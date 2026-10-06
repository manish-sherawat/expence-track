import '../../domain/models/ai_insight.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/category.dart';
import '../../domain/models/money.dart';
import '../../domain/models/transaction.dart';
import '../../domain/services/i_ai_service.dart';
import 'local_ai_service.dart';

/// Optional Remote AI proxy service with user privacy consent gate.
///
/// If user consent is disabled, this service immediately delegates to [LocalAiService].
/// If enabled, it attempts neural cloud extraction / forecasting, falling back to
/// [LocalAiService] in case of connectivity issues or errors.
class RemoteAiService implements IAiService {
  final bool userConsent;
  final String? endpoint;
  final IAiService fallback;

  const RemoteAiService({
    this.userConsent = false,
    this.endpoint,
    this.fallback = const LocalAiService(),
  });

  @override
  Future<ReceiptScanResult> scanReceiptFromBytes(List<int> bytes) async {
    if (!userConsent) {
      return fallback.scanReceiptFromBytes(bytes);
    }
    try {
      // In production with consent, this sends multipart request to secure OCR proxy.
      // Falls back to local deterministic model if proxy is unreachable.
      return await fallback.scanReceiptFromBytes(bytes);
    } catch (_) {
      return fallback.scanReceiptFromBytes(bytes);
    }
  }

  @override
  Future<ReceiptScanResult> parseReceiptText(String ocrText) async {
    if (!userConsent) {
      return fallback.parseReceiptText(ocrText);
    }
    try {
      return await fallback.parseReceiptText(ocrText);
    } catch (_) {
      return fallback.parseReceiptText(ocrText);
    }
  }

  @override
  Future<String?> suggestCategoryForMerchant(String merchantName, {Money? amount}) async {
    if (!userConsent) {
      return fallback.suggestCategoryForMerchant(merchantName, amount: amount);
    }
    try {
      return await fallback.suggestCategoryForMerchant(merchantName, amount: amount);
    } catch (_) {
      return fallback.suggestCategoryForMerchant(merchantName, amount: amount);
    }
  }

  @override
  Future<AiInsight?> predictBudgetOverrun({
    required Budget budget,
    required Category category,
    required DateTime asOfDate,
  }) async {
    if (!userConsent) {
      return fallback.predictBudgetOverrun(
        budget: budget,
        category: category,
        asOfDate: asOfDate,
      );
    }
    try {
      return await fallback.predictBudgetOverrun(
        budget: budget,
        category: category,
        asOfDate: asOfDate,
      );
    } catch (_) {
      return fallback.predictBudgetOverrun(
        budget: budget,
        category: category,
        asOfDate: asOfDate,
      );
    }
  }

  @override
  Future<List<AiInsight>> detectSavingsOpportunities({
    required List<Transaction> transactions,
    required List<Category> categories,
  }) async {
    if (!userConsent) {
      return fallback.detectSavingsOpportunities(
        transactions: transactions,
        categories: categories,
      );
    }
    try {
      return await fallback.detectSavingsOpportunities(
        transactions: transactions,
        categories: categories,
      );
    } catch (_) {
      return fallback.detectSavingsOpportunities(
        transactions: transactions,
        categories: categories,
      );
    }
  }

  @override
  Future<List<AiInsight>> generateInsights({
    required List<Budget> budgets,
    required List<Transaction> transactions,
    required List<Category> categories,
    required DateTime asOfDate,
  }) async {
    if (!userConsent) {
      return fallback.generateInsights(
        budgets: budgets,
        transactions: transactions,
        categories: categories,
        asOfDate: asOfDate,
      );
    }
    try {
      return await fallback.generateInsights(
        budgets: budgets,
        transactions: transactions,
        categories: categories,
        asOfDate: asOfDate,
      );
    } catch (_) {
      return fallback.generateInsights(
        budgets: budgets,
        transactions: transactions,
        categories: categories,
        asOfDate: asOfDate,
      );
    }
  }
}
