import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/app/router.dart';
import 'package:salary_tracker/design_system/components/components.dart';

void main() {
  group('HomeScreen (Screen 1) Widget Tests', () {
    setUp(() {
      appRouter.go('/');
    });
    testWidgets('Renders all Screen 1 elements with exact mockup values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Greeting & Profile
      expect(find.text('Welcome Back,'), findsOneWidget);
      expect(find.text('Jacob Simmons'), findsOneWidget);

      // 2. Action buttons (Search & Bell)
      expect(find.byType(CircleIconButton), findsNWidgets(2));

      // 3. Total Balance Card & Sub-stats
      expect(find.text('TOTAL BALANCE'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);

      // 4. AI Insight Banner
      expect(find.byType(InsightBanner), findsOneWidget);
      expect(
        find.textContaining('You may exceed dining budget'),
        findsOneWidget,
      );

      // 5. Category Carousel
      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Transport'), findsWidgets);

      // 6. Recent Transactions
      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Whole Foods Market'), findsWidgets);
      expect(find.text('Uber Trip'), findsOneWidget);

      // 7. Floating FrostedNavBar
      expect(find.byType(FrostedNavBar), findsOneWidget);
    });

    testWidgets('Tapping on a transaction navigates to detail route',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1600);
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

      final wholeFoodsFinder = find.text('Whole Foods Market').first;
      expect(wholeFoodsFinder, findsOneWidget);

      await tester.tap(wholeFoodsFinder);
      await tester.pumpAndSettle();

      // Verifies navigation to transaction detail route
      expect(find.text('Transaction Detail'), findsOneWidget);
    });

    testWidgets('Tapping on AI Insight banner navigates to /insight route',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      final bannerFinder = find.byType(InsightBanner);
      expect(bannerFinder, findsOneWidget);

      await tester.tap(bannerFinder);
      await tester.pumpAndSettle();

      expect(find.text('Spending Insights'), findsOneWidget);
    });
  });
}
