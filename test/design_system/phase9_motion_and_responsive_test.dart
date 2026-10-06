import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/design_system/components/glass_surface.dart';
import 'package:salary_tracker/design_system/tokens/tokens.dart';

void main() {
  group('Phase 9: Motion, Accessibility, Themes & Responsive Web Tests', () {
    testWidgets('Switching themeModeProvider to dark activates dark theme tokens',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
          ],
          child: const AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Jacob Simmons'));
      final theme = AppTheme.of(context);

      expect(theme.colors.isDark, isTrue);
      expect(theme.colors.bg, equals(AppColors.dark.bg));
      expect(theme.colors.textPrimary, equals(AppColors.dark.textPrimary));
    });

    testWidgets('Reduced transparency fallback renders solid surface without BackdropFilter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        AppTheme(
          data: AppThemeData.light(reduceTransparency: true),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: GlassSurface(
              child: Text('Test Glass'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Glass'), findsOneWidget);
      // In reduced transparency mode, BackdropFilter is omitted
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('Normal mode renders GlassSurface with BackdropFilter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        AppTheme(
          data: AppThemeData.light(reduceTransparency: false),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: GlassSurface(
              child: Text('Test Glass 2'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Glass 2'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('Responsive web container constrains width on displays > 900px',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1200, 900);
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

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final phoneFrame = constrainedBoxes.firstWhere(
        (box) => box.constraints.maxWidth == 440,
      );
      expect(phoneFrame, isNotNull);
      expect(phoneFrame.constraints.maxWidth, equals(440));
    });

    testWidgets('Text scaling at 1.3x renders without unhandled layout overflow',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1600);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MediaQuery(
            data: MediaQueryData(
              size: Size(800, 1600),
              textScaler: TextScaler.linear(1.3),
            ),
            child: AppApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jacob Simmons'), findsOneWidget);
      expect(find.text('TOTAL BALANCE'), findsOneWidget);
    });
  });
}
