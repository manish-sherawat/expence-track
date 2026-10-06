import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/app/router.dart';
import 'package:salary_tracker/ui/screens/see_all/categories_list_screen.dart';
import 'package:salary_tracker/ui/screens/see_all/transactions_list_screen.dart';

void main() {
  group('See All Screens Widget Tests', () {
    testWidgets('CategoriesListScreen renders all categories and budgets',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1600);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appRouter.go('/categories');
      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesListScreen), findsOneWidget);
      expect(find.text('All Categories'), findsOneWidget);
      expect(find.text('TOTAL MONTHLY EXPENSES'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('TransactionsListScreen renders and switches filters',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1600);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appRouter.go('/transactions');
      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TransactionsListScreen), findsOneWidget);
      expect(find.text('All Transactions'), findsOneWidget);
      expect(find.text('Whole Foods Market'), findsWidgets);

      // Switch to Expenses
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();
      expect(find.text('Uber Trip'), findsOneWidget);

      // Switch to Income
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();
      expect(find.text('Whole Foods Market'), findsNothing);
      expect(find.textContaining('TechCorp'), findsWidgets);
    });
  });
}
