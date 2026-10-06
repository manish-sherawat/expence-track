import '../models/account.dart';
import '../models/ai_insight.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/financial_summary.dart';
import '../models/merchant.dart';
import '../models/money.dart';
import '../models/receipt.dart';
import '../models/salary_profile.dart';
import '../models/transaction.dart';

abstract class IFinanceRepository {
  Stream<Money> watchTotalBalance();
  Stream<List<Account>> watchAccounts();
  Stream<List<Category>> watchCategories();
  Stream<List<Merchant>> watchMerchants();
  Stream<List<Transaction>> watchRecentTransactions({int limit = 50});
  Stream<List<Transaction>> watchTransactionsByMonth(int year, int month);
  Future<Transaction?> getTransactionById(String id);
  Future<Receipt?> getReceiptByTransactionId(String transactionId);
  Future<void> saveReceipt(Receipt receipt);
  Stream<List<Budget>> watchBudgets(int year, int month);
  Stream<SalaryProfile?> watchSalaryProfile();
  Stream<List<AiInsight>> watchInsights();
  Future<FinancialSummary> getFinancialSummary(int year, int month);
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<void> updateBudget(Budget budget);
  Future<void> updateSalaryProfile(SalaryProfile profile);
  Future<void> dismissInsight(String id);
  Future<void> seedMockupData();
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed);
  Future<String> getAppSetting(String key, {String defaultValue = ''});
  Future<void> setAppSetting(String key, String value);
  Future<void> seedInitialFreshData(SalaryProfile profile);
  Future<String> exportDatabaseToCsv();
}

