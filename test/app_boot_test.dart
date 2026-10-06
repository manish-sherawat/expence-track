import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/design_system/tokens/tokens.dart';

void main() {
  testWidgets('AppApp boots with WidgetsApp.router and displays Home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AppApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Screen 1 greeting and user name
    expect(find.text('Welcome Back,'), findsOneWidget);
    expect(find.text('Jacob Simmons'), findsOneWidget);

    // Verify Total Balance card components
    expect(find.text('TOTAL BALANCE'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);

    // Verify Sections
    expect(find.text('Spending by Category'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);

    // Verify AppTheme InheritedWidget is present in context
    final BuildContext context = tester.element(find.text('Jacob Simmons'));
    final theme = AppTheme.of(context);
    expect(theme.colors.bg, equals(AppColors.light.bg));
    expect(theme.colors.textPrimary, equals(AppColors.light.textPrimary));
  });
}
