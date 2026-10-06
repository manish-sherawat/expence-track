import 'dart:math' as math;
import '../../domain/models/ai_insight.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/category.dart';
import '../../domain/models/money.dart';
import '../../domain/models/receipt.dart';
import '../../domain/models/transaction.dart';
import '../../domain/services/i_ai_service.dart';

/// Fast, deterministic local AI service for receipt scanning and rule-based
/// category inference.
class LocalAiService implements IAiService {
  const LocalAiService();

  @override
  Future<ReceiptScanResult> scanReceiptFromBytes(List<int> bytes) async {
    // In local / offline mode, simulates neural OCR processing latency
    await Future<void>.delayed(const Duration(milliseconds: 250));

    // Return structured scan corresponding to standard mockup receipt
    const items = [
      ReceiptLineItem(
        id: 'ocr_item_1',
        receiptId: 'ocr_rcpt_01',
        name: 'Organic Oat Milk',
        quantity: 2,
        price: Money(998), // $9.98
      ),
      ReceiptLineItem(
        id: 'ocr_item_2',
        receiptId: 'ocr_rcpt_01',
        name: 'Avocados (Hass)',
        quantity: 4,
        price: Money(600), // $6.00
      ),
      ReceiptLineItem(
        id: 'ocr_item_3',
        receiptId: 'ocr_rcpt_01',
        name: 'Greek Yogurt 32oz',
        quantity: 1,
        price: Money(749), // $7.49
      ),
      ReceiptLineItem(
        id: 'ocr_item_4',
        receiptId: 'ocr_rcpt_01',
        name: 'Artisan Sourdough',
        quantity: 1,
        price: Money(699), // $6.99
      ),
    ];

    return ReceiptScanResult(
      merchantName: 'Whole Foods Market',
      timestamp: DateTime.now(),
      items: items,
      subtotal: const Money(3046),
      tax: const Money(245),
      total: const Money(3291),
      confidenceScore: 0.985,
      suggestedCategory: 'Groceries',
      rawText: '''
WHOLE FOODS MARKET
Store #10429 - New York, NY
================================
2x ORGANIC OAT MILK       \$9.98
4x AVOCADOS (HASS)        \$6.00
1x GREEK YOGURT 32OZ      \$7.49
1x ARTISAN SOURDOUGH      \$6.99
--------------------------------
SUBTOTAL                 \$30.46
TAX 8%                    \$2.45
TOTAL                    \$32.91
================================
AUTH: 839201 VISA 4829
''',
    );
  }

  @override
  Future<ReceiptScanResult> parseReceiptText(String ocrText) async {
    final lines = ocrText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String merchant = 'Unknown Merchant';
    final List<ReceiptLineItem> items = [];
    int subtotalCents = 0;
    int taxCents = 0;
    int totalCents = 0;

    final priceRegex = RegExp(r'\$?\s*(\d+[.,]\d{2})');
    final quantityRegex = RegExp(r'^(\d+)\s*[xX@]\s*(.+)$');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final upper = line.toUpperCase();

      // First few non-dashed lines usually identify the merchant
      if (i < 3 &&
          !upper.contains('===') &&
          !upper.contains('---') &&
          !upper.contains('RECEIPT') &&
          merchant == 'Unknown Merchant') {
        merchant = line;
      }

      final isSubtotal = upper.contains('SUBTOTAL') || upper.contains('SUB TOTAL');
      final isTax = upper.contains('TAX') && !upper.contains('TAXABLE');
      final isTotal = !isSubtotal &&
          (upper.contains('TOTAL') ||
              upper.contains('BALANCE DUE') ||
              upper.contains('AMOUNT DUE') ||
              upper.contains('NET AMOUNT') ||
              upper.contains('TOTAI'));
      final isIgnoredFooter = upper.contains('AUTH') ||
          upper.contains('VISA') ||
          upper.contains('MASTERCARD') ||
          upper.contains('AMEX') ||
          upper.contains('DISCOVER') ||
          upper.contains('CARD') ||
          upper.contains('CHANGE') ||
          upper.contains('CASH TENDERED') ||
          upper.contains('APPROVED') ||
          upper.contains('AID ') ||
          upper.contains('TC ');

      if (isSubtotal) {
        final match = priceRegex.firstMatch(line);
        if (match != null) {
          subtotalCents = _parseCents(match.group(1)!);
        }
      } else if (isTax) {
        final match = priceRegex.firstMatch(line);
        if (match != null) {
          taxCents = _parseCents(match.group(1)!);
        }
      } else if (isTotal) {
        final match = priceRegex.firstMatch(line);
        if (match != null) {
          totalCents = _parseCents(match.group(1)!);
        }
      } else if (!isIgnoredFooter) {
        // Line item candidate
        final priceMatch = priceRegex.firstMatch(line);
        if (priceMatch != null) {
          final priceStr = priceMatch.group(1)!;
          final itemPrice = _parseCents(priceStr);
          final textBeforePrice = line.substring(0, priceMatch.start).trim();

          if (textBeforePrice.isNotEmpty && !textBeforePrice.startsWith('-')) {
            int qty = 1;
            String itemName = textBeforePrice;

            final qMatch = quantityRegex.firstMatch(textBeforePrice);
            if (qMatch != null) {
              qty = int.tryParse(qMatch.group(1)!) ?? 1;
              itemName = qMatch.group(2)!.trim();
            }

            // Clean leading index numbering like "1. ", "1) ", or "#1 "
            itemName = itemName.replaceFirst(RegExp(r'^#?\d+[\.\)]\s*'), '');

            items.add(
              ReceiptLineItem(
                id: 'parsed_${items.length + 1}',
                receiptId: 'parsed_rcpt',
                name: itemName,
                quantity: qty,
                price: Money(itemPrice),
              ),
            );
          }
        }
      }
    }

