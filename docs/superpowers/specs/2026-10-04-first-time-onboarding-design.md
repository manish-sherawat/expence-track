# First-Time User Experience (FTUE) & Onboarding Design Specification

- **Date**: 2026-10-04
- **Status**: Approved for Implementation Planning
- **Author**: Antigravity Assistant & Engineering Team
- **Target Application**: Salary Tracker (Zero Material, Zero Cupertino custom design system)

---

## 1. Executive Summary & Goals

When a new user launches the Salary Tracker app for the first time, the current implementation navigates immediately to the dashboard with hardcoded or auto-seeded mockup data. There is no introduction, no personal salary configuration, no currency selection, and no orientation.

This specification introduces a **First-Time User Experience (FTUE)** featuring a 5-step onboarding wizard, custom glassmorphism visual cards, live daily safe-to-spend allowance preview, choice between demo playground or fresh start, and four signature "delight" touches.

### Key Objectives
1. **Zero Registration Barrier**: Instant local onboarding without account creation, email verification, or cloud lock-in.
2. **Immediate Financial Clarity**: Live calculation of daily spending power as the user inputs their salary and pay cycle.
3. **Choice of Mode**: Support both curious explorers ("Explore with Demo Data") and clean-slate trackers ("Start Clean").
4. **Delightful Micro-Interactions**: Custom haptic feedback, fluid cubic animations, step progress pill bar, and celebration particles.
5. **Consistency with Design System**: 100% compliant with existing tokens, custom painters, `WidgetsApp.router`, and zero Material/Cupertino dependencies.

---

## 2. Architecture & Data Flow

### 2.1 Database & Persistence (`AppSettings`)
The existing SQLite database via Drift already provides an `AppSettings` table (`key` TEXT PK, `value` TEXT). We define the following keys:
- `onboarding_completed`: `'true'` | `'false'` (defaults to `'false'`)
- `app_currency_symbol`: E.g. `'$'`, `'€'`, `'£'`, `'₹'`, `'¥'` (defaults to `'$'`)
- `onboarding_draft_step`: Integer index (`0` to `4`) to support save-as-you-go.
- `day1_banner_dismissed`: `'true'` | `'false'` (defaults to `'false'`)

### 2.2 Providers (`finance_providers.dart`)
1. **`onboardingCompletedProvider`**: StreamProvider / StateNotifier watching `AppSettings` for `onboarding_completed`.
2. **`currencySymbolProvider`**: StreamProvider or StateProvider managing the active currency symbol.
3. **`onboardingDraftController`**: StateNotifier holding intermediate draft values:
   - `selectedCurrency`: String (default `'$'`)
   - `monthlySalaryCents`: int
   - `payFrequency`: `PayFrequency` enum (`monthly`, `biweekly`, `weekly`)
   - `payDayOfMonth`: int (1 to 31, default 15)
   - `employerName`: String
   - `isDemoMode`: bool (default `true`)

### 2.3 Router Integration (`router.dart`)
- Define new route `/onboarding` pointing to `OnboardingScreen`.
- In `GoRouter.redirect`:
  - When `onboarding_completed == false` and current URI does not start with `/onboarding`, redirect to `/onboarding`.
  - When `onboarding_completed == true` and current URI is `/onboarding`, redirect to `/`.

---

## 3. Screen Sequence & Wizard Details

The onboarding experience is orchestrated inside `OnboardingScreen` using a horizontal `PageView` with `NeverScrollableScrollPhysics` (navigation is button-driven with step-back support):

### Step 1: Welcome & Value Vision
- **Visual**: Hero illustration (`assets/illustrations/welcome_vault.jpg`) framed in a subtle glowing glass surface.
- **Copy**:
  - Title: *"Master Your Paycheck"*
  - Subtitle: *"Know exactly what you can safely spend every day until your next payday."*
  - Badge: 🔒 *"100% Private & On-Device. Zero registration required."*
- **Interaction**: Primary button: *"Get Started"*.

