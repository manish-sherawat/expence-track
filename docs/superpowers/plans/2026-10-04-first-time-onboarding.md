# First-Time User Experience & Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a zero-Material, zero-Cupertino 5-step first-time onboarding wizard with custom 3D glassmorphic illustrations, live daily safe-to-spend calculation, choice between demo and clean ledger, top progress bar, haptic feedback, and a day-1 contextual welcome banner on the home screen.

**Architecture:** A dedicated `/onboarding` route guarded in `router.dart` checks `AppSettings.onboarding_completed`. A Riverpod `OnboardingController` manages draft state across a 5-step `PageView`. On completion, it persists the user's `SalaryProfile`, sets their selected currency, seeds demo or clean data, and transitions to `/`.

**Tech Stack:** Flutter (`WidgetsApp`, `CustomPainter`), `flutter_riverpod`, `go_router`, `drift`, custom design tokens (`AppTheme`, `AppColors`, `AppTypography`, `AppSpacing`).

**Spec:** [`docs/superpowers/specs/2026-10-04-first-time-onboarding-design.md`](file:///d:/Flutter/BUget%20Tracker/salary_tracker/docs/superpowers/specs/2026-10-04-first-time-onboarding-design.md)

## Global Constraints

- **Design System**: 100% custom widgets; zero Material and zero Cupertino imports.
- **Visuals**: Use custom 3D illustrations from `assets/illustrations/` (`welcome_vault.jpg`, `salary_growth.jpg`, `all_set_check.jpg`).
- **Privacy**: No external network or login auth; all state saved locally in SQLite via Drift.
- **Haptics**: `HapticFeedback.lightImpact()` on option selects and `HapticFeedback.mediumImpact()` on completion.

## Review Focus

1. **Zero / Negative Salary Input**: User types "$0" or leaves it blank on step 3; ensure Continue is disabled or defaults to safe value without division-by-zero.
2. **Back-Navigation State Retention**: Stepping back to previous steps must preserve already entered salary, currency, and mode.
3. **App Kill During Wizard**: State saved in `AppSettings` draft or properly restored so relaunch doesn't crash or skip setup.
4. **Clean vs Demo Seeding**: Choosing "Start Clean" must not load mockup transactions, while "Explore with Demo Data" must load mock transactions.
5. **Route Guard Redirection Loop**: Completed users navigating back should never re-enter `/onboarding`, and incomplete users should not access `/`.

---

### Task 1: Database & Repository Settings Helpers

**Files:**
- Modify: `lib/domain/repositories/i_finance_repository.dart:25-33`
- Modify: `lib/data/repositories/finance_repository.dart:440-480`
- Test: `test/data/onboarding_settings_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `AppSettings` table
- Produces:
  ```dart
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed);
  Future<String> getAppSetting(String key, {String defaultValue = ''});
  Future<void> setAppSetting(String key, String value);
  Future<void> seedInitialFreshData(SalaryProfile profile);
  ```

- [ ] **Step 1: Write the failing test**

```dart
// test/data/onboarding_settings_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:salary_tracker/data/database/app_database.dart';
import 'package:salary_tracker/data/repositories/finance_repository.dart';
import 'package:salary_tracker/domain/models/money.dart';
import 'package:salary_tracker/domain/models/salary_profile.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FinanceRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('onboarding defaults to false then updates to true', () async {
    expect(await repo.isOnboardingCompleted(), isFalse);
    await repo.setOnboardingCompleted(true);
    expect(await repo.isOnboardingCompleted(), isTrue);
  });

  test('getAppSetting and setAppSetting persist arbitrary key values', () async {
    expect(await repo.getAppSetting('app_currency_symbol', defaultValue: '\$'), '\$');
    await repo.setAppSetting('app_currency_symbol', '€');
    expect(await repo.getAppSetting('app_currency_symbol'), '€');
  });

  test('seedInitialFreshData creates default accounts and categories with zero transactions', () async {
    const profile = SalaryProfile(
      id: 'default_salary',
      monthlyGross: Money(600000),
      monthlyNet: Money(500000),
      payDayOfMonth: 25,
      employerName: 'Acme Corp',
    );
    await repo.seedInitialFreshData(profile);
    
    final accounts = await repo.watchAccounts().first;
    expect(accounts, isNotEmpty);
    
    final txns = await repo.watchRecentTransactions().first;
    expect(txns, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/onboarding_settings_test.dart`
Expected: Compilation failure (methods not defined on `IFinanceRepository` / `FinanceRepository`).

- [ ] **Step 3: Implement settings helpers in IFinanceRepository and FinanceRepository**

Add signatures to `lib/domain/repositories/i_finance_repository.dart`:
```dart
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed);
  Future<String> getAppSetting(String key, {String defaultValue = ''});
  Future<void> setAppSetting(String key, String value);
  Future<void> seedInitialFreshData(SalaryProfile profile);
```

Implement in `lib/data/repositories/finance_repository.dart`:
```dart
  @override
  Future<bool> isOnboardingCompleted() async {
    final setting = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals('onboarding_completed')))
        .getSingleOrNull();
    return setting?.value == 'true';
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _db.into(_db.appSettings).insert(
          AppSettingRow(
            key: 'onboarding_completed',
            value: completed ? 'true' : 'false',
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<String> getAppSetting(String key, {String defaultValue = ''}) async {
    final setting = await (_db.select(_db.appSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return setting?.value ?? defaultValue;
  }

  @override
  Future<void> setAppSetting(String key, String value) async {
    await _db.into(_db.appSettings).insert(
          AppSettingRow(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> seedInitialFreshData(SalaryProfile profile) async {
    await _db.transaction(() async {
      await updateSalaryProfile(profile);

      // Default primary accounts with 0 balance
      await _db.into(_db.accounts).insert(
            const AccountRow(
              id: 'acc_primary_checking',
              name: 'Primary Checking',
              type: 'checking',
              balanceMinor: 0,
              lastFour: '0000',
              institution: 'Cash / Bank',
              isDefault: true,
            ),
            mode: InsertMode.insertOrReplace,
          );

      // Standard budget categories
      for (final c in MockupSeedData.categories) {
        await _db.into(_db.categories).insert(
              CategoryRow(
                id: c.id,
                name: c.name,
                iconKey: c.iconKey,
                colorHex: c.colorHex,
                budgetMonthlyMinor: c.budgetMonthly?.cents,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/onboarding_settings_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add test/data/onboarding_settings_test.dart lib/domain/repositories/i_finance_repository.dart lib/data/repositories/finance_repository.dart
git commit -m "feat(data): add onboarding settings helpers and seedInitialFreshData"
```

---

### Task 2: Onboarding State & Calculations

**Files:**
- Create: `lib/features/onboarding/models/onboarding_state.dart`
- Create: `lib/features/onboarding/providers/onboarding_provider.dart`
- Test: `test/features/onboarding/onboarding_state_test.dart`

**Interfaces:**
- Consumes: `SalaryProfile`, `Money`, `IFinanceRepository`
- Produces:
  ```dart
  enum PayFrequency { monthly, biweekly, weekly }
  class OnboardingState { ... int calculateDailyBudgetMinor(); }
  class OnboardingNotifier extends StateNotifier<OnboardingState> { ... }
  final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(...);
  final onboardingCompletedProvider = FutureProvider<bool>(...);
  ```

- [ ] **Step 1: Write the failing test**

```dart
// test/features/onboarding/onboarding_state_test.dart
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

  test('calculateDailyBudgetMinor returns zero when salary is zero', () {
    const state = OnboardingState(
      monthlyNetMinor: 0,
      frequency: PayFrequency.monthly,
    );
    expect(state.calculateDailyBudgetMinor(), 0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/onboarding/onboarding_state_test.dart`
Expected: FAIL (missing file `onboarding_state.dart`).

- [ ] **Step 3: Create OnboardingState and OnboardingNotifier**

Create `lib/features/onboarding/models/onboarding_state.dart`:
```dart
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
        return (monthlyNetMinor ~/ 2) ~/ 14;
      case PayFrequency.weekly:
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
```

Create `lib/features/onboarding/providers/onboarding_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/money.dart';
import '../../../domain/models/salary_profile.dart';
import '../../../providers/finance_providers.dart';
import '../models/onboarding_state.dart';

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.isOnboardingCompleted();
});

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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/onboarding/onboarding_state_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding/models/onboarding_state.dart lib/features/onboarding/providers/onboarding_provider.dart test/features/onboarding/onboarding_state_test.dart
git commit -m "feat(onboarding): add OnboardingState and OnboardingNotifier"
```

---

### Task 3: UI Delighters (Progress Bar & Confetti Burst)

**Files:**
- Create: `lib/features/onboarding/widgets/onboarding_progress_bar.dart`
- Create: `lib/features/onboarding/widgets/confetti_burst.dart`
- Test: `test/features/onboarding/onboarding_widgets_test.dart`

**Interfaces:**
- Consumes: `AppTheme`, `AppColors`, `AppSpacing`
- Produces:
  ```dart
  class OnboardingProgressBar extends StatelessWidget { ... }
  class ConfettiBurst extends StatefulWidget { ... }
  ```

- [ ] **Step 1: Write the failing widget test**

```dart
// test/features/onboarding/onboarding_widgets_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/design_system/tokens/tokens.dart';
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
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/onboarding/onboarding_widgets_test.dart`
Expected: FAIL (missing `onboarding_progress_bar.dart`).

- [ ] **Step 3: Create OnboardingProgressBar and ConfettiBurst**

Create `lib/features/onboarding/widgets/onboarding_progress_bar.dart`:
```dart
import 'package:flutter/widgets.dart';
import '../../../design_system/components/app_icon.dart';
import '../../../design_system/components/pressable.dart';
import '../../../design_system/tokens/tokens.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
    this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        children: [
          if (currentStep > 0 && onBack != null) ...[
            Pressable(
              onPressed: onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: AppRadius.fullBorder,
                  border: Border.all(color: colors.borderSubtle),
                ),
                alignment: Alignment.center,
                child: AppIcon(
                  AppIconType.arrowLeft,
                  size: 16,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
          ] else ...[
            const SizedBox(width: 36, height: 36),
            const SizedBox(width: AppSpacing.s12),
          ],
          Expanded(
            child: Row(
              children: List.generate(totalSteps, (index) {
                final isCompleted = index <= currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right: index < totalSteps - 1 ? AppSpacing.s6 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? colors.primary
                          : colors.borderSubtle.withValues(alpha: 0.3),
                      borderRadius: AppRadius.fullBorder,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 36 + AppSpacing.s12), // Visual balance for back button
        ],
      ),
    );
  }
}
```

Create `lib/features/onboarding/widgets/confetti_burst.dart`:
```dart
import 'dart:math' as math;
import 'package:flutter/widgets.dart';

class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, required this.child});
  final Widget child;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    for (int i = 0; i < 45; i++) {
      _particles.add(_Particle(_random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _ConfettiPainter(
            progress: _controller.value,
            particles: _particles,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _Particle {
  _Particle(math.Random random)
      : color = _colors[random.nextInt(_colors.length)],
        angle = random.nextDouble() * 2 * math.pi,
        velocity = 120 + random.nextDouble() * 260,
        size = 5 + random.nextDouble() * 5,
        rotation = random.nextDouble() * 4 * math.pi;

  static const _colors = [
    Color(0xFF2B7FFF),
    Color(0xFF00D26A),
    Color(0xFFFFB800),
    Color(0xFFFF4864),
    Color(0xFF8B5CF6),
  ];

  final Color color;
  final double angle;
  final double velocity;
  final double size;
  final double rotation;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.particles});
  final double progress;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;
    final center = Offset(size.width / 2, size.height * 0.35);
    final paint = Paint()..style = PaintingStyle.fill;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final distance = p.velocity * progress;
      final x = center.dx + math.cos(p.angle) * distance;
      final y = center.dy + math.sin(p.angle) * distance + (progress * progress * 150);

      paint.color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation * progress);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/onboarding/onboarding_widgets_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding/widgets/onboarding_progress_bar.dart lib/features/onboarding/widgets/confetti_burst.dart test/features/onboarding/onboarding_widgets_test.dart
git commit -m "feat(onboarding): add OnboardingProgressBar and ConfettiBurst widgets"
```

---

### Task 4: Complete OnboardingScreen Implementation

**Files:**
- Create: `lib/features/onboarding/screens/onboarding_screen.dart`
- Test: `test/features/onboarding/onboarding_screen_test.dart`

**Interfaces:**
- Consumes: `OnboardingProgressBar`, `ConfettiBurst`, `onboardingProvider`, `AppTheme`
- Produces: `class OnboardingScreen extends ConsumerStatefulWidget`

- [ ] **Step 1: Write the failing widget test**

```dart
// test/features/onboarding/onboarding_screen_test.dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/onboarding/onboarding_screen_test.dart`
Expected: FAIL (missing `onboarding_screen.dart`).

- [ ] **Step 3: Implement OnboardingScreen**

Create `lib/features/onboarding/screens/onboarding_screen.dart` with all 5 steps:
- Step 1: Welcome & Vision with `assets/illustrations/welcome_vault.jpg`
- Step 2: Currency selection (`$ USD`, `€ EUR`, `£ GBP`, `₹ INR`, `¥ JPY`, `$ CAD`, `$ AUD`)
- Step 3: Net Salary input, Pay frequency SegmentedControl, Payday selector, Live Safe-to-Spend display
- Step 4: Demo vs Clean ledger selection cards
- Step 5: Celebration with `ConfettiBurst`, summary card, and "Enter Dashboard" trigger.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/onboarding/onboarding_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding/screens/onboarding_screen.dart test/features/onboarding/onboarding_screen_test.dart
git commit -m "feat(onboarding): implement 5-step OnboardingScreen with illustrations and haptics"
```

---

### Task 5: Router Redirection & Day-1 Contextual Welcome Banner

**Files:**
- Create: `lib/ui/screens/home/widgets/day1_welcome_banner.dart`
- Modify: `lib/ui/screens/home/home_screen.dart:55-70`
- Modify: `lib/app/router.dart:20-60`
- Test: `test/features/onboarding/day1_welcome_banner_test.dart`

**Interfaces:**
- Consumes: `onboardingCompletedProvider`, `IFinanceRepository`
- Produces: `Day1WelcomeBanner`, top-level `/onboarding` route in `appRouter`

- [ ] **Step 1: Write the failing test**

```dart
// test/features/onboarding/day1_welcome_banner_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/design_system/tokens/tokens.dart';
import 'package:salary_tracker/ui/screens/home/widgets/day1_welcome_banner.dart';

void main() {
  testWidgets('Day1WelcomeBanner renders and dismisses on tap', (tester) async {
    bool dismissed = false;
    await tester.pumpWidget(
      ProviderScope(
        child: AppTheme(
          data: AppThemeData.dark(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Day1WelcomeBanner(
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Welcome Aboard!'), findsOneWidget);
    await tester.tap(find.byType(Pressable));
    await tester.pump();
    expect(dismissed, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/onboarding/day1_welcome_banner_test.dart`
Expected: FAIL (missing `day1_welcome_banner.dart`).

- [ ] **Step 3: Implement Day1WelcomeBanner, integrate into HomeScreen and Router**

Create `lib/ui/screens/home/widgets/day1_welcome_banner.dart`:
```dart
import 'package:flutter/widgets.dart';
import '../../../../design_system/components/app_icon.dart';
import '../../../../design_system/components/glass_surface.dart';
import '../../../../design_system/components/pressable.dart';
import '../../../../design_system/tokens/tokens.dart';

class Day1WelcomeBanner extends StatelessWidget {
  const Day1WelcomeBanner({super.key, required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s8,
      ),
      child: GlassSurface(
        padding: const EdgeInsets.all(AppSpacing.s16),
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.15),
                borderRadius: AppRadius.fullBorder,
              ),
              alignment: Alignment.center,
              child: const AppIcon(AppIconType.sparkle, size: 20),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Aboard!',
                    style: text.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap the "+" button below or scan a receipt to log your first transaction.',
                    style: text.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Pressable(
              onPressed: onDismiss,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s4),
                child: AppIcon(AppIconType.close, size: 16, color: colors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Integrate into `lib/ui/screens/home/home_screen.dart` and update `lib/app/router.dart` with `/onboarding` route and redirection.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/onboarding/day1_welcome_banner_test.dart`
Expected: PASS

- [ ] **Step 5: Run full test suite to ensure no regressions**

Run: `flutter test`
Expected: All tests PASS

- [ ] **Step 6: Commit**

```bash
git add lib/ui/screens/home/widgets/day1_welcome_banner.dart lib/ui/screens/home/home_screen.dart lib/app/router.dart test/features/onboarding/day1_welcome_banner_test.dart
git commit -m "feat(navigation): integrate onboarding route, redirection guard, and Day1WelcomeBanner"
```
