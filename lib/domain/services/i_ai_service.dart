import '../models/ai_insight.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/money.dart';
import '../models/receipt.dart';
import '../models/transaction.dart';

/// Result from AI Receipt OCR scanning and parsing.
class ReceiptScanResult {
  final String merchantName;
  final DateTime timestamp;
  final List<ReceiptLineItem> items;
  final Money subtotal;
  final Money tax;
  final Money total;
  final double confidenceScore;
  final String? suggestedCategory;
  final String rawText;

  const ReceiptScanResult({
    required this.merchantName,
    required this.timestamp,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.confidenceScore = 0.98,
    this.suggestedCategory,
    this.rawText = '',
  });
}

/// Abstract AI service interface for receipt scanning, OCR extraction,
/// financial categorisation, budget velocity forecasting, and savings detection.
abstract class IAiService {
  /// Scans receipt image bytes and produces structured itemized receipt data.
  Future<ReceiptScanResult> scanReceiptFromBytes(List<int> bytes);

  /// Parses raw OCR text into structured receipt line items, tax, and totals.
  Future<ReceiptScanResult> parseReceiptText(String ocrText);

  /// Predicts / suggests category for a given merchant name and optional amount.
  Future<String?> suggestCategoryForMerchant(String merchantName, {Money? amount});

  /// Predicts whether a budget will be overrun by month end based on current velocity.
  Future<AiInsight?> predictBudgetOverrun({
    required Budget budget,
    required Category category,
    required DateTime asOfDate,
  });

  /// Detects potential savings opportunities from recurring charges or excess category spend.
  Future<List<AiInsight>> detectSavingsOpportunities({
    required List<Transaction> transactions,
    required List<Category> categories,
  });

  /// Synthesizes comprehensive AI insights combining overrun forecasts and savings detectors.
  Future<List<AiInsight>> generateInsights({
    required List<Budget> budgets,
    required List<Transaction> transactions,
    required List<Category> categories,
    required DateTime asOfDate,
  });
}

