import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/repositories/finance_repository.dart';
import '../data/services/local_ai_service.dart';
import '../data/services/remote_ai_service.dart';
import '../domain/models/account.dart';
import '../domain/models/ai_insight.dart';
import '../domain/models/budget.dart';
import '../domain/models/category.dart';
import '../domain/models/financial_summary.dart';
import '../domain/models/merchant.dart';
import '../domain/models/money.dart';
import '../domain/models/receipt.dart';
import '../domain/models/salary_profile.dart';
import '../domain/models/transaction.dart';
import '../domain/repositories/i_finance_repository.dart';
import '../domain/services/i_ai_service.dart';

/// Database instance provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Single Finance Repository provider.
final financeRepositoryProvider = Provider<IFinanceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final repo = FinanceRepository(db);
  // Auto-seed mockup dataset on initial repository creation
  repo.seedMockupData();
  return repo;
});

/// Selected month and year filter for reports (defaults to April 2026 for mockups).
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime(2026, 4);
});

/// Real-time stream of user's total net worth balance.
final totalBalanceStreamProvider = StreamProvider<Money>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.watchTotalBalance();
});

/// Real-time stream of all user accounts (checking, savings, credit cards).
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.watchAccounts();
});

/// Real-time stream of all spending and income categories.
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.watchCategories();
});

/// Real-time stream of all merchants with visit history.
final merchantsStreamProvider = StreamProvider<List<Merchant>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.watchMerchants();
});

/// Real-time stream of recent transactions for the Home screen feed.
final recentTransactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.watchRecentTransactions(limit: 50);
});

/// Real-time stream of all transactions.
final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.watchRecentTransactions(limit: 500);
});

/// Real-time stream of transactions for the currently selected month.
final monthlyTransactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  return repo.watchTransactionsByMonth(selectedMonth.year, selectedMonth.month);
});

/// Comprehensive monthly financial summary (Income, Expenses, Saved, Daily Avg, MoM, etc.).
final financialSummaryFutureProvider = FutureProvider<FinancialSummary>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  return repo.getFinancialSummary(selectedMonth.year, selectedMonth.month);
});

/// Real-time stream of monthly financial summary.
final financialSummaryStreamProvider = StreamProvider<FinancialSummary>((ref) async* {
  final repo = ref.watch(financeRepositoryProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  yield await repo.getFinancialSummary(selectedMonth.year, selectedMonth.month);
});

/// Real-time stream of category budgets for the current month.
final budgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  return repo.watchBudgets(selectedMonth.year, selectedMonth.month);
});

/// Real-time stream of salary profile.
final salaryProfileStreamProvider = StreamProvider<SalaryProfile?>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.watchSalaryProfile();
});

/// Real-time stream of active AI insights.
final insightsStreamProvider = StreamProvider<List<AiInsight>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.watchInsights();
});

/// Selected transaction ID for detail view.
final selectedTransactionIdProvider = StateProvider<String?>((ref) => null);

/// Transaction detail by ID provider.
final transactionDetailFutureProvider =
    FutureProvider.family<Transaction?, String>((ref, id) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getTransactionById(id);
});

/// Receipt detail by transaction ID provider.
final receiptDetailFutureProvider =
    FutureProvider.family<Receipt?, String>((ref, transactionId) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getReceiptByTransactionId(transactionId);
});

/// User privacy consent state for remote cloud AI processing (toggled in Settings).
final remoteAiConsentProvider = StateProvider<bool>((ref) => false);

/// Unified AI service provider with privacy consent toggle and local fallback.
final aiServiceProvider = Provider<IAiService>((ref) {
  final consent = ref.watch(remoteAiConsentProvider);
  return RemoteAiService(
    userConsent: consent,
    fallback: const LocalAiService(),
  );
});

/// User profile display name provider (persisted in app settings).
final userNameProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getAppSetting('user_name', defaultValue: 'Jacob Simmons');
});


