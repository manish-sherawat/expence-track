import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/data/database/app_database.dart';
import 'package:salary_tracker/data/repositories/finance_repository.dart';
import 'package:salary_tracker/domain/models/money.dart';
import 'package:salary_tracker/domain/models/transaction.dart' as domain;

void main() {
  late AppDatabase db;
  late FinanceRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = FinanceRepository(db);
    await repository.seedMockupData();
  });

  tearDown(() async {
    await db.close();
  });

  group('FinanceRepository & Derived Financial Calculations Tests', () {
    test(r'Mockup seed data seeds accounts with exact $12,892.90 balance', () async {
      final balance = await repository.watchTotalBalance().first;
      expect(balance.cents, 1289290);
      expect(balance.format(), r'$12,892.90');

      final accounts = await repository.watchAccounts().first;
      expect(accounts.length, 2);
      expect(accounts.first.name, 'Primary Checking');
      expect(accounts.first.balance.cents, 842940);
      expect(accounts.last.name, 'High Yield Savings');
      expect(accounts.last.balance.cents, 446350);
    });

    test('Mockup seed data seeds categories and merchants accurately', () async {
      final categories = await repository.watchCategories().first;
      expect(categories.length, 6);
      expect(categories.any((c) => c.name == 'Rent'), isTrue);
      expect(categories.any((c) => c.name == 'Food'), isTrue);
      expect(categories.any((c) => c.name == 'Transport'), isTrue);
      expect(categories.any((c) => c.name == 'Shopping'), isTrue);

      final merchants = await repository.watchMerchants().first;
      expect(merchants.length, 6);
      final wholeFoods = merchants.firstWhere((m) => m.name == 'Whole Foods Market');
      expect(wholeFoods.visitCount, 8);
      expect(wholeFoods.totalSpent.cents, 48920); // $489.20
    });

    test('FinancialSummary for April 2026 matches exact mockup figures', () async {
      final summary = await repository.getFinancialSummary(2026, 4);

      expect(summary.totalBalance.cents, 1289290); // $12,892.90
      expect(summary.totalIncome.cents, 842900);   // $8,429.00
      expect(summary.totalExpenses.cents, 321800); // $3,218.00
      expect(summary.totalSaved.cents, 219000);    // $2,190.00
      expect(summary.rentSharePercentage, 37.3);   // 37.3% (rounds to 37% on mockup)
      expect(summary.rentSharePercentage.round(), 37);
      expect(summary.biggestCategoryName, 'Rent');
      expect(summary.biggestCategoryAmount.cents, 120000); // $1,200.00
      expect(summary.aiSavingsFound.cents, 18400); // $184.00
    });

    test('Transaction and receipt lookup works with line items', () async {
      final txn = await repository.getTransactionById('txn_wf_01');
      expect(txn, isNotNull);
      expect(txn!.title, 'Whole Foods Market');
      expect(txn.amount.cents, -3291);
      expect(txn.hasReceipt, isTrue);

      final receipt = await repository.getReceiptByTransactionId('txn_wf_01');
      expect(receipt, isNotNull);
      expect(receipt!.merchantName, 'Whole Foods Market');
      expect(receipt.total.cents, 3291);
      expect(receipt.items.length, 4);
      expect(receipt.items.first.name, 'Organic Oat Milk');
      expect(receipt.items.first.price.cents, 998);
      expect(receipt.items[1].name, 'Avocados (Hass)');
      expect(receipt.items[1].quantity, 4);
    });

    test('Budget domain model calculations (over, under, progress ratio)', () async {
      final budgets = await repository.watchBudgets(2026, 4).first;
      expect(budgets.length, 4);

      // Food: Limit $700, Spent $850 -> Over by $150
      final foodBudget = budgets.firstWhere((b) => b.categoryId == 'cat_food');
      expect(foodBudget.isOverBudget, isTrue);
      expect(foodBudget.overspentAmount.cents, 15000);
      expect(foodBudget.progressRatio, greaterThan(1.0));

      // Transport: Limit $500, Spent $420 -> Under by $80
      final transportBudget = budgets.firstWhere((b) => b.categoryId == 'cat_transport');
      expect(transportBudget.isOverBudget, isFalse);
      expect(transportBudget.remainingAmount.cents, 8000);
      expect(transportBudget.progressRatio, closeTo(0.84, 0.01));
    });

    test('Adding a transaction updates account balance and recent list', () async {
      final initialBalance = await repository.watchTotalBalance().first;

      final newTxn = domain.Transaction(
        id: 'txn_test_coffee',
        accountId: 'acc_checking_01',
        categoryId: 'cat_food',
        amount: const Money(-550), // -$5.50
        timestamp: DateTime(2026, 4, 15, 10, 0),
        title: 'Morning Espresso',
        subtitle: 'Coffee',
        type: domain.TransactionType.expense,
      );

      await repository.addTransaction(newTxn);

      final updatedBalance = await repository.watchTotalBalance().first;
      expect(updatedBalance.cents, initialBalance.cents - 550);

      final recent = await repository.watchRecentTransactions(limit: 5).first;
      expect(recent.any((t) => t.id == 'txn_test_coffee'), isTrue);
    });

    test('Dismissing insight updates active insights stream', () async {
      final initialInsights = await repository.watchInsights().first;
      expect(initialInsights.length, 2);

      await repository.dismissInsight('insight_dining_overrun');

      final updatedInsights = await repository.watchInsights().first;
      expect(updatedInsights.length, 1);
      expect(updatedInsights.first.id, 'insight_sub_savings');
    });
  });
}
