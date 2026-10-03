import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/design_system/tokens/tokens.dart';

void main() {
  testWidgets('AppApp boots with WidgetsApp.router and displays Phase 0 screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AppApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify custom tokens are accessible and Phase 0 content renders
    expect(find.text('Salary Tracker'), findsOneWidget);
    expect(find.text('✦ PHASE 1 FOUNDATION ACTIVE'), findsOneWidget);
    expect(find.text('INCOME'), findsOneWidget);
    expect(find.text('EXPENSES'), findsOneWidget);
    expect(find.text('SAVED'), findsOneWidget);

    // Verify AppTheme InheritedWidget is present in context
    final BuildContext context = tester.element(find.text('Salary Tracker'));
    final theme = AppTheme.of(context);
    expect(theme.colors.bg, equals(AppColors.light.bg));
    expect(theme.colors.textPrimary, equals(AppColors.light.textPrimary));
  });
}
