import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/app/router.dart';
import 'package:salary_tracker/data/database/app_database.dart';
import 'package:salary_tracker/providers/finance_providers.dart';

void main() {
  group('FTUE Flow Integration Test', () {
    testWidgets('Full 5-Step First-Time User Experience to Dashboard',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1800);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() async {
        await db.close();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Future<void> pumpTransition() async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));
      }

      appRouter.go('/onboarding');

      // 1. Boot Application at /onboarding
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const AppApp(),
        ),
      );
      await pumpTransition();

      // Step 0: Welcome & Vision
      expect(find.text('Master Your Paycheck'), findsOneWidget);
      expect(find.text('100% Private & On-Device'), findsOneWidget);

      // Tap Get Started -> Step 1
      await tester.tap(find.text('Get Started'));
      await pumpTransition();

      // Step 1: Currency Selection
      expect(find.text('Choose Your Currency'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);

      // Tap EUR
      await tester.tap(find.text('EUR'));
      await pumpTransition();

      // Tap Continue -> Step 2
      await tester.tap(find.text('Continue to Salary Setup →'));
      await pumpTransition();

      // Step 2: Salary & Pay Schedule
      expect(find.text('Your Income & Payday'), findsOneWidget);
      expect(find.text('DAILY SAFE-TO-SPEND ALLOWANCE'), findsOneWidget);

      // Tap Continue -> Step 3
      await tester.tap(find.text('Continue →'));
      await pumpTransition();

      // Step 3: Experience Mode
      expect(find.text('How would you like to start?'), findsOneWidget);
      expect(find.text('Explore with Demo Playground'), findsOneWidget);
      expect(find.text('Start Clean Ledger'), findsOneWidget);

      // Tap Create My Dashboard -> Step 4
      await tester.tap(find.text('Create My Dashboard →'));
      await pumpTransition();

      // Step 4: Celebration & Launch
      expect(find.text("You're All Set!"), findsOneWidget);
      expect(find.text('Enter Dashboard 🚀'), findsOneWidget);

      // Tap Enter Dashboard -> Lands on Home screen
      await tester.tap(find.text('Enter Dashboard 🚀'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('TOTAL BALANCE'), findsOneWidget);

      // Clean up widget tree and flush any stream timers before test exits
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
