import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/data/services/local_ai_service.dart';
import 'package:salary_tracker/data/services/remote_ai_service.dart';
import 'package:salary_tracker/domain/models/ai_insight.dart';
import 'package:salary_tracker/domain/models/budget.dart';
import 'package:salary_tracker/domain/models/category.dart';
import 'package:salary_tracker/domain/models/money.dart';
import 'package:salary_tracker/domain/models/transaction.dart';

void main() {
  group('Phase 8: AI Services & Predictive Intelligence Tests', () {
    const localAi = LocalAiService();

    test('predictBudgetOverrun accurately projects overrun based on velocity', () async {
      // Food budget: $600.00 limit, spent $489.20 on day 15 of April (30 days)
      // Projected: 489.20 / 15 * 30 = $978.40 (exceeds $600 by ~$378)
      const foodCategory = Category(
        id: 'cat_food',
        name: 'Dining',
        iconKey: 'food',
        colorHex: 0xFFFF5C00,
        budgetMonthly: Money(60000),
      );

      const foodBudget = Budget(
        id: 'bgt_food_apr',
        categoryId: 'cat_food',
        limitAmount: Money(60000), // $600.00
        spentAmount: Money(48920), // $489.20
        month: 4,
        year: 2026,
      );

      final insight = await localAi.predictBudgetOverrun(
        budget: foodBudget,
        category: foodCategory,
        asOfDate: DateTime(2026, 4, 15),
      );

      expect(insight, isNotNull);
      expect(insight!.type, equals(AiInsightType.overrunWarning));
      expect(insight.title, contains('Dining Budget Velocity Warning'));
      expect(insight.description, contains('You may exceed dining budget'));
      expect(insight.impactAmount!.cents, greaterThan(30000));
    });

    test('predictBudgetOverrun returns null when spending is well under budget', () async {
      const rentCategory = Category(
        id: 'cat_rent',
        name: 'Rent',
        iconKey: 'rent',
        colorHex: 0xFF5B616E,
        budgetMonthly: Money(120000),
      );

      const rentBudget = Budget(
        id: 'bgt_rent_apr',
        categoryId: 'cat_rent',
        limitAmount: Money(120000), // $1200.00
        spentAmount: Money(60000), // $600.00 on day 20 (rate = 30/day -> 900 < 1200)
        month: 4,
        year: 2026,
      );

      final insight = await localAi.predictBudgetOverrun(
        budget: rentBudget,
        category: rentCategory,
        asOfDate: DateTime(2026, 4, 20),
      );

      expect(insight, isNull);
    });

    test('detectSavingsOpportunities discovers subscription patterns', () async {
      final txns = [
        Transaction(
          id: 'sub_netflix',
          accountId: 'acc_01',
          categoryId: 'cat_shopping',
          amount: const Money(1999),
          timestamp: DateTime(2026, 4, 5),
          title: 'Netflix Subscription',
          subtitle: 'Streaming service',
          type: TransactionType.expense,
        ),
        Transaction(
          id: 'sub_spotify',
          accountId: 'acc_01',
          categoryId: 'cat_shopping',
          amount: const Money(1099),
          timestamp: DateTime(2026, 4, 8),
          title: 'Spotify Premium Membership',
          subtitle: 'Music subscription',
          type: TransactionType.expense,
        ),
        Transaction(
          id: 'sub_gym',
          accountId: 'acc_01',
          categoryId: 'cat_shopping',
          amount: const Money(8500),
          timestamp: DateTime(2026, 4, 1),
          title: 'Equinox Fitness Club',
          subtitle: 'Fitness membership',
          type: TransactionType.expense,
        ),
      ];

      final savings = await localAi.detectSavingsOpportunities(
        transactions: txns,
        categories: const [],
      );

      expect(savings, isNotEmpty);
      final subSaving = savings.firstWhere((s) => s.type == AiInsightType.savingFound);
      expect(subSaving.title, contains('Subscription Optimization'));
      expect(subSaving.impactAmount!.cents, equals(1999 + 1099 + 8500));
    });

    test('generateInsights aggregates both overruns and savings opportunities', () async {
      const foodCategory = Category(
        id: 'cat_food',
        name: 'Dining',
        iconKey: 'food',
        colorHex: 0xFFFF5C00,
        budgetMonthly: Money(60000),
      );

      const foodBudget = Budget(
        id: 'bgt_food',
        categoryId: 'cat_food',
        limitAmount: Money(60000),
        spentAmount: Money(50000),
        month: 4,
        year: 2026,
      );

      final txns = [
        Transaction(
          id: 'sub_1',
          accountId: 'acc_01',
          categoryId: 'cat_shopping',
          amount: const Money(1599),
          timestamp: DateTime(2026, 4, 2),
          title: 'Streaming Subscription',
          subtitle: 'Monthly membership',
          type: TransactionType.expense,
        ),
      ];

      final insights = await localAi.generateInsights(
        budgets: [foodBudget],
        transactions: txns,
        categories: [foodCategory],
        asOfDate: DateTime(2026, 4, 15),
      );

      expect(insights.length, greaterThanOrEqualTo(2));
      expect(insights.any((i) => i.type == AiInsightType.overrunWarning), isTrue);
      expect(insights.any((i) => i.type == AiInsightType.savingFound), isTrue);
    });

    test('RemoteAiService respects userConsent gate and uses fallback when denied', () async {
      const deniedRemote = RemoteAiService(
        userConsent: false,
        fallback: localAi,
      );

      expect(deniedRemote.userConsent, isFalse);

      final category = await deniedRemote.suggestCategoryForMerchant('Whole Foods Market');
      expect(category, equals('Groceries'));

      const allowedRemote = RemoteAiService(
        userConsent: true,
        fallback: localAi,
      );
      expect(allowedRemote.userConsent, isTrue);

      final allowedCategory = await allowedRemote.suggestCategoryForMerchant('Starbucks Coffee');
      expect(allowedCategory, equals('Dining'));
    });
  });
}
