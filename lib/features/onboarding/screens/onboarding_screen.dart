import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/app_button.dart';
import '../../../design_system/components/app_icon.dart';
import '../../../design_system/components/app_scaffold.dart';
import '../../../design_system/components/app_text_field.dart';
import '../../../design_system/components/glass_surface.dart';
import '../../../design_system/components/pressable.dart';
import '../../../design_system/components/segmented_control.dart';
import '../../../design_system/tokens/tokens.dart';
import '../models/onboarding_state.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/confetti_burst.dart';
import '../widgets/funny_minimal_illustrations.dart';
import '../widgets/onboarding_progress_bar.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  late final TextEditingController _salaryController;
  late final TextEditingController _employerController;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _salaryController = TextEditingController(text: '4500');
    _employerController = TextEditingController(text: 'My Workplace');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _salaryController.dispose();
    _employerController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    ref.read(onboardingProvider.notifier).setStep(step);
    _pageController.animateToPage(
      step,
      duration: AppMotion.durationNormal,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            OnboardingProgressBar(
              currentStep: state.currentStep,
              totalSteps: 5,
              onBack: state.currentStep > 0
                  ? () {
                      AppHaptics.selectionClick();
                      _goToStep(state.currentStep - 1);
                    }
                  : null,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomeStep(context, state, notifier),
                  _buildCurrencyStep(context, state, notifier),
                  _buildSalaryStep(context, state, notifier),
                  _buildModeStep(context, state, notifier),
                  _buildCelebrationStep(context, state, notifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 0: Welcome & Value Vision
  // ---------------------------------------------------------------------------
  Widget _buildWelcomeStep(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        children: [
          const Spacer(),
          const FunnyMinimalIllustration(
            type: FunnyCharacterType.vault,
            size: 160,
          ),
          const SizedBox(height: AppSpacing.s20),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s6,
            ),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.12),
              borderRadius: AppRadii.borderFull,
              border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(AppIconType.shield, size: 14, color: colors.accent),
                const SizedBox(width: AppSpacing.s6),
                Text(
                  '100% Private & On-Device',
                  style: text.bodySmall.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Master Your Paycheck',
            textAlign: TextAlign.center,
            style: text.h1.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Know exactly what you can safely spend every single day until your next payday, without stressing over complex spreadsheets.',
            textAlign: TextAlign.center,
            style: text.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.45,
            ),
          ),
          const Spacer(),
          AppButton(
            label: 'Get Started',
            trailingIcon: AppIconType.arrowRight,
            isFullWidth: true,
            size: AppButtonSize.large,
            onPressed: () {
              AppHaptics.selectionClick();
              _goToStep(1);
            },
          ),
          const SizedBox(height: AppSpacing.s20),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: Currency Selection
  // ---------------------------------------------------------------------------
  Widget _buildCurrencyStep(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    const currencies = [
      ('\$', 'USD', 'US Dollar'),
      ('€', 'EUR', 'Euro'),
      ('£', 'GBP', 'British Pound'),
      ('₹', 'INR', 'Indian Rupee'),
      ('¥', 'JPY', 'Japanese Yen'),
      ('\$', 'CAD', 'Canadian Dollar'),
      ('\$', 'AUD', 'Australian Dollar'),
      ('₣', 'CHF', 'Swiss Franc'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: FunnyMinimalIllustration(
              type: FunnyCharacterType.coolCoin,
              size: 110,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Choose Your Currency',
            style: text.h2.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'We will format all transactions, budgets, and forecasts to your currency.',
            style: text.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s16),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.s12,
                mainAxisSpacing: AppSpacing.s12,
                childAspectRatio: 2.3,
              ),
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final (sym, code, name) = currencies[index];
                final isSelected = state.currencyCode == code;

                return Pressable(
                  onPressed: () {
                    AppHaptics.selectionClick();
                    notifier.setCurrency(sym, code);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                      vertical: AppSpacing.s8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.accent.withValues(alpha: 0.12)
                          : colors.surface,
                      borderRadius: AppRadii.border16,
                      border: Border.all(
                        color: isSelected ? colors.accent : colors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.accent
                                : colors.border.withValues(alpha: 0.3),
                            borderRadius: AppRadii.borderFull,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            sym,
                            style: text.bodyLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isSelected ? const Color(0xFF0F172A) : colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                code,
                                style: text.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          GlassSurface(
            padding: const EdgeInsets.all(AppSpacing.s12),
            borderRadius: AppRadii.border16,
            child: Row(
              children: [
                Text(
                  'Format Preview:',
                  style: text.bodySmall.copyWith(color: colors.textSecondary),
                ),
                const Spacer(),
                Text(
                  '${state.currencySymbol}1,250.00',
                  style: text.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppButton(
            label: 'Continue to Salary Setup →',
            isFullWidth: true,
            size: AppButtonSize.large,
            onPressed: () {
              AppHaptics.selectionClick();
              _goToStep(2);
            },
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: Salary & Pay Schedule
  // ---------------------------------------------------------------------------
  Widget _buildSalaryStep(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;
    final dailyAllowanceMinor = state.calculateDailyBudgetMinor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: FunnyMinimalIllustration(
              type: FunnyCharacterType.smartBudget,
              size: 100,
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          Text(
            'Your Income & Payday',
            style: text.h2.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'Powers your daily safe-to-spend allowance and cash flow.',
            style: text.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s16),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net Monthly Take-Home Pay',
                    style: text.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  AppTextField(
                    controller: _salaryController,
                    placeholder: '4500',
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                      final amount = int.tryParse(clean) ?? 0;
                      notifier.setSalary(amount * 100);
                    },
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  // Quick Salary Presets
                  Row(
                    children: [3000, 4500, 6000, 8000].map((preset) {
                      final isSelected = state.monthlyNetMinor == preset * 100;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Pressable(
                            onPressed: () {
                              AppHaptics.selectionClick();
                              _salaryController.text = preset.toString();
                              notifier.setSalary(preset * 100);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? colors.accent : colors.surface,
                                borderRadius: AppRadii.border8,
                                border: Border.all(
                                  color: isSelected ? colors.accent : colors.border,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${state.currencySymbol}$preset',
                                style: text.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? const Color(0xFF0F172A) : colors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'Pay Frequency',
                    style: text.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  SegmentedControl<PayFrequency>(
                    segments: const [
                      PayFrequency.monthly,
                      PayFrequency.biweekly,
                      PayFrequency.weekly,
                    ],
                    selectedSegment: state.frequency,
                    labelBuilder: (f) {
                      switch (f) {
                        case PayFrequency.monthly:
                          return 'Monthly';
                        case PayFrequency.biweekly:
                          return 'Bi-Weekly';
                        case PayFrequency.weekly:
                          return 'Weekly';
                      }
                    },
                    onSegmentSelected: (f) {
                      AppHaptics.selectionClick();
                      notifier.setFrequency(f);
                    },
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'Payday (Day of Month: ${state.payDayOfMonth}th)',
                    style: text.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: 31,
                      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s6),
                      itemBuilder: (context, idx) {
                        final day = idx + 1;
                        final isSelected = state.payDayOfMonth == day;
                        return Pressable(
                          onPressed: () {
                            AppHaptics.selectionClick();
                            notifier.setPayDay(day);
                          },
                          child: Container(
                            width: 38,
                            decoration: BoxDecoration(
                              color: isSelected ? colors.accent : colors.surface,
                              borderRadius: AppRadii.borderFull,
                              border: Border.all(
                                color: isSelected ? colors.accent : colors.border,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$day',
                              style: text.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? const Color(0xFF0F172A) : colors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  // Live Calculator Card
                  GlassSurface(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    borderRadius: AppRadii.border16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppIcon(AppIconType.sparkle, size: 16, color: colors.accent),
                            const SizedBox(width: AppSpacing.s6),
                            Text(
                              'DAILY SAFE-TO-SPEND ALLOWANCE',
                              style: text.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.accent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          '${state.currencySymbol}${(dailyAllowanceMinor / 100).toStringAsFixed(2)} / day',
                          style: text.h1.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Calculated across your pay cycle so you never run dry before next payday.',
                          style: text.bodySmall.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          AppButton(
            label: 'Continue →',
            isFullWidth: true,
            size: AppButtonSize.large,
            enabled: state.monthlyNetMinor > 0,
            onPressed: () {
              AppHaptics.selectionClick();
              _goToStep(3);
            },
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: Experience Mode
  // ---------------------------------------------------------------------------
  Widget _buildModeStep(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: FunnyMinimalIllustration(
              type: FunnyCharacterType.curiousPiggy,
              size: 110,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'How would you like to start?',
            style: text.h2.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'You can switch or clear sample data in Settings at any time.',
            style: text.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s16),
          // Option 1: Demo Mode
          Pressable(
            onPressed: () {
              AppHaptics.selectionClick();
              notifier.setDemoMode(true);
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: state.isDemoMode
                    ? colors.accent.withValues(alpha: 0.12)
                    : colors.surface,
                borderRadius: AppRadii.border20,
                border: Border.all(
                  color: state.isDemoMode ? colors.accent : colors.border,
                  width: state.isDemoMode ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: AppRadii.borderFull,
                        ),
                        child: Text(
                          'RECOMMENDED ✦',
                          style: text.bodySmall.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.isDemoMode ? colors.accent : colors.surface,
                          border: Border.all(
                            color: state.isDemoMode ? colors.accent : colors.border,
                            width: 2,
                          ),
                        ),
                        child: state.isDemoMode
                            ? const Center(
                                child: AppIcon(
                                  AppIconType.check,
                                  size: 12,
                                  color: Color(0xFF0F172A),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    'Explore with Demo Playground',
                    style: text.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pre-loads realistic checking accounts, recent transactions, spending charts, and an AI-scanned receipt so you can test all features right away.',
                    style: text.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          // Option 2: Clean Mode
          Pressable(
            onPressed: () {
              AppHaptics.selectionClick();
              notifier.setDemoMode(false);
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: !state.isDemoMode
                    ? colors.accent.withValues(alpha: 0.12)
                    : colors.surface,
                borderRadius: AppRadii.border20,
                border: Border.all(
                  color: !state.isDemoMode ? colors.accent : colors.border,
                  width: !state.isDemoMode ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.border.withValues(alpha: 0.6),
                          borderRadius: AppRadii.borderFull,
                        ),
                        child: Text(
                          'FRESH SLATE',
                          style: text.bodySmall.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: !state.isDemoMode ? colors.accent : colors.surface,
                          border: Border.all(
                            color: !state.isDemoMode ? colors.accent : colors.border,
                            width: 2,
                          ),
                        ),
                        child: !state.isDemoMode
                            ? const Center(
                                child: AppIcon(
                                  AppIconType.check,
                                  size: 12,
                                  color: Color(0xFF0F172A),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    'Start Clean Ledger',
                    style: text.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Initializes primary accounts and standard budget categories with a \$0 balance, ready for you to log your real transactions from scratch.',
                    style: text.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          AppButton(
            label: 'Create My Dashboard →',
            isFullWidth: true,
            size: AppButtonSize.large,
            onPressed: () {
              AppHaptics.selectionClick();
              _goToStep(4);
            },
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 4: Celebration & Launch
  // ---------------------------------------------------------------------------
  Widget _buildCelebrationStep(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;
    final dailyAllowanceMinor = state.calculateDailyBudgetMinor();

    return ConfettiBurst(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        child: Column(
          children: [
            const Spacer(),
            const FunnyMinimalIllustration(
              type: FunnyCharacterType.partyCelebration,
              size: 150,
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              "You're All Set!",
              textAlign: TextAlign.center,
              style: text.h1.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Your personalized financial command center is configured and ready.',
              textAlign: TextAlign.center,
              style: text.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s20),
            GlassSurface(
              padding: const EdgeInsets.all(AppSpacing.s16),
              borderRadius: AppRadii.border20,
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Configured Salary',
                    '${state.currencySymbol}${(state.monthlyNetMinor / 100).toStringAsFixed(2)} / mo',
                    text,
                    colors,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  _buildSummaryRow(
                    'Pay Schedule',
                    '${state.frequency.name.toUpperCase()} (Day ${state.payDayOfMonth})',
                    text,
                    colors,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  _buildSummaryRow(
                    'Daily Allowance',
                    '${state.currencySymbol}${(dailyAllowanceMinor / 100).toStringAsFixed(2)} / day',
                    text,
                    colors,
                    highlight: true,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  _buildSummaryRow(
                    'Initial Mode',
                    state.isDemoMode ? 'Demo Playground' : 'Clean Ledger',
                    text,
                    colors,
                  ),
                ],
              ),
            ),
            const Spacer(),
            AppButton(
              label: 'Enter Dashboard 🚀',
              isFullWidth: true,
              size: AppButtonSize.large,
              isLoading: _isCompleting,
              onPressed: () async {
                setState(() => _isCompleting = true);
                unawaited(AppHaptics.mediumImpact());
                await notifier.completeOnboarding();
                if (mounted) {
                  this.context.go('/');
                }
              },
            ),
            const SizedBox(height: AppSpacing.s20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    AppTypography text,
    AppColors colors, {
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: text.bodySmall.copyWith(color: colors.textSecondary),
        ),
        Text(
          value,
          style: text.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: highlight ? colors.accent : colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
