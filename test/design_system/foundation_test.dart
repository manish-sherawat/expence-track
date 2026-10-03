import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/design_system/components/components.dart';
import 'package:salary_tracker/design_system/tokens/tokens.dart';

Widget _wrap(Widget child, {AppThemeData? theme}) {
  return AppTheme(
    data: theme ?? AppThemeData.light(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    ),
  );
}

void main() {
  group('Pressable Component Tests', () {
    testWidgets('Pressable triggers onPressed callback', (tester) async {
      int tapCount = 0;
      await tester.pumpWidget(
        _wrap(
          Pressable(
            onPressed: () => tapCount++,
            child: const Text('Tap me'),
          ),
        ),
      );

      expect(find.text('Tap me'), findsOneWidget);
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      expect(tapCount, equals(1));
    });

    testWidgets('Disabled Pressable does not trigger onPressed', (tester) async {
      int tapCount = 0;
      await tester.pumpWidget(
        _wrap(
          Pressable(
            enabled: false,
            onPressed: () => tapCount++,
            child: const Text('Disabled'),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      expect(tapCount, equals(0));
    });
  });

  group('AmountText Component Tests', () {
    testWidgets('AmountText formats whole dollars and cents properly', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AmountText(amountMinor: 1289290), // $12,892.90
        ),
      );

      expect(find.text(r'$12,892.90', findRichText: true), findsOneWidget);
    });

    testWidgets('AmountText formats signed positive and negative amounts', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: [
              AmountText(
                amountMinor: 842900,
                signStyle: AmountSignStyle.signedWithColor,
              ),
              AmountText(
                amountMinor: -321800,
                signStyle: AmountSignStyle.signedWithColor,
              ),
            ],
          ),
        ),
      );

      expect(find.text(r'+$8,429.00', findRichText: true), findsOneWidget);
      expect(find.text(r'-$3,218.00', findRichText: true), findsOneWidget);
    });
  });

  group('GlassSurface Component Tests', () {
    testWidgets('GlassSurface renders BackdropFilter when transparency is allowed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const GlassSurface(
            child: Text('Glass Content'),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.text('Glass Content'), findsOneWidget);
    });

    testWidgets('GlassSurface falls back to solid container when reduceTransparency is enabled', (tester) async {
      final themeWithReducedTransparency = AppThemeData.light(reduceTransparency: true);

      await tester.pumpWidget(
        _wrap(
          const GlassSurface(
            child: Text('Solid Fallback'),
          ),
          theme: themeWithReducedTransparency,
        ),
      );

      // BackdropFilter must be bypassed for accessibility/performance
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('Solid Fallback'), findsOneWidget);
    });
  });

  group('TagChip & StatusPill Tests', () {
    testWidgets('TagChip renders AI sparkle and handles tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          TagChip.ai(
            label: 'Food',
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Food'), findsOneWidget);
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('StatusPill renders Over and Under labels', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              StatusPill.over(),
              StatusPill.under(),
            ],
          ),
        ),
      );

      expect(find.text('Over'), findsOneWidget);
      expect(find.text('Under'), findsOneWidget);
    });
  });

  group('CircleIconButton & AppButton Tests', () {
    testWidgets('CircleIconButton has 44x44 touch target and handles badge', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          Center(
            child: CircleIconButton(
              icon: AppIconType.bell,
              hasBadge: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(CircleIconButton));
      expect(size.width, equals(44.0));
      expect(size.height, equals(44.0));

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('AppButton handles tap and loading state', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Submit',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);

      // Test loading state
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Submit',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // When loading, tapping should not trigger onPressed
      tapped = false;
      await tester.tap(find.byType(AppButton));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tapped, isFalse);
    });
  });
}
