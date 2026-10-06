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
  group('Phase 2 Component Library Tests', () {
    testWidgets('FrostedNavBar renders and handles item selection', (tester) async {
      int selectedIndex = 0;
      bool centerActionTriggered = false;

      await tester.pumpWidget(
        _wrap(
          FrostedNavBar(
            selectedIndex: selectedIndex,
            onItemSelected: (idx) => selectedIndex = idx,
            onCenterAction: () => centerActionTriggered = true,
            leftItems: const [
              FrostedNavBarItem(icon: AppIconType.wallet, label: 'Wallet'),
              FrostedNavBarItem(icon: AppIconType.chart, label: 'Analytics'),
            ],
            rightItems: const [
              FrostedNavBarItem(icon: AppIconType.bell, label: 'Alerts'),
              FrostedNavBarItem(icon: AppIconType.user, label: 'Profile'),
            ],
          ),
        ),
      );

      expect(find.byType(FrostedNavBar), findsOneWidget);
      expect(find.byType(AppIcon), findsWidgets);

      // Tap index 1
      final icons = find.byType(AppIcon);
      await tester.tap(icons.at(1));
      await tester.pumpAndSettle();
      expect(selectedIndex, equals(1));

      // Tap center action
      await tester.tap(icons.at(2)); // center plus icon
      await tester.pumpAndSettle();
      expect(centerActionTriggered, isTrue);
    });

    testWidgets('SegmentedControl switches selected index smoothly', (tester) async {
      String selectedSegment = 'Week';

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              return SegmentedControl<String>(
                segments: const ['Week', 'Month', 'Year'],
                selectedSegment: selectedSegment,
                onSegmentSelected: (seg) => setState(() => selectedSegment = seg),
                labelBuilder: (seg) => seg,
              );
            },
          ),
        ),
      );

      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);

      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      expect(selectedSegment, equals('Month'));

      await tester.tap(find.text('Year'));
      await tester.pumpAndSettle();
      expect(selectedSegment, equals('Year'));
    });

    testWidgets('StatCard and TrendBadge render accurately', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Spent',
                  amountCents: 321800,
                  trendPercentage: -4.2,
                  isPositiveGood: false,
                ),
              ),
              Expanded(
                child: StatCard(
                  title: 'Daily Average',
                  amountCents: 10726,
                  trendPercentage: 2.1,
                  isPositiveGood: true,
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Total Spent'), findsOneWidget);
      expect(find.text('Daily Average'), findsOneWidget);
      expect(find.text('-4.2%'), findsOneWidget);
      expect(find.text('+2.1%'), findsOneWidget);
    });

    testWidgets('ProgressBar animates to target percentage', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ProgressBar(
            progress: 0.68,
            height: 6,
          ),
        ),
      );

      expect(find.byType(ProgressBar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('AreaLineChart renders painter canvas', (tester) async {
      final points = [
        const ChartDataPoint(label: 'Apr 1', valueCents: 12000),
        const ChartDataPoint(label: 'Apr 5', valueCents: 24000),
        const ChartDataPoint(label: 'Apr 10', valueCents: 18000),
        const ChartDataPoint(label: 'Apr 15', valueCents: 32000),
      ];

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 200,
            child: AreaLineChart(
              data: points,
            ),
          ),
        ),
      );

      expect(find.byType(AreaLineChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('TransactionTile renders details and amount correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TransactionTile(
            title: 'Whole Foods Market',
            subtitle: 'Groceries & Household',
            amountCents: 6784,
            isIncome: false,
            timeString: '2:45 PM',
            aiChipLabel: '✦ Food',
            icon: AppIconType.food,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Whole Foods Market'), findsOneWidget);
      expect(find.text('Groceries & Household'), findsOneWidget);
      expect(find.text('2:45 PM'), findsOneWidget);
      expect(find.text('✦ Food'), findsOneWidget);
    });

    testWidgets('CategoryCard and InsightBanner render correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              CategoryCard(
                title: 'Food & Dining',
                amountCents: 124000,
                percentage: 38.5,
                icon: AppIconType.food,
                onTap: () {},
              ),
              InsightBanner(
                headline: 'AI Smart Insight',
                subheadline: 'You saved \$140 more on dining compared to last month.',
                onTap: () {},
              ),
            ],
          ),
        ),
      );

      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('AI Smart Insight'), findsOneWidget);
      expect(find.text('You saved \$140 more on dining compared to last month.'), findsOneWidget);
    });

    testWidgets('AmountKeypad triggers callbacks on digit, decimal, and backspace', (tester) async {
      String entered = '';
      bool decimalPressed = false;
      bool backspacePressed = false;

      await tester.pumpWidget(
        _wrap(
          AmountKeypad(
            onDigitPressed: (digit) => entered += digit,
            onDecimalPressed: () => decimalPressed = true,
            onBackspacePressed: () => backspacePressed = true,
          ),
        ),
      );

      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      expect(entered, equals('5'));

      await tester.tap(find.text('.'));
      await tester.pumpAndSettle();
      expect(decimalPressed, isTrue);

      await tester.tap(find.byType(AppIcon));
      await tester.pumpAndSettle();
      expect(backspacePressed, isTrue);
    });

    testWidgets('AppTextField accepts text input and shows error', (tester) async {
      String currentText = '';
      await tester.pumpWidget(
        _wrap(
          AppTextField(
            label: 'Salary Amount',
            placeholder: 'Enter amount...',
            errorText: 'Required field',
            onChanged: (val) => currentText = val,
          ),
        ),
      );

      expect(find.text('Salary Amount'), findsOneWidget);
      expect(find.text('Enter amount...'), findsOneWidget);
      expect(find.text('Required field'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), '1000');
      await tester.pumpAndSettle();
      expect(currentText, equals('1000'));
    });

    testWidgets('AppSelectionControls (Toggle, Checkbox, Radio) work as expected', (tester) async {
      bool toggleVal = false;
      bool checkboxVal = false;
      int radioVal = 1;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  AppToggle(
                    value: toggleVal,
                    onChanged: (val) => setState(() => toggleVal = val),
                  ),
                  AppCheckbox(
                    value: checkboxVal,
                    onChanged: (val) => setState(() => checkboxVal = val),
                  ),
                  AppRadio<int>(
                    value: 1,
                    groupValue: radioVal,
                    onChanged: (val) => setState(() => radioVal = val),
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.byType(AppToggle), findsOneWidget);
      expect(find.byType(AppCheckbox), findsOneWidget);
      expect(find.byType(AppRadio<int>), findsOneWidget);

      await tester.tap(find.byType(AppToggle));
      await tester.pumpAndSettle();
      expect(toggleVal, isTrue);

      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      expect(checkboxVal, isTrue);
    });

    testWidgets('AppDatePicker and AppLoadingSpinner render', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SingleChildScrollView(
            child: Column(
              children: [
                AppDatePicker(
                  initialDate: DateTime(2026, 4, 15),
                  onDateSelected: (_) {},
                ),
                const AppLoadingSpinner(size: 24),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppDatePicker), findsOneWidget);
      expect(find.byType(AppLoadingSpinner), findsOneWidget);
    });

    test('FormValidator and FormGroup validate fields correctly', () {
      final form = FormGroup();
      form.registerField(
        'salary',
        initialValue: '',
        validator: FormValidator.required('Salary is required'),
      );
      form.registerField(
        'email',
        initialValue: 'test@domain.com',
        validator: FormValidator.email('Invalid email'),
      );

      expect(form.validate(), isFalse);
      expect(form.getError('salary'), equals('Salary is required'));
      expect(form.getError('email'), isNull);

      form.setValue('salary', '5000');
      expect(form.validate(), isTrue);
      expect(form.getError('salary'), isNull);
    });
  });
}
