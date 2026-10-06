import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/design_system/tokens/tokens.dart';
import 'package:salary_tracker/features/onboarding/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders initial Welcome step', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: AppTheme(
          data: AppThemeData.dark(),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: OnboardingScreen(),
          ),
        ),
      ),
    );

    expect(find.text('Master Your Paycheck'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
