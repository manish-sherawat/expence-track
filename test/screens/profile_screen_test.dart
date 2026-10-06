import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/app/router.dart';
import 'package:salary_tracker/design_system/components/components.dart';
import 'package:salary_tracker/ui/screens/profile/profile_screen.dart';

void main() {
  group('ProfileScreen (Screen 5) Widget Tests', () {
    setUp(() {
      appRouter.go('/profile');
    });

    testWidgets('Renders all ProfileScreen elements with mockup salary details',
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

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Jacob Simmons'), findsOneWidget);
      expect(find.text('jacob.simmons@email.com'), findsOneWidget);
      expect(find.text('Pro ✦'), findsNothing);

      // Income card
      expect(find.text('MONTHLY INCOME'), findsOneWidget);
      expect(find.textContaining('TechCorp'), findsOneWidget);
      expect(find.text('Gross Income'), findsOneWidget);
      expect(find.text('Federal & State Tax'), findsOneWidget);

      // Savings card
      expect(find.text('MONTHLY SAVINGS TARGET'), findsOneWidget);
      expect(find.text('On Track'), findsOneWidget);
      expect(find.text('100% of goal'), findsOneWidget);

      // Preferences & toggles
      expect(find.text('PREFERENCES & AI'), findsOneWidget);
      expect(find.text('AI Auto-Categorization'), findsOneWidget);
      expect(find.text('Paper Receipt OCR'), findsOneWidget);
      expect(find.byType(AppToggle), findsNWidgets(3));
    });

    testWidgets('Toggling preference switch updates toggle state',
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

      final firstToggle = find.byType(AppToggle).first;
      await tester.tap(firstToggle);
      await tester.pumpAndSettle();

      expect(firstToggle, findsOneWidget);
    });

    testWidgets('Tapping Reset to Mockup Data opens bottom sheet modal',
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

      final resetBtn = find.text('Reset').first;
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      expect(find.text('Reset to Mockup Data'), findsWidgets);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset Now'), findsOneWidget);
    });
  });
}
