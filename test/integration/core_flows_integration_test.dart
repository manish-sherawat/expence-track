import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/app/router.dart';
import 'package:salary_tracker/design_system/components/app_icon.dart';
import 'package:salary_tracker/design_system/components/circle_icon_button.dart';
import 'package:salary_tracker/design_system/components/frosted_nav_bar.dart';

void main() {
  group('Core Flows Integration Test', () {
    setUp(() {
      appRouter.go('/');
    });

    testWidgets('Full End-to-End User Flow across All Screens and Tabs',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1800);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Boot Application
      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Home Screen Content
      expect(find.text('Jacob Simmons'), findsOneWidget);
      expect(find.text('TOTAL BALANCE'), findsOneWidget);
      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.text('Whole Foods Market'), findsWidgets);

      // 2. Navigation Flow: Tap Transaction -> Detail Screen
      final firstTransaction = find.text('Whole Foods Market').first;
      await tester.tap(firstTransaction);
      await tester.pumpAndSettle();

      // Verify Transaction Detail Screen
      expect(find.text('Transaction Detail'), findsOneWidget);
      expect(find.text('Whole Foods Market'), findsWidgets);
      expect(find.text('AI Receipt Scan'), findsOneWidget);
      expect(find.text('4 Items • Verified'), findsOneWidget);

      // Tap Back button on Transaction Detail Screen
      final backButton = find.byType(CircleIconButton).first;
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Return to Home Screen
      expect(find.text('Jacob Simmons'), findsOneWidget);
      expect(find.text('TOTAL BALANCE'), findsOneWidget);

      // 3. Navigation Flow: Tap "See all" on Spending by Category
      final seeAllCategories = find.text('See all').first;
      await tester.tap(seeAllCategories);
      await tester.pumpAndSettle();

      // Verify Categories List Screen
      expect(find.text('All Categories'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);

      // Tap Back to Home
      final categoriesBackButton = find.byType(CircleIconButton).first;
      await tester.tap(categoriesBackButton);
      await tester.pumpAndSettle();

      // 4. Tab Navigation Flow: FrostedNavBar tabs
      final navBar = find.byType(FrostedNavBar);
      expect(navBar, findsOneWidget);

      // Tap Insight Tab (chart icon in nav bar)
      final chartIcon = find.descendant(
        of: navBar,
        matching: find.byWidgetPredicate(
          (widget) => widget is AppIcon && widget.type == AppIconType.chart,
        ),
      );
      expect(chartIcon, findsOneWidget);
      await tester.tap(chartIcon);
      await tester.pumpAndSettle();

      // Verify Spending Insight Screen
      expect(find.text('Spending Insights'), findsOneWidget);
      expect(find.text('Total Spent'), findsOneWidget);
      expect(find.text('Daily Average'), findsOneWidget);
      expect(find.text('Spending Trend'), findsOneWidget);
      expect(find.text('Budget vs Actual'), findsOneWidget);

      // Tap Activity / Cards Tab (receipt icon in nav bar)
      final receiptIcon = find.descendant(
        of: navBar,
        matching: find.byWidgetPredicate(
          (widget) => widget is AppIcon && widget.type == AppIconType.receipt,
        ),
      );
      expect(receiptIcon, findsOneWidget);
      await tester.tap(receiptIcon);
      await tester.pumpAndSettle();

      // Verify Activity / Cards Screen
      expect(find.text('Cards & Activity'), findsOneWidget);
      expect(find.text('PAYMENT CARDS'), findsOneWidget);
      expect(find.text('Primary Checking'), findsOneWidget);
      expect(find.text('High Yield Savings'), findsOneWidget);

      // Tap Profile Tab (user icon in nav bar)
      final userIcon = find.descendant(
        of: navBar,
        matching: find.byWidgetPredicate(
          (widget) => widget is AppIcon && widget.type == AppIconType.user,
        ),
      );
      expect(userIcon, findsOneWidget);
      await tester.tap(userIcon);
      await tester.pumpAndSettle();

      // Verify Profile Screen
      expect(find.text('Jacob Simmons'), findsOneWidget);
      expect(find.text('MONTHLY INCOME'), findsOneWidget);
      expect(find.text('PREFERENCES & AI'), findsOneWidget);

      // Return to Home Tab (home icon in nav bar)
      final homeIcon = find.descendant(
        of: navBar,
        matching: find.byWidgetPredicate(
          (widget) => widget is AppIcon && widget.type == AppIconType.home,
        ),
      );
      expect(homeIcon, findsOneWidget);
      await tester.tap(homeIcon);
      await tester.pumpAndSettle();
      expect(find.text('Jacob Simmons'), findsOneWidget);

      // 5. Add Transaction Flow:
      // Navigate to Add Transaction (+ button in navbar)
      final plusIcon = find.descendant(
        of: navBar,
        matching: find.byWidgetPredicate(
          (widget) => widget is AppIcon && widget.type == AppIconType.plus,
        ),
      );
      expect(plusIcon, findsOneWidget);
      await tester.tap(plusIcon);
      await tester.pumpAndSettle();

      // Verify Add Transaction Screen
      expect(find.text('New Transaction'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Auto-fill via AI Receipt Scan
      final scanButton = find.text('Scan');
      expect(scanButton, findsOneWidget);
      await tester.tap(scanButton);
      await tester.pumpAndSettle();

      final confirmButton = find.text('Confirm & Use');
      if (confirmButton.evaluate().isNotEmpty) {
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();
      }

      expect(find.text('Receipt Attached (4 items)'), findsOneWidget);

      // Tap close button to return to Home screen
      final closeButton = find.byType(CircleIconButton).first;
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Successfully back on Home screen with Jacob Simmons visible
      expect(find.text('Jacob Simmons'), findsOneWidget);
      expect(find.text('TOTAL BALANCE'), findsOneWidget);
    });
  });
}
