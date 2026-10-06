enum PayFrequency { monthly, biweekly, weekly }

class OnboardingState {
  const OnboardingState({
    this.currentStep = 0,
    this.currencySymbol = '\$',
    this.currencyCode = 'USD',
    this.monthlyNetMinor = 450000, // $4,500.00 default suggestion
    this.frequency = PayFrequency.monthly,
    this.payDayOfMonth = 15,
    this.employerName = 'My Workplace',
    this.isDemoMode = true,
    this.daysInMonth = 30,
  });

  final int currentStep;
  final String currencySymbol;
  final String currencyCode;
  final int monthlyNetMinor;
  final PayFrequency frequency;
  final int payDayOfMonth;
  final String employerName;
  final bool isDemoMode;
  final int daysInMonth;

  int calculateDailyBudgetMinor() {
    if (monthlyNetMinor <= 0) return 0;
    switch (frequency) {
      case PayFrequency.monthly:
        return daysInMonth > 0 ? (monthlyNetMinor ~/ daysInMonth) : 0;
      case PayFrequency.biweekly:
        // Bi-weekly pay represents 26 paychecks per year or approx half month per 14 days
        return (monthlyNetMinor ~/ 2) ~/ 14;
      case PayFrequency.weekly:
        // Weekly pay represents approx quarter month per 7 days
        return (monthlyNetMinor ~/ 4) ~/ 7;
    }
  }

  OnboardingState copyWith({
    int? currentStep,
    String? currencySymbol,
    String? currencyCode,
    int? monthlyNetMinor,
    PayFrequency? frequency,
    int? payDayOfMonth,
    String? employerName,
    bool? isDemoMode,
    int? daysInMonth,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      monthlyNetMinor: monthlyNetMinor ?? this.monthlyNetMinor,
      frequency: frequency ?? this.frequency,
      payDayOfMonth: payDayOfMonth ?? this.payDayOfMonth,
      employerName: employerName ?? this.employerName,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      daysInMonth: daysInMonth ?? this.daysInMonth,
    );
  }
}
