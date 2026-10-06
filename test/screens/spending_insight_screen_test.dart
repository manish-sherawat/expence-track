import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/app/router.dart';
import 'package:salary_tracker/design_system/components/components.dart';
import 'package:salary_tracker/ui/screens/spending_insight/widgets/budget_edit_bottom_sheet.dart';
import 'package:salary_tracker/ui/screens/spending_insight/widgets/budget_vs_actual_card.dart';
import 'package:salary_tracker/ui/screens/spending_insight/widgets/spending_header.dart';
import 'package:salary_tracker/ui/screens/spending_insight/widgets/spending_trend_card.dart';
import 'package:salary_tracker/ui/screens/spending_insight/widgets/stat_cards_grid.dart';

void main() {
  group('SpendingInsightScreen (Screen 3) Widget Tests', () {
    setUp(() {
      appRouter.go('/insight');
    });

    testWidgets('Renders all Screen 3 elements with exact mockup values',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1800);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header (Title, Month Dropdown Pill, Segmented Control)
      expect(find.byType(SpendingHeader), findsOneWidget);
      expect(find.text('Spending Insights'), findsOneWidget);
      expect(find.text('April 2026'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);

      // 2. 2x2 Stat Cards
      expect(find.byType(StatCardsGrid), findsOneWidget);
      expect(find.text('Total Spent'), findsOneWidget);
      expect(find.textContaining('3,218'), findsWidgets);
      expect(find.text('Daily Average'), findsOneWidget);
      expect(find.textContaining('107'), findsWidgets);
      expect(find.text('Biggest Category'), findsOneWidget);
      expect(find.text('Rent (37%)'), findsOneWidget);
      expect(find.text('AI Saving Found'), findsOneWidget);
      expect(find.textContaining('184'), findsWidgets);

      // 3. Spending Trend Card with AreaLineChart
      expect(find.byType(SpendingTrendCard), findsOneWidget);
      expect(find.text('Spending Trend'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.byType(AreaLineChart), findsOneWidget);

      // 4. Budget vs Actual Card
      expect(find.byType(BudgetVsActualCard), findsOneWidget);
      expect(find.text('Budget vs Actual'), findsOneWidget);
      expect(find.text('Edit Budgets'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Rent'), findsWidgets);
      expect(find.text('Over'), findsNWidgets(2)); // Food & Shopping
      expect(find.text('Under'), findsNWidgets(2)); // Transport & Rent
    });

    testWidgets('Tapping SegmentedControl switches timeframe selection',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1800);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      final weekFinder = find.text('Week');
      expect(weekFinder, findsOneWidget);

      await tester.tap(weekFinder);
      await tester.pumpAndSettle();

      final yearFinder = find.text('Year');
      expect(yearFinder, findsOneWidget);

      await tester.tap(yearFinder);
      await tester.pumpAndSettle();
    });

    testWidgets('Tapping Metric dropdown pill switches to Income and updates chart',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1800);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      final metricDropdown = find.text('Expenses');
      expect(metricDropdown, findsOneWidget);

      // 1. Open dropdown
      await tester.tap(metricDropdown);
      await tester.pumpAndSettle();

      // 2. Select 'Income' option in overlay
      expect(find.text('Income'), findsOneWidget);
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      // 3. Dropdown pill now displays Income
      expect(find.text('Income'), findsOneWidget);

      // 4. Open dropdown again and switch back to Expenses
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Expenses').last);
      await tester.pumpAndSettle();

      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('Tapping Edit Budgets opens BudgetEditBottomSheet and saves',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1800);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      final editButton = find.text('Edit Budgets');
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Bottom sheet is now displayed
      expect(find.byType(BudgetEditBottomSheet), findsOneWidget);
      expect(find.text('Edit Monthly Budgets'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      // Save changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.byType(BudgetEditBottomSheet), findsNothing);
    });
  });
}
