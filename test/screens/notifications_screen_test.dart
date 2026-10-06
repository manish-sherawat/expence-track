import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/app/router.dart';
import 'package:salary_tracker/ui/screens/notifications/notifications_screen.dart';

void main() {
  group('NotificationsScreen Widget Tests', () {
    setUp(() {
      appRouter.go('/notifications');
    });

    testWidgets('Renders all NotificationsScreen elements and alert cards',
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

      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Income Deposit Confirmed'), findsOneWidget);
      expect(find.text('Dining Budget Warning'), findsOneWidget);
      expect(find.text('AI Savings Detected'), findsOneWidget);
      expect(find.text('Mark All Read'), findsOneWidget);
    });

    testWidgets('Filtering by Budget displays only budget alerts',
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

      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Dining Budget Warning'), findsOneWidget);
      expect(find.text('Income Deposit Confirmed'), findsNothing);
    });

    testWidgets('Tapping Mark All Read marks all as read and updates header',
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

      await tester.tap(find.text('Mark All Read'));
      await tester.pumpAndSettle();

      expect(find.text('0 unread alerts'), findsOneWidget);
      expect(find.text('Mark All Read'), findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });
  });
}