    if (subtotalCents == 0 && items.isNotEmpty) {
      subtotalCents = items.fold(0, (sum, it) => sum + it.price.cents);
    }
    if (totalCents == 0) {
      totalCents = subtotalCents + taxCents;
    }

    final category = await suggestCategoryForMerchant(merchant);

    return ReceiptScanResult(
      merchantName: merchant,
      timestamp: DateTime.now(),
      items: items,
      subtotal: Money(subtotalCents),
      tax: Money(taxCents),
      total: Money(totalCents),
      confidenceScore: math.min(1.0, 0.70 + (items.length * 0.07)),
      suggestedCategory: category,
      rawText: ocrText,
    );
  }

  @override
  Future<String?> suggestCategoryForMerchant(String merchantName, {Money? amount}) async {
    final lower = merchantName.toLowerCase();
    if (lower.contains('rent') ||
        lower.contains('lease') ||
        lower.contains('real estate') ||
        lower.contains('property') ||
        lower.contains('landlord')) {
      return 'Rent';
    }
    if (lower.contains('payroll') ||
        lower.contains('salary') ||
        lower.contains('techcorp')) {
      return 'Salary';
    }
    if (lower.contains('whole foods') ||
        lower.contains('trader joe') ||
        lower.contains('grocery') ||
        lower.contains('market') ||
        lower.contains('safeway') ||
        lower.contains('supermarket')) {
      return 'Groceries';
    }
    if (lower.contains('uber') ||
        lower.contains('lyft') ||
        lower.contains('transit') ||
        lower.contains('mta') ||
        lower.contains('subway') ||
        RegExp(r'\bmetro\b').hasMatch(lower)) {
      return 'Transport';
    }
    if (lower.contains('coffee') ||
        lower.contains('starbucks') ||
        lower.contains('blue bottle') ||
        lower.contains('cafe') ||
        lower.contains('restaurant') ||
        lower.contains('diner') ||
        lower.contains('tavern') ||
        lower.contains('bistro')) {
      return 'Dining';
    }
    if (lower.contains('apple') ||
        lower.contains('nordstrom') ||
        lower.contains('amazon') ||
        lower.contains('target') ||
        lower.contains('clothing') ||
        lower.contains('store')) {
      return 'Shopping';
    }
    return null;
  }

  @override
  Future<AiInsight?> predictBudgetOverrun({
    required Budget budget,
    required Category category,
    required DateTime asOfDate,
  }) async {
    final day = asOfDate.day;
    if (day <= 0) return null;

    final daysInMonth = DateTime(asOfDate.year, asOfDate.month + 1, 0).day;
    final spentCents = budget.spentAmount.cents;
    final limitCents = budget.limitAmount.cents;

    if (spentCents <= 0 || limitCents <= 0) return null;

    // Daily spending velocity projection
    final dailyRate = spentCents / day;
    final projectedCents = (dailyRate * daysInMonth).round();

    if (projectedCents > limitCents) {
      final overrunCents = projectedCents - limitCents;
      final overrunDollars = (overrunCents / 100.0).round();
      final catName = category.name.toLowerCase();

      return AiInsight(
        id: 'insight_overrun_${category.id}_${asOfDate.month}',
        title: '${category.name} Budget Velocity Warning',
        description:
            'You may exceed $catName budget by \$$overrunDollars by month end based on current velocity.',
        type: AiInsightType.overrunWarning,
        impactAmount: Money(overrunCents),
        categoryId: category.id,
        actionLabel: 'Review & adjust',
        routePath: '/insight',
        createdAt: asOfDate,
      );
    }
    return null;
  }

  @override
  Future<List<AiInsight>> detectSavingsOpportunities({
    required List<Transaction> transactions,
    required List<Category> categories,
  }) async {
    final List<AiInsight> findings = [];

    // 1. Group recurring subscription patterns
    final Map<String, List<Transaction>> byMerchant = {};
    for (final t in transactions) {
      if (t.type == TransactionType.expense) {
        final key = t.title.toLowerCase();
        byMerchant.putIfAbsent(key, () => []).add(t);
      }
    }

    int recurringTotalCents = 0;
    byMerchant.forEach((merchant, list) {
      final isSub = merchant.contains('netflix') ||
          merchant.contains('spotify') ||
          merchant.contains('gym') ||
          merchant.contains('fitness') ||
          merchant.contains('subscription') ||
          merchant.contains('membership') ||
          merchant.contains('prime');
      if (isSub && list.isNotEmpty) {
        recurringTotalCents += list.fold(0, (sum, t) => sum + t.amount.cents.abs());
      }
    });

    if (recurringTotalCents > 0) {
      final impact = (recurringTotalCents / 100.0).toStringAsFixed(2);
      findings.add(
        AiInsight(
          id: 'insight_sub_savings_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Subscription Optimization',
          description: 'Found \$$impact/mo in recurring memberships & subscriptions.',
          type: AiInsightType.savingFound,
          impactAmount: Money(recurringTotalCents),
          actionLabel: 'View details',
          routePath: '/insight',
          createdAt: DateTime.now(),
        ),
      );
    }

    // 2. High dining velocity optimization
    final diningTxns = transactions.where((t) {
      final catId = t.categoryId.toLowerCase();
      final title = t.title.toLowerCase();
      return catId.contains('food') ||
          title.contains('cafe') ||
          title.contains('coffee') ||
          title.contains('restaurant');
    }).toList();

    if (diningTxns.length >= 3) {
      final diningTotalCents = diningTxns.fold(0, (sum, t) => sum + t.amount.cents.abs());
      if (diningTotalCents > 20000) {
        final potentialSavingsCents = (diningTotalCents * 0.25).round();
        final formattedSavings = (potentialSavingsCents / 100.0).round();
        findings.add(
          AiInsight(
            id: 'insight_dining_shift_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Dining Optimization',
            description:
                'Shifting 2 dining meals to home cooking could save \$$formattedSavings/mo.',
            type: AiInsightType.spendingVelocity,
            impactAmount: Money(potentialSavingsCents),
            actionLabel: 'See category breakdown',
            routePath: '/insight',
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    return findings;
  }

  @override
  Future<List<AiInsight>> generateInsights({
    required List<Budget> budgets,
    required List<Transaction> transactions,
    required List<Category> categories,
    required DateTime asOfDate,
  }) async {
    final List<AiInsight> result = [];

    // Overrun warnings
    for (final budget in budgets) {
      final category = categories.firstWhere(
        (c) => c.id == budget.categoryId,
        orElse: () => Category(
          id: budget.categoryId,
          name: 'General',
          iconKey: 'wallet',
          colorHex: 0xFF5B616E,
        ),
      );
      final overrun = await predictBudgetOverrun(
        budget: budget,
        category: category,
        asOfDate: asOfDate,
      );
      if (overrun != null) {
        result.add(overrun);
      }
    }

    // Savings detectors
    final savings = await detectSavingsOpportunities(
      transactions: transactions,
      categories: categories,
    );
    result.addAll(savings);

    return result;
  }

  int _parseCents(String text) {
    final cleaned = text.replaceAll(',', '.').replaceAll(RegExp(r'[^\d.]'), '');
    final val = double.tryParse(cleaned) ?? 0.0;
    return (val * 100).round();
  }
}
