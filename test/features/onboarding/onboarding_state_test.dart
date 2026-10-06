import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/features/onboarding/models/onboarding_state.dart';

void main() {
  test('calculateDailyBudgetMinor correctly calculates for monthly cycle', () {
    const state = OnboardingState(
      monthlyNetMinor: 300000, // $3,000.00
      frequency: PayFrequency.monthly,
      daysInMonth: 30,
    );
    expect(state.calculateDailyBudgetMinor(), 10000); // $100.00/day
  });

  test('calculateDailyBudgetMinor handles bi-weekly cycle', () {
    const state = OnboardingState(
      monthlyNetMinor: 280000, // $2,800.00 / month = $1,400 / 14 days
      frequency: PayFrequency.biweekly,
    );
    expect(state.calculateDailyBudgetMinor(), 10000); // $100.00/day
  });

  test('calculateDailyBudgetMinor handles weekly cycle', () {
    const state = OnboardingState(
      monthlyNetMinor: 280000, // $2,800.00 / month = $700 / 7 days
      frequency: PayFrequency.weekly,
    );
    expect(state.calculateDailyBudgetMinor(), 10000); // $100.00/day
  });

  test('calculateDailyBudgetMinor returns zero when salary is zero or negative', () {
    const stateZero = OnboardingState(
      monthlyNetMinor: 0,
      frequency: PayFrequency.monthly,
    );
    expect(stateZero.calculateDailyBudgetMinor(), 0);

    const stateNegative = OnboardingState(
      monthlyNetMinor: -500,
      frequency: PayFrequency.monthly,
    );
    expect(stateNegative.calculateDailyBudgetMinor(), 0);
  });

  test('copyWith retains and updates properties appropriately', () {
    const state = OnboardingState();
    final updated = state.copyWith(
      currentStep: 2,
      currencySymbol: '€',
      currencyCode: 'EUR',
      monthlyNetMinor: 500000,
      employerName: 'Acme Global',
      isDemoMode: false,
    );

    expect(updated.currentStep, 2);
    expect(updated.currencySymbol, '€');
    expect(updated.currencyCode, 'EUR');
    expect(updated.monthlyNetMinor, 500000);
    expect(updated.employerName, 'Acme Global');
    expect(updated.isDemoMode, false);
  });
}
