import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/money.dart';
import '../../../domain/models/salary_profile.dart';
import '../../../providers/finance_providers.dart';
import '../models/onboarding_state.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.isOnboardingCompleted();
});

final day1BannerDismissedProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  final val = await repo.getAppSetting('day1_banner_dismissed', defaultValue: 'false');
  return val == 'true';
});

final day1BannerDismissedStateProvider = StateProvider<bool>((ref) => false);

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this._ref) : super(const OnboardingState());

  final Ref _ref;

  void setStep(int step) => state = state.copyWith(currentStep: step);
  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setCurrency(String symbol, String code) {
    state = state.copyWith(currencySymbol: symbol, currencyCode: code);
  }

  void setSalary(int netMinor) => state = state.copyWith(monthlyNetMinor: netMinor);
  void setFrequency(PayFrequency freq) => state = state.copyWith(frequency: freq);
  void setPayDay(int day) => state = state.copyWith(payDayOfMonth: day);
  void setEmployer(String name) => state = state.copyWith(employerName: name);
  void setDemoMode(bool demo) => state = state.copyWith(isDemoMode: demo);

  Future<void> completeOnboarding() async {
    final repo = _ref.read(financeRepositoryProvider);

    // 1. Save salary profile
    final profile = SalaryProfile(
      id: 'user_salary_profile',
      monthlyGross: Money(state.monthlyNetMinor),
      monthlyNet: Money(state.monthlyNetMinor),
      payDayOfMonth: state.payDayOfMonth,
      employerName: state.employerName.isEmpty ? 'My Workplace' : state.employerName,
    );

    if (state.isDemoMode) {
      await repo.seedMockupData();
      await repo.updateSalaryProfile(profile);
    } else {
      await repo.seedInitialFreshData(profile);
    }

    // 2. Persist app settings
    await repo.setAppSetting('app_currency_symbol', state.currencySymbol);
    await repo.setAppSetting('app_currency_code', state.currencyCode);
    await repo.setOnboardingCompleted(true);
  }
}
