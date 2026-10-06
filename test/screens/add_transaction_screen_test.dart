import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/app/router.dart';
import 'package:salary_tracker/design_system/components/components.dart';
import 'package:salary_tracker/ui/screens/add_transaction/add_transaction_screen.dart';

void main() {
  group('AddTransactionScreen Widget Tests', () {
    setUp(() {
      appRouter.go('/add-transaction');
    });

    testWidgets('Renders all AddTransactionScreen elements',
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

      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(find.text('New Transaction'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.byType(AmountKeypad), findsOneWidget);
      expect(find.text('Merchant / Description'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Payment Account'), findsOneWidget);
      expect(find.text('Attach Receipt'), findsOneWidget);
    });

    testWidgets('Keypad typing updates amount display and Expense/Income toggle works',
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

      // Tap '5', '0' on keypad
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      expect(find.textContaining('50'), findsWidgets);

      // Switch to Income
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();
      expect(find.text('AMOUNT RECEIVED'), findsOneWidget);
    });

    testWidgets('Scan receipt auto-fills merchant and amount',
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

      final scanButton = find.text('Scan');
      expect(scanButton, findsOneWidget);

      await tester.tap(scanButton);
      await tester.pumpAndSettle();

      final confirmButton = find.text('Confirm & Use');
      if (confirmButton.evaluate().isNotEmpty) {
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();
      }

      // Verifies receipt scan populated fields
      expect(
        find.byWidgetPredicate((w) =>
            w is EditableText &&
            w.controller.text.contains('Whole Foods')),
        findsOneWidget,
      );
      expect(find.text('Receipt Attached (4 items)'), findsOneWidget);
      expect(find.text('Rescan'), findsOneWidget);
    });

    testWidgets('Tapping close button navigates back to previous screen',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1800);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appRouter.go('/');
      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      unawaited(appRouter.push('/add-transaction'));
      await tester.pumpAndSettle();

      expect(find.byType(AddTransactionScreen), findsOneWidget);

      // Tap close button
      await tester.tap(find.byType(CircleIconButton).first);
      await tester.pumpAndSettle();

      // Should have navigated back to home
      expect(find.byType(AddTransactionScreen), findsNothing);
    });
  });
}
