import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:salary_tracker/data/database/app_database.dart';
import 'package:salary_tracker/data/repositories/finance_repository.dart';
import 'package:salary_tracker/domain/models/money.dart';
import 'package:salary_tracker/domain/models/salary_profile.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FinanceRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('onboarding defaults to false then updates to true', () async {
    expect(await repo.isOnboardingCompleted(), isFalse);
    await repo.setOnboardingCompleted(true);
    expect(await repo.isOnboardingCompleted(), isTrue);
  });

  test('getAppSetting and setAppSetting persist arbitrary key values', () async {
    expect(await repo.getAppSetting('app_currency_symbol', defaultValue: '\$'), '\$');
    await repo.setAppSetting('app_currency_symbol', '€');
    expect(await repo.getAppSetting('app_currency_symbol'), '€');
  });

  test('seedInitialFreshData creates default accounts and categories with zero transactions', () async {
    const profile = SalaryProfile(
      id: 'default_salary',
      monthlyGross: Money(600000),
      monthlyNet: Money(500000),
      payDayOfMonth: 25,
      employerName: 'Acme Corp',
    );
    await repo.seedInitialFreshData(profile);
    
    final accounts = await repo.watchAccounts().first;
    expect(accounts, isNotEmpty);
    
    final txns = await repo.watchRecentTransactions().first;
    expect(txns, isEmpty);
  });
}
