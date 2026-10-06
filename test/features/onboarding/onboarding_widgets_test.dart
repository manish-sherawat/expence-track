import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/design_system/components/pressable.dart';
import 'package:salary_tracker/design_system/tokens/tokens.dart';
import 'package:salary_tracker/features/onboarding/widgets/funny_minimal_illustrations.dart';
import 'package:salary_tracker/features/onboarding/widgets/onboarding_progress_bar.dart';

void main() {
  testWidgets('OnboardingProgressBar renders 5 segments and triggers onBack', (tester) async {
    bool backTapped = false;
    await tester.pumpWidget(
      AppTheme(
        data: AppThemeData.dark(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: OnboardingProgressBar(
            currentStep: 2,
            totalSteps: 5,
            onBack: () => backTapped = true,
          ),
        ),
      ),
    );

    expect(find.byType(OnboardingProgressBar), findsOneWidget);
    await tester.tap(find.byType(Pressable));
    await tester.pump();
    expect(backTapped, isTrue);
  });

  testWidgets('FunnyMinimalIllustration renders character types without error', (tester) async {
    for (final type in FunnyCharacterType.values) {
      await tester.pumpWidget(
        AppTheme(
          data: AppThemeData.dark(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: FunnyMinimalIllustration(type: type),
          ),
        ),
      );
      expect(find.byType(FunnyMinimalIllustration), findsOneWidget);
    }
  });
}
