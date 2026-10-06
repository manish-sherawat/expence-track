import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/app/router.dart';
import 'package:salary_tracker/ui/screens/search/search_screen.dart';

void main() {
  group('SearchScreen Widget Tests', () {
    setUp(() {
      appRouter.go('/search');
    });

    testWidgets('Renders all SearchScreen elements and suggested tags',
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

      expect(find.byType(SearchScreen), findsOneWidget);
      expect(find.byType(EditableText), findsOneWidget);
      expect(find.text('SUGGESTED SEARCHES'), findsOneWidget);
      expect(find.text('Whole Foods'), findsWidgets);
      expect(find.text('Uber'), findsWidgets);
      expect(find.text('All Categories'), findsOneWidget);
    });

    testWidgets('Tapping suggested search tag populates search bar',
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

      // Tap on 'Whole Foods' tag in suggestions
      final tagFinder = find.text('Whole Foods').last;
      await tester.tap(tagFinder);
      await tester.pumpAndSettle();

      // Results should display Whole Foods transaction
      expect(find.text('Whole Foods Market'), findsWidgets);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('Entering query filters transactions reactively',
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

      // Enter query 'Uber'
      await tester.enterText(find.byType(EditableText), 'Uber');
      await tester.pumpAndSettle();

      expect(find.text('Uber Trip'), findsOneWidget);
    });
  });
}
