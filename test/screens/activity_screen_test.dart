import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/app/router.dart';
import 'package:salary_tracker/ui/screens/activity/activity_screen.dart';
import 'package:salary_tracker/ui/screens/activity/widgets/glass_payment_card.dart';

void main() {
  group('ActivityScreen (Screen 4) Widget Tests', () {
    setUp(() {
      appRouter.go('/activity');
    });

    testWidgets('Renders all ActivityScreen elements and payment cards',
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

      expect(find.byType(ActivityScreen), findsOneWidget);
      expect(find.text('Cards & Activity'), findsOneWidget);
      expect(find.text('PAYMENT CARDS'), findsOneWidget);
      expect(find.byType(GlassPaymentCard), findsNWidgets(2));
      expect(find.text('Primary Checking'), findsOneWidget);
      expect(find.text('High Yield Savings'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
    });

    testWidgets('Tapping payment card filters transactions and clear button resets',
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

      // Tap on Primary Checking card
      await tester.tap(find.text('Primary Checking'));
      await tester.pumpAndSettle();

      expect(find.text('Clear filter'), findsOneWidget);
      expect(find.text('Filtered by Card'), findsOneWidget);

      // Tap Clear filter
      await tester.tap(find.text('Clear filter'));
      await tester.pumpAndSettle();

      expect(find.text('Clear filter'), findsNothing);
    });

    testWidgets('Switching filter to Receipts displays receipt transactions',
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

      await tester.tap(find.text('Receipts'));
      await tester.pumpAndSettle();

      expect(find.text('Whole Foods Market'), findsWidgets);
    });

    testWidgets('Export button triggers export confirmation toast',
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

      await tester.tap(find.text('Export'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Exported'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });
}
