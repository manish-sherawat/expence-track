import 'dart:async';
import 'package:drift/drift.dart';

import '../../domain/models/account.dart';
import '../../domain/models/ai_insight.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/category.dart';
import '../../domain/models/financial_summary.dart';
import '../../domain/models/merchant.dart';
import '../../domain/models/money.dart';
import '../../domain/models/receipt.dart';
import '../../domain/models/salary_profile.dart';
import '../../domain/models/transaction.dart' as domain_txn;
import '../../domain/repositories/i_finance_repository.dart';
import '../database/app_database.dart';
import '../seed/mockup_seed_data.dart';

class FinanceRepository implements IFinanceRepository {
  FinanceRepository(this._db);

  final AppDatabase _db;
  Future<void>? _seedFuture;

  // ---------------------------------------------------------------------------
  // Reactive Streams
  // ---------------------------------------------------------------------------

  @override
  Stream<Money> watchTotalBalance() {
    return _db.select(_db.accounts).watch().map((accounts) {
      if (accounts.isEmpty) return MockupSeedData.totalBalance;
      final sum = accounts.fold<int>(0, (prev, acc) => prev + acc.balanceMinor);
      return Money(sum);
    });
  }

  @override
  Stream<List<Account>> watchAccounts() {
    return _db.select(_db.accounts).watch().map((rows) {
      return rows.map(_mapAccount).toList();
    });
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _db.select(_db.categories).watch().map((rows) {
      return rows.map(_mapCategory).toList();
    });
  }

  @override
  Stream<List<Merchant>> watchMerchants() {
    return _db.select(_db.merchants).watch().map((rows) {
      return rows.map(_mapMerchant).toList();
    });
  }

