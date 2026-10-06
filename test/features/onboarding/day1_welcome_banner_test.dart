import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/design_system/components/pressable.dart';
import 'package:salary_tracker/design_system/tokens/tokens.dart';
import 'package:salary_tracker/ui/screens/home/widgets/day1_welcome_banner.dart';

void main() {
  testWidgets('Day1WelcomeBanner renders and dismisses on tap', (tester) async {
    bool dismissed = false;
    await tester.pumpWidget(
      AppTheme(
        data: AppThemeData.dark(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Day1WelcomeBanner(
            onDismiss: () => dismissed = true,
          ),
        ),
      ),
    );

    expect(find.text('Welcome Aboard!'), findsOneWidget);
    expect(find.text('Replay Onboarding Tour'), findsOneWidget);
    await tester.tap(find.byType(Pressable).first);
    await tester.pump();
    expect(dismissed, isTrue);
  });
}