### Step 2: Currency & Regional Formatting
- **Visual**: Currency selection grid with pill chips (`$ USD`, `€ EUR`, `£ GBP`, `₹ INR`, `¥ JPY`, `$ CAD`, `$ AUD`).
- **Live Preview**: Interactive card displaying:
  - *"Amounts will display like: [Symbol]1,250.00"*
- **Interaction**: Haptic click on selection; *"Continue"* button.

### Step 3: Salary & Pay Schedule (The Core Engine)
- **Inputs**:
  - **Net Take-Home Salary**: Text field with currency prefix and numeric input.
  * **Pay Frequency**: SegmentedControl (`Monthly`, `Bi-weekly`, `Weekly`).
  * **Payday of Month**: Wheel or selector (1–31).
  * **Employer Name** (Optional): Defaults to *"My Workplace"*.
- **Live Calculator Feedback Card**:
  - Automatically computes and animates:
    $$\text{Daily Allowance} = \frac{\text{Net Monthly Salary}}{\text{Days in Cycle}}$$
  - Displays: *"Estimated Safe-to-Spend: **$XX.XX / day**"* with gentle glow animation.

### Step 4: Starting Experience Mode
- Two interactive selection cards:
  1. **Explore with Demo Data (Recommended)**:
     - Pre-loads sample checking & savings accounts, categorized expenses, and AI insight samples.
     - Subtext: *"Best for first-time users who want to see full charts, trends, and scanner capabilities immediately."*
  2. **Start Clean**:
     - Pre-loads standard accounts and budget categories with $0 balance and zero transactions.
     - Subtext: *"Best for users ready to start logging actual transactions immediately."*

### Step 5: Celebration & Launch
- **Visual**: Confetti particle burst via custom `CustomPainter`, checkmark shield illustration (`assets/illustrations/all_set_check.jpg`).
- **Personalized Summary Glass Card**:
  - Configured Salary: `[Symbol]X,XXX / month`
  - Next Payday: `In X days (Day Y)`
  - Daily Budget: `[Symbol]XX.XX / day`
- **Interaction**: *"Enter Dashboard"* primary button with medium haptic pulse.

---

## 4. The 4 Extra "Make the User Feel Good" Touches

1. **Top Segmented Progress Indicator**:
   - 5-pill segmented bar showing current step with fluid width animation (`Curves.easeOutCubic`).
   - Includes a back-arrow button to return to previous steps seamlessly.
2. **Haptic Feedback**:
   - `HapticFeedback.lightImpact()` on option selections, currency picks, and step advances.
   - `HapticFeedback.mediumImpact()` on final launch button tap.
3. **Save-As-You-Go**:
   - Intermediate draft values are saved to SQLite or StateNotifier so accidentally closing the app does not erase progress.
4. **Day-1 Contextual Guide Banner**:
   - On `HomeScreen`, if `day1_banner_dismissed != 'true'`, render an elegant dismissible top glass card:
     > *"👋 Welcome aboard! Tap the '+' button below to add your first transaction or scan a receipt."*

---

## 5. Visual Assets & Illustrations

Custom illustrations generated and placed in `assets/illustrations/`:
1. `welcome_vault.jpg` — Sleek, dark-mode 3D vault with neon accent glows and floating coins.
2. `salary_growth.jpg` — Upward neon graph trajectory with glowing calendar badge.
3. `all_set_check.jpg` — Glassmorphic badge with celebratory sparkles and checkmark.

---

## 6. Testing & Quality Verification

1. **Unit Tests**:
   - Calculation logic for daily allowance across monthly, bi-weekly, and weekly cycles.
   - Database read/write for `AppSettings` onboarding keys.
2. **Widget Tests**:
   - `OnboardingScreen` page navigation (forward, backward, progress indicator updates).
   - Form validation: Ensuring salary cannot be zero or negative.
   - Route redirection verification (unauthenticated first-run lands on `/onboarding`, subsequent runs land on `/`).
3. **Device Verification**:
   - Verify layout on both compact mobile screens and tablet/desktop centered frame.