  @override
  Stream<List<domain_txn.Transaction>> watchRecentTransactions({int limit = 50}) {
    final query = _db.select(_db.transactions)
      ..orderBy([
        (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    return query.watch().map((rows) {
      return rows.map(_mapTransaction).toList();
    });
  }

  @override
  Stream<List<domain_txn.Transaction>> watchTransactionsByMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    final query = _db.select(_db.transactions)
      ..where((t) => t.timestamp.isBiggerOrEqualValue(start) & t.timestamp.isSmallerThanValue(end))
      ..orderBy([
        (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
      ]);

    return query.watch().map((rows) {
      return rows.map(_mapTransaction).toList();
    });
  }

  @override
  Future<domain_txn.Transaction?> getTransactionById(String id) async {
    final query = _db.select(_db.transactions)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapTransaction(row);
  }

  @override
  Future<Receipt?> getReceiptByTransactionId(String transactionId) async {
    final rcptQuery = _db.select(_db.receipts)
      ..where((r) => r.transactionId.equals(transactionId));
    final rcptRow = await rcptQuery.getSingleOrNull();
    if (rcptRow == null) return null;

    final itemsQuery = _db.select(_db.receiptItems)
      ..where((item) => item.receiptId.equals(rcptRow.id));
    final itemsRows = await itemsQuery.get();

    return _mapReceipt(rcptRow, itemsRows);
  }

  @override
  Future<void> saveReceipt(Receipt receipt) async {
    await _db.into(_db.receipts).insertOnConflictUpdate(
      ReceiptsCompanion.insert(
        id: receipt.id,
        transactionId: receipt.transactionId,
        merchantName: receipt.merchantName,
        timestamp: receipt.timestamp,
        subtotalMinor: receipt.subtotal.cents,
        taxMinor: receipt.tax.cents,
        totalMinor: receipt.total.cents,
        rawOcrText: Value(receipt.rawOcrText),
        imageUrl: Value(receipt.imageUrl),
      ),
    );

    await (_db.delete(_db.receiptItems)..where((item) => item.receiptId.equals(receipt.id))).go();
    for (final item in receipt.items) {
      await _db.into(_db.receiptItems).insert(
        ReceiptItemsCompanion.insert(
          id: item.id,
          receiptId: receipt.id,
          name: item.name,
          quantity: Value(item.quantity),
          priceMinor: item.price.cents,
        ),
      );
    }
  }

  @override
  Stream<List<Budget>> watchBudgets(int year, int month) {
    final query = _db.select(_db.budgets)
      ..where((b) => b.year.equals(year) & b.month.equals(month));

    return query.watch().map((rows) {
      return rows.map(_mapBudget).toList();
    });
  }

  @override
  Stream<SalaryProfile?> watchSalaryProfile() {
    return _db.select(_db.salaryProfiles).watch().map((rows) {
      if (rows.isEmpty) return null;
      return _mapSalaryProfile(rows.first);
    });
  }

  @override
  Stream<List<AiInsight>> watchInsights() {
    final query = _db.select(_db.insights)
      ..where((i) => i.isDismissed.equals(false))
      ..orderBy([
        (i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc),
      ]);

    return query.watch().map((rows) {
      return rows.map(_mapInsight).toList();
    });
  }

  // ---------------------------------------------------------------------------
  // Derived Financial Calculations
  // ---------------------------------------------------------------------------

  @override
  Future<FinancialSummary> getFinancialSummary(int year, int month) async {
    // 1. Total Balance
    final accounts = await _db.select(_db.accounts).get();
    final balanceMinor = accounts.fold<int>(
      0,
      (prev, a) => prev + a.balanceMinor,
    );

    // 2. Transactions in Month
    final start = DateTime(year, month, 1);
    final end = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    final txns = await (_db.select(_db.transactions)
          ..where((t) =>
              t.timestamp.isBiggerOrEqualValue(start) &
              t.timestamp.isSmallerThanValue(end)))
        .get();

    int incomeMinor = 0;
    int expenseMinor = 0;
    int savedMinor = 0;
    final categoryTotals = <String, int>{};

    for (final t in txns) {
      if (t.type == 'income') {
        incomeMinor += t.amountMinor.abs();
      } else if (t.type == 'transfer' || t.categoryId == MockupSeedData.catSavings) {
        savedMinor += t.amountMinor.abs();
      } else if (t.type == 'expense' || t.amountMinor < 0) {
        final absAmount = t.amountMinor.abs();
        expenseMinor += absAmount;
        categoryTotals[t.categoryId] = (categoryTotals[t.categoryId] ?? 0) + absAmount;
      }
    }

    // Days in Month
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final dailyAvgMinor = daysInMonth > 0 ? (expenseMinor ~/ daysInMonth) : 0;

    // Previous Month Expenses for MoM Change
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    final prevStart = DateTime(prevYear, prevMonth, 1);
    final prevEnd = DateTime(year, month, 1);

    final prevTxns = await (_db.select(_db.transactions)
          ..where((t) =>
              t.timestamp.isBiggerOrEqualValue(prevStart) &
              t.timestamp.isSmallerThanValue(prevEnd) &
              t.type.equals('expense')))
        .get();

    final prevExpenseMinor = prevTxns.fold<int>(
      0,
      (prev, t) => prev + t.amountMinor.abs(),
    );

    double momChange = 0.0;
    if (prevExpenseMinor > 0) {
      momChange = ((expenseMinor - prevExpenseMinor) / prevExpenseMinor) * 100.0;
    } else {
      momChange = -4.2; // Default mockup reference
    }

    // Biggest Category
    String biggestCatId = MockupSeedData.catRent;
    int biggestCatAmount = 0;
    categoryTotals.forEach((catId, total) {
      if (total > biggestCatAmount) {
        biggestCatAmount = total;
        biggestCatId = catId;
      }
    });

    // Lookup Category Name
    String biggestCatName = 'Rent';
    final catRow = await (_db.select(_db.categories)..where((c) => c.id.equals(biggestCatId))).getSingleOrNull();
    if (catRow != null) {
      biggestCatName = catRow.name;
    }

    final hasAccounts = accounts.isNotEmpty;

    // Rent Share Percentage
    final rentSpent = categoryTotals[MockupSeedData.catRent] ?? (hasAccounts ? 0 : 120000);
    final rentShare = expenseMinor > 0
        ? (rentSpent / expenseMinor) * 100.0
        : (hasAccounts ? 0.0 : 37.0);

    // Savings Found
    final insights = await (_db.select(_db.insights)
          ..where((i) => i.type.equals('savingFound') & i.isDismissed.equals(false)))
        .get();
    final savingsFoundMinor = insights.fold<int>(
      0,
      (prev, i) => prev + (i.impactAmountMinor ?? 0),
    );

    return FinancialSummary(
      month: month,
      year: year,
      totalBalance: Money(hasAccounts ? balanceMinor : MockupSeedData.totalBalance.cents),
      totalIncome: Money(hasAccounts ? incomeMinor : MockupSeedData.summary.totalIncome.cents),
      totalExpenses: Money(hasAccounts ? expenseMinor : MockupSeedData.summary.totalExpenses.cents),
      totalSaved: Money(hasAccounts ? savedMinor : MockupSeedData.summary.totalSaved.cents),
      dailyAverage: Money(hasAccounts ? dailyAvgMinor : MockupSeedData.summary.dailyAverage.cents),
      momChangePercentage: momChange,
      rentSharePercentage: double.parse(rentShare.toStringAsFixed(1)),
      biggestCategoryName: biggestCatAmount > 0
          ? biggestCatName
          : (hasAccounts ? 'None' : MockupSeedData.summary.biggestCategoryName),
      biggestCategoryAmount: Money(hasAccounts ? biggestCatAmount : MockupSeedData.summary.biggestCategoryAmount.cents),
      aiSavingsFound: Money(hasAccounts ? savingsFoundMinor : MockupSeedData.summary.aiSavingsFound.cents),
    );
  }

  // ---------------------------------------------------------------------------
  // Mutating Operations
  // ---------------------------------------------------------------------------

  @override
  Future<void> addTransaction(domain_txn.Transaction transaction) async {
    if (_seedFuture != null) {
      await _seedFuture;
    }
    final existingAccounts = await _db.select(_db.accounts).get();
    if (existingAccounts.isEmpty) {
      await seedMockupData();
    }

    await _db.into(_db.transactions).insert(
          TransactionRow(
            id: transaction.id,
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            merchantId: transaction.merchantId,
            amountMinor: transaction.amount.cents,
            timestamp: transaction.timestamp,
            title: transaction.title,
            subtitle: transaction.subtitle,
            note: transaction.note,
            aiSuggestedCategory: transaction.aiSuggestedCategory,
            aiConfirmed: transaction.aiConfirmed,
            cardLastFour: transaction.cardLastFour,
            hasReceipt: transaction.hasReceipt,
            type: transaction.type.name,
          ),
          mode: InsertMode.insertOrReplace,
        );

    // Update account balance
    final account = await (_db.select(_db.accounts)..where((a) => a.id.equals(transaction.accountId))).getSingleOrNull();
    if (account != null) {
      final newBalance = account.balanceMinor + transaction.amount.cents;
      await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id))).write(
        AccountsCompanion(balanceMinor: Value(newBalance)),
      );
    }
  }

  @override
  Future<void> updateTransaction(domain_txn.Transaction transaction) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(transaction.id))).write(
      TransactionsCompanion(
        categoryId: Value(transaction.categoryId),
        title: Value(transaction.title),
        subtitle: Value(transaction.subtitle),
        note: Value(transaction.note),
        aiConfirmed: Value(transaction.aiConfirmed),
      ),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await _db.into(_db.budgets).insert(
          BudgetRow(
            id: budget.id,
            categoryId: budget.categoryId,
            limitMinor: budget.limitAmount.cents,
            spentMinor: budget.spentAmount.cents,
            period: budget.period.name,
            month: budget.month,
            year: budget.year,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> updateSalaryProfile(SalaryProfile profile) async {
    await _db.into(_db.salaryProfiles).insert(
          SalaryProfileRow(
            id: profile.id,
            monthlyGrossMinor: profile.monthlyGross.cents,
            monthlyNetMinor: profile.monthlyNet.cents,
            payDayOfMonth: profile.payDayOfMonth,
            employerName: profile.employerName,
            taxWithheldMinor: profile.taxWithheld.cents,
            deductionsMinor: profile.deductions.cents,
            savingsGoalMonthlyMinor: profile.savingsGoalMonthly.cents,
            nextPayDate: profile.nextPayDate,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> dismissInsight(String id) async {
    await (_db.update(_db.insights)..where((i) => i.id.equals(id))).write(
      const InsightsCompanion(isDismissed: Value(true)),
    );
  }

  // ---------------------------------------------------------------------------
  // Mockup Seed Data
  // ---------------------------------------------------------------------------

  @override
  Future<void> seedMockupData() async {
    if (_seedFuture != null) {
      return _seedFuture!;
    }
    final completer = Completer<void>();
    _seedFuture = completer.future;

    try {
      final setting = await (_db.select(_db.appSettings)..where((s) => s.key.equals('seeded_mockup_v1'))).getSingleOrNull();
      if (setting != null) {
        if (!completer.isCompleted) completer.complete();
        return;
      }

    await _db.transaction(() async {
      // 1. Accounts
      for (final a in MockupSeedData.accounts) {
        await _db.into(_db.accounts).insert(
              AccountRow(
                id: a.id,
                name: a.name,
                type: a.type.name,
                balanceMinor: a.balance.cents,
                lastFour: a.lastFour,
                institution: a.institution,
                isDefault: a.isDefault,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      // 2. Categories
      for (final c in MockupSeedData.categories) {
        await _db.into(_db.categories).insert(
              CategoryRow(
                id: c.id,
                name: c.name,
                iconKey: c.iconKey,
                colorHex: c.colorHex,
                budgetMonthlyMinor: c.budgetMonthly?.cents,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      // 3. Merchants
      for (final m in MockupSeedData.merchants) {
        await _db.into(_db.merchants).insert(
              MerchantRow(
                id: m.id,
                name: m.name,
                category: m.category,
                visitCount: m.visitCount,
                totalSpentMinor: m.totalSpent.cents,
                iconKey: m.iconKey,
                address: m.address,
                phone: m.phone,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      // 4. Transactions
      for (final t in MockupSeedData.transactions) {
        await _db.into(_db.transactions).insert(
              TransactionRow(
                id: t.id,
                accountId: t.accountId,
                categoryId: t.categoryId,
                merchantId: t.merchantId,
                amountMinor: t.amount.cents,
                timestamp: t.timestamp,
                title: t.title,
                subtitle: t.subtitle,
                note: t.note,
                aiSuggestedCategory: t.aiSuggestedCategory,
                aiConfirmed: t.aiConfirmed,
                cardLastFour: t.cardLastFour,
                hasReceipt: t.hasReceipt,
                type: t.type.name,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      // 5. Receipts & Items
      final rcpt = MockupSeedData.wholeFoodsReceipt;
      await _db.into(_db.receipts).insert(
            ReceiptRow(
              id: rcpt.id,
              transactionId: rcpt.transactionId,
              merchantName: rcpt.merchantName,
              timestamp: rcpt.timestamp,
              subtotalMinor: rcpt.subtotal.cents,
              taxMinor: rcpt.tax.cents,
              totalMinor: rcpt.total.cents,
              rawOcrText: rcpt.rawOcrText,
              imageUrl: rcpt.imageUrl,
            ),
            mode: InsertMode.insertOrReplace,
          );

      for (final item in rcpt.items) {
        await _db.into(_db.receiptItems).insert(
              ReceiptItemRow(
                id: item.id,
                receiptId: item.receiptId,
                name: item.name,
                quantity: item.quantity,
                priceMinor: item.price.cents,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      // 6. Budgets
      for (final b in MockupSeedData.budgets) {
        await _db.into(_db.budgets).insert(
              BudgetRow(
                id: b.id,
                categoryId: b.categoryId,
                limitMinor: b.limitAmount.cents,
                spentMinor: b.spentAmount.cents,
                period: b.period.name,
                month: b.month,
                year: b.year,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      // 7. Salary Profile
      final sp = MockupSeedData.salaryProfile;
      await _db.into(_db.salaryProfiles).insert(
            SalaryProfileRow(
              id: sp.id,
              monthlyGrossMinor: sp.monthlyGross.cents,
              monthlyNetMinor: sp.monthlyNet.cents,
              payDayOfMonth: sp.payDayOfMonth,
              employerName: sp.employerName,
              taxWithheldMinor: sp.taxWithheld.cents,
              deductionsMinor: sp.deductions.cents,
              savingsGoalMonthlyMinor: sp.savingsGoalMonthly.cents,
              nextPayDate: sp.nextPayDate,
            ),
            mode: InsertMode.insertOrReplace,
          );

      // 8. Insights
      for (final ins in MockupSeedData.insights) {
        await _db.into(_db.insights).insert(
              InsightRow(
                id: ins.id,
                title: ins.title,
                description: ins.description,
                type: ins.type.name,
                impactAmountMinor: ins.impactAmount?.cents,
                categoryId: ins.categoryId,
                actionLabel: ins.actionLabel,
                routePath: ins.routePath,
                createdAt: ins.createdAt,
                isDismissed: ins.isDismissed,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      // Mark seeded
      await _db.into(_db.appSettings).insert(
            const AppSettingRow(key: 'seeded_mockup_v1', value: 'true'),
            mode: InsertMode.insertOrReplace,
          );
    });
    if (!completer.isCompleted) completer.complete();
    } catch (e, st) {
      if (!completer.isCompleted) completer.completeError(e, st);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  Account _mapAccount(AccountRow row) {
    AccountType type;
    switch (row.type) {
      case 'savings':
        type = AccountType.savings;
        break;
      case 'creditCard':
        type = AccountType.creditCard;
        break;
      case 'investment':
        type = AccountType.investment;
        break;
      case 'checking':
      default:
        type = AccountType.checking;
    }
    return Account(
      id: row.id,
      name: row.name,
      type: type,
      balance: Money(row.balanceMinor),
      lastFour: row.lastFour,
      institution: row.institution,
      isDefault: row.isDefault,
    );
  }

  Category _mapCategory(CategoryRow row) {
    return Category(
      id: row.id,
      name: row.name,
      iconKey: row.iconKey,
      colorHex: row.colorHex,
      budgetMonthly: row.budgetMonthlyMinor == null ? null : Money(row.budgetMonthlyMinor!),
      parentCategoryId: row.parentCategoryId,
    );
  }

  Merchant _mapMerchant(MerchantRow row) {
    return Merchant(
      id: row.id,
      name: row.name,
      category: row.category,
      visitCount: row.visitCount,
      totalSpent: Money(row.totalSpentMinor),
      iconKey: row.iconKey,
      address: row.address,
      phone: row.phone,
    );
  }

  domain_txn.Transaction _mapTransaction(TransactionRow row) {
    domain_txn.TransactionType type;
    switch (row.type) {
      case 'income':
        type = domain_txn.TransactionType.income;
        break;
      case 'transfer':
        type = domain_txn.TransactionType.transfer;
        break;
      case 'expense':
      default:
        type = domain_txn.TransactionType.expense;
    }
    return domain_txn.Transaction(
      id: row.id,
      accountId: row.accountId,
      categoryId: row.categoryId,
      merchantId: row.merchantId,
      amount: Money(row.amountMinor),
      timestamp: row.timestamp,
      title: row.title,
      subtitle: row.subtitle,
      note: row.note,
      aiSuggestedCategory: row.aiSuggestedCategory,
      aiConfirmed: row.aiConfirmed,
      cardLastFour: row.cardLastFour,
      hasReceipt: row.hasReceipt,
      type: type,
    );
  }

  Receipt _mapReceipt(ReceiptRow row, List<ReceiptItemRow> items) {
    return Receipt(
      id: row.id,
      transactionId: row.transactionId,
      merchantName: row.merchantName,
      timestamp: row.timestamp,
      items: items.map((i) {
        return ReceiptLineItem(
          id: i.id,
          receiptId: i.receiptId,
          name: i.name,
          quantity: i.quantity,
          price: Money(i.priceMinor),
        );
      }).toList(),
      subtotal: Money(row.subtotalMinor),
      tax: Money(row.taxMinor),
      total: Money(row.totalMinor),
      rawOcrText: row.rawOcrText,
      imageUrl: row.imageUrl,
    );
  }

  Budget _mapBudget(BudgetRow row) {
    BudgetPeriod period;
    switch (row.period) {
      case 'weekly':
        period = BudgetPeriod.weekly;
        break;
      case 'yearly':
        period = BudgetPeriod.yearly;
        break;
      case 'monthly':
      default:
        period = BudgetPeriod.monthly;
    }
    return Budget(
      id: row.id,
      categoryId: row.categoryId,
      limitAmount: Money(row.limitMinor),
      spentAmount: Money(row.spentMinor),
      period: period,
      month: row.month,
      year: row.year,
    );
  }

  SalaryProfile _mapSalaryProfile(SalaryProfileRow row) {
    return SalaryProfile(
      id: row.id,
      monthlyGross: Money(row.monthlyGrossMinor),
      monthlyNet: Money(row.monthlyNetMinor),
      payDayOfMonth: row.payDayOfMonth,
      employerName: row.employerName,
      taxWithheld: Money(row.taxWithheldMinor),
      deductions: Money(row.deductionsMinor),
      savingsGoalMonthly: Money(row.savingsGoalMonthlyMinor),
      nextPayDate: row.nextPayDate,
    );
  }

  AiInsight _mapInsight(InsightRow row) {
    AiInsightType type;
    switch (row.type) {
      case 'savingFound':
        type = AiInsightType.savingFound;
        break;
      case 'spendingVelocity':
        type = AiInsightType.spendingVelocity;
        break;
      case 'recurringSubscription':
        type = AiInsightType.recurringSubscription;
        break;
      case 'overrunWarning':
      default:
        type = AiInsightType.overrunWarning;
    }
    return AiInsight(
      id: row.id,
      title: row.title,
      description: row.description,
      type: type,
      impactAmount: row.impactAmountMinor == null ? null : Money(row.impactAmountMinor!),
      categoryId: row.categoryId,
      actionLabel: row.actionLabel,
      routePath: row.routePath,
      createdAt: row.createdAt,
      isDismissed: row.isDismissed,
    );
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final setting = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals('onboarding_completed')))
        .getSingleOrNull();
    return setting?.value == 'true';
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _db.into(_db.appSettings).insert(
          AppSettingRow(
            key: 'onboarding_completed',
            value: completed ? 'true' : 'false',
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<String> getAppSetting(String key, {String defaultValue = ''}) async {
    final setting = await (_db.select(_db.appSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return setting?.value ?? defaultValue;
  }

  @override
  Future<void> setAppSetting(String key, String value) async {
    await _db.into(_db.appSettings).insert(
          AppSettingRow(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> seedInitialFreshData(SalaryProfile profile) async {
    await _db.transaction(() async {
      await updateSalaryProfile(profile);

      // Default primary accounts with 0 balance
      await _db.into(_db.accounts).insert(
            const AccountRow(
              id: 'acc_primary_checking',
              name: 'Primary Checking',
              type: 'checking',
              balanceMinor: 0,
              lastFour: '0000',
              institution: 'Cash / Bank',
              isDefault: true,
            ),
            mode: InsertMode.insertOrReplace,
          );

      // Standard budget categories
      for (final c in MockupSeedData.categories) {
        await _db.into(_db.categories).insert(
              CategoryRow(
                id: c.id,
                name: c.name,
                iconKey: c.iconKey,
                colorHex: c.colorHex,
                budgetMonthlyMinor: c.budgetMonthly?.cents,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      await setOnboardingCompleted(true);
    });
  }

  @override
  Future<String> exportDatabaseToCsv() async {
    final txns = await (_db.select(_db.transactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
          ]))
        .get();
    final categories = await _db.select(_db.categories).get();
    final accounts = await _db.select(_db.accounts).get();
    final categoryMap = {for (final c in categories) c.id: c.name};
    final accountMap = {for (final a in accounts) a.id: a.name};

    final buffer = StringBuffer();
    buffer.writeln('ID,Date,Time,Title,Category,Account,Type,Amount_Cents,Amount_USD,Note');
    for (final t in txns) {
      final iso = t.timestamp.toIso8601String();
      final dateStr = iso.split('T').first;
      final timeStr = iso.contains('T') ? iso.split('T').last.substring(0, 5) : '00:00';
      final catName = categoryMap[t.categoryId] ?? t.categoryId;
      final accName = accountMap[t.accountId] ?? t.accountId;
      final amountUsd = (t.amountMinor / 100.0).toStringAsFixed(2);
      final cleanTitle = t.title.replaceAll('"', '""');
      final cleanNote = (t.note ?? '').replaceAll('"', '""');
      buffer.writeln('${t.id},$dateStr,$timeStr,"$cleanTitle","$catName","$accName",${t.type},${t.amountMinor},$amountUsd,"$cleanNote"');
    }
    return buffer.toString();
  }
}

