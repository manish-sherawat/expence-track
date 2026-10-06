# Salary & Money Tracker: Master Roadmap & First-Time Install Screens Specification

**Target Platforms:** Android, iOS, Web (Single Flutter Codebase)  
**Design Philosophy:** 100% Custom Primitives (Zero Material & Zero Cupertino widgets)  
**Typography:** Inter Variable Font with Tabular Figures  
**Color System:** Obsidian Dark Mode (`#0B0D12`) / Pure Cream Light Mode (`#F5F6FA`)  

---

## Part 1: Master Product & Engineering Roadmap

### Phase 0: Architecture Foundations & Custom Design System ✅
*Status: 100% Complete & Verified with 81/81 Automated Tests*
- Custom token engine: `AppColors`, `AppTypography`, `AppSpacing`, `AppRadii`, `AppShadows`, `AppMotion`.
- Strict zero-Material & zero-Cupertino architectural guardrails (`WidgetsApp.router`).
- Core UI primitives: `Pressable`, `GlassSurface`, `AppScaffold`, `AmountText`, `TagChip`, `StatusPill`, `CircleIconButton`, `AppButton`, `AppIcon` custom vector system.
- Component Gallery (`/gallery`) showcasing all primitives in interactive light & dark states.
- Continuous Integration (CI) workflow with static analyzer enforcement.

### Phase 1: Core Dashboard & Financial Views ✅
*Status: 100% Complete & Verified on Physical Android Hardware*
- **Home Screen (Screen 1):**
  - Total Balance glass card with Income, Expenses, and Saved columns.
  - Live AI Insight banner with sparkle icon and overrun predictive warnings.
  - Spending by Category horizontal carousel with custom painter icons.
  - Recent transactions list with day separators (Today, Yesterday) and signed amount formatting.
- **Transaction Details & AI Receipt Scan (Screen 2):**
  - Merchant title, avatar, visit count, and category chips.
  - AI receipt scan paper card with itemized line items, subtotal, tax, and total.
  - Fullscreen receipt zoom viewer and similar transactions timeline.
- **Spending Insights & Analytics (Screen 3):**
  - Month/Year dropdown pill and segmented control (Week / Month / Year).
  - 2x2 Stat cards: Total Spent, Daily Average, Biggest Category, AI Saving Found.
  - Cubic Bezier `AreaLineChart` with gradient fill and interactive touch scrubber tooltip.
  - Budget vs Actual progress bars with Over/Under status indicators.
- **Navigation & Supporting Screens:**
  - Profile, Cards, Search & Notifications tabs with floating `FrostedNavBar`.
  - Drift SQLite reactive database engine with offline-first local state.

### Phase 2: First-Time User Experience (FTUE) & Onboarding Engine 🚀 *(CURRENT FOCUS)*
*Status: Architecture & Specs Approved, Ready for Code Implementation*
- Zero-registration, 100% private, on-device onboarding wizard.
- Dedicated guarded route (`/onboarding`) preventing uninitialized app access.
- 5-step interactive page sequence with top animated progress pill bar.
- Currency selection (`$ USD`, `€ EUR`, `£ GBP`, `₹ INR`, `¥ JPY`, `$ CAD`, `$ AUD`).
- Interactive Salary Engine with live daily safe-to-spend allowance calculation.
- Choice of starting state: "Explore with Demo Data" vs "Start Clean Ledger".
- Confetti celebration launch animation and Day-1 guided home tour.

### Phase 3: Hardware Integration & On-Device Camera OCR *(UPCOMING - Q1)*
- Camera Viewfinder: Custom zero-Material camera interface with rectangular paper guide.
- On-Device OCR: Google ML Kit (`google_mlkit_text_recognition`) offline text extraction.
- Automatic edge detection, perspective correction, and auto-cropping for paper receipts.
- Local receipt compression (WebP) to minimize storage footprint.
- Optional Pro Cloud AI Parser: Gemini 1.5 Flash API connector for itemized breakdown.

### Phase 4: Biometric Security & App Lock *(UPCOMING - Q1)*
- Biometric Authentication: Face ID, Touch ID, and Android Biometrics via `local_auth`.
- Background Snapshot Shield: Privacy blur when app enters multitasking/app switcher.
- Secure storage for encryption keys and settings using `flutter_secure_storage`.
- Timeout lock: Configurable auto-lock after 1 minute, 5 minutes, or immediately on backgrounding.

### Phase 5: Cloud Backup, Multi-Device Sync & User Auth *(UPCOMING - Q2)*
- Sign in with Apple & Sign in with Google (optional; local mode remains primary).
- End-to-end encrypted cloud backup (Supabase / SQLite replication).
- Conflict-free offline synchronization with client-side resolution.
- Export & Data Portability: Encrypted JSON, CSV, and PDF tax report generation.

### Phase 6: Open Banking & Automated Feeds *(UPCOMING - Q2/Q3)*
- Read-only bank account connection via Plaid Link / Teller API.
- Automated background transaction ingestion (`WorkManager` / iOS `BackgroundTasks`).
- Smart Reconciliation: Automatically match scanned receipts with card transactions.
- SMS / Notification parser for regional markets without open banking support.

### Phase 7: Mobile OS Native Widgets & Notifications *(UPCOMING - Q3)*
- iOS Home Screen & Lock Screen Widgets (`WidgetKit`): Remaining daily budget, quick "+" action.
- Android Glance App Widgets: Live daily allowance meter and quick transaction logger.
- Scheduled Push Notifications: Payday deposit alert, weekly budget wrap-up, bill due dates.

### Phase 8: Store Publishing, Compliance & Monetization *(UPCOMING - Q4)*
- RevenueCat integration for "Pro ✦" tier (Cloud OCR, multi-currency, bank feeds).
- Legal compliance: App Store Guideline 5.1.1 Account Deletion, Privacy Policy, GDPR/CCPA.
- Store optimization: App icon variations, iPad/tablet 2-pane layouts, localized screenshots.
- Privacy-first telemetry & error reporting via Sentry / PostHog.

---

## Part 2: First-Time Install Experience (FTUE) — All Screens in Detail

Every single screen that appears from the second a user installs and opens the app for the first time.

```
┌────────────────────────────────────────────────────────────────────────┐
│ FIRST-TIME INSTALL SCREEN FLOW                                         │
│                                                                        │
│ [Screen 0: Brand Splash]                                               │
│        │ (auto-transition ~1200ms)                                     │
│        ▼                                                               │
│ [Screen 1: Welcome & Value Vision] ── "Get Started"                    │
│        │                                                               │
│        ▼                                                               │
│ [Screen 2: Currency Selection] ────── Choose "$ USD", "€ EUR", etc.    │
│        │                                                               │
│        ▼                                                               │
│ [Screen 3: Salary & Payday Engine] ── Live Daily Allowance Calculation │
│        │                                                               │
│        ▼                                                               │
│ [Screen 4: Experience Mode Choice] ── "Demo Data" vs "Clean Ledger"    │
│        │                                                               │
│        ▼                                                               │
│ [Screen 5: Celebration & Summary] ─── Confetti Particles + Launch CTA  │
│        │                                                               │
│        ▼                                                               │
│ [Screen 6: Guided Home Screen] ────── Day-1 Contextual Welcome Banner  │
└────────────────────────────────────────────────────────────────────────┘
```

---

### Screen 0: Native Launch & Brand Splash

*Purpose: First visual impression while database initializes and font cache warms up.*

- **Visual Assets & Illustration:**
  - Centered Brand Emblem (Vault Shield with Stylized Sparkle `✦`).
  - Framing: Deep obsidian gradient background (`#0B0D12` to `#161A22`).
  - Ambient Glow: Radial emerald/teal gradient halo behind the icon.
  - Dimensions: 120 x 120 pt centered vector emblem.
- **Animation & Motion:**
  - Emblem scales from 0.75 to 1.0 with soft spring overshoot (damping: 0.8, stiffness: 200).
  - Subtle breathing radial glow pulses between 30% and 50% opacity (1400ms ease-in-out).
  - Seamless alpha fade exit (250ms) into Screen 1 without any white flash or layout jump.
- **Text & Typography:**
  - App Title: **"Salary Tracker"** (24pt Inter Bold, tracking: -0.5px, `#FFFFFF`).
  - Subtitle: **"Private • Predictive • Personal"** (13pt Inter Regular, `#8E9BAE`).
  - Bottom Microcopy: **"v1.0 • Encrypted On-Device"** (11pt Inter Medium, `#525C6C`).
- **Buttons & Controls:**
  - *None* (Automatic non-interactive transition after 1000–1200ms once local DB initializes).

---

### Screen 1: Welcome & Value Vision (Zero-Registration Introduction)

*Purpose: Build instant trust, explain the signature "Daily Safe-to-Spend" concept, and assure the user that their data is 100% private with no mandatory account creation.*

- **Visual Assets & Illustration:**
  - Primary Visual: [`welcome_vault.jpg`](file:///d:/Flutter/BUget%20Tracker/salary_tracker/assets/illustrations/welcome_vault.jpg).
  - Artwork Description: 3D dark-mode vault cylinder surrounded by glowing emerald coins, floating credit cards, and sparkling ambient light.
  - Container: 240pt tall `GlassSurface` card with rounded corners (r: 28pt), hairline border (0.5pt, `#FFFFFF` at 12% opacity), and soft drop shadow.
  - Trust Badge Icon: Custom vector lock icon (16x16pt) inside a pill badge.
- **Animation & Motion:**
  - Top Progress Bar slides down from top (`AppMotion.enterDuration`, 240ms).
  - Vault Card floats down with subtle ease-out spring (stiffness: 180, damping: 0.85).
  - Text elements stagger upward with 40ms sequential delays.
  - Idle Motion: Subtle levitation on the vault card (4px up/down over 3 seconds).
  - Button Press: `Pressable` scale down to 0.97 + opacity 0.85 in 90ms.
  - Haptics: `AppHaptics.selectionClick()` on tap.
- **Text & Typography:**
  - Step Indicator: **"STEP 1 OF 5"** (11pt Inter Bold, uppercase, tracking: 1.2px, `#10B981`).
  - Privacy Pill: **"🔒 100% On-Device & Private. Zero Cloud Lock-In."** (12pt Inter SemiBold).
  - Main Headline: **"Master Your Paycheck"** (32pt Inter ExtraBold, tracking: -1.0px, `#FFFFFF`).
  - Subtitle: **"Know exactly what you can safely spend every single day until your next payday, without stressing over complex spreadsheets."** (15pt Inter Regular, `#94A3B8`, line height: 1.45).
  - Feature Bullets:
    - ✦ Real-time Daily Allowance calculator
    - ✦ Smart AI auto-categorization & receipt scanner
    - ✦ Works 100% offline — your money data stays on your phone
- **Buttons & Controls:**
  - **Primary CTA Button:**
    - Label: **"Get Started →"**
    - Style: `AppButton.primary` (Solid Ink/White, 52pt height, full width).
    - Action: Navigates forward to Step 2 with spring slide.
  - **Secondary Action (Ghost):**
    - Label: **"Already have a backup? Restore Data"**
    - Style: `AppButton.ghost` (Underline text button, 40pt height).
    - Action: Opens local file picker for SQLite backup restore.

---

### Screen 2: Currency & Regional Preferences

*Purpose: Establish active currency symbol and formatting upfront so all calculations, cards, and inputs reflect the user's local economy.*

- **Visual Assets & Illustration:**
  - Header Icon: Glowing Currency Globe / Coin Stack vector icon inside a 48pt frosted circle.
  - Live Preview Card: Floating `GlassSurface` card displaying dynamic formatted sample figures.
  - Grid Icons: High-contrast circular currency tokens (`$`, `€`, `£`, `₹`, `¥`, `₩`, `₣`).
- **Animation & Motion:**
  - Selection Animation: When a currency pill is tapped, the selected card springs up by 2px, its border lights up in emerald (`#10B981`), and a checkmark badge pops in.
  - Dynamic Text Morph: The Live Preview Card numbers instantly crossfade-morph to show the selected symbol and local separator rules:
    - Tapping `$` → `$1,250.00`
    - Tapping `€` → `1.250,00 €`
    - Tapping `₹` → `₹1,250.00`
  - Haptics: `AppHaptics.selectionClick()` on every selection change.
- **Text & Typography:**
  - Step Indicator: **"STEP 2 OF 5"** (11pt Inter Bold, `#10B981`).
  - Main Headline: **"Choose Your Currency"** (26pt Inter Bold, `#FFFFFF`).
  - Subtitle: **"Select your primary currency. All balances, transaction amounts, and daily budgets will be formatted with this symbol."** (14pt Inter Regular, `#94A3B8`).
  - Selection Grid Options (2 columns):
    - `[ $ ]` USD — United States Dollar
    - `[ € ]` EUR — Eurozone Euro
    - `[ £ ]` GBP — British Pound
    - `[ ₹ ]` INR — Indian Rupee
    - `[ ¥ ]` JPY — Japanese Yen
    - `[ $ ]` CAD — Canadian Dollar
    - `[ $ ]` AUD — Australian Dollar
    - `[ 🌐 ]` More / Custom Currency...
  - Live Preview Box:
    - Header: **"SAMPLE FORMAT DISPLAY"**
    - Large Value: **"$1,250.00"** (`AmountText` format with bold whole numbers and lighter cents)
    - Microcopy: **"Positive amounts show +$1,250.00 • Expenses show -$42.50"**
- **Buttons & Controls:**
  - **Back Button (Top Left):** `CircleIconButton` with left arrow (44pt circle, pops back to Step 1).
  - **Progress Bar:** 5-segment pill bar with Step 2 filled.
  - **Primary CTA Button:**
    - Label: **"Continue to Salary Setup →"**
    - Style: `AppButton.primary` (52pt height).
    - State: Active immediately (defaults to `$` USD).
    - Action: Saves selected currency into draft state and advances to Step 3.

---

### Screen 3: Salary & Pay Schedule (The Core Engine)

*Purpose: Capture net take-home salary, pay frequency, and payday to immediately power the app's signature algorithm: the Daily Safe-to-Spend Allowance.*

- **Visual Assets & Illustration:**
  - Primary Visual: [`salary_growth.jpg`](file:///d:/Flutter/BUget%20Tracker/salary_tracker/assets/illustrations/salary_growth.jpg).
  - Artwork Description: 3D neon graph trajectory with glowing calendar badge and currency coins.
  - Live Allowance Card: `GlassSurface` card with glowing border and dynamic calculation meter.
  - Interactive Segmented Control: 3-way sliding pill (`Monthly` / `Bi-Weekly` / `Weekly`).
- **Animation & Motion:**
  - Live Count-Up Animation: As the user types their salary into the keypad/field, the "Daily Safe-to-Spend" number actively counts up in real time (e.g. `$0.00` → `$145.16/day`) using an ease-out rolling number animation.
  - Segmented Sliding Thumb: Spring animation (stiffness: 300, damping: 0.8) when toggling between "Monthly", "Bi-Weekly", and "Weekly".
  - Glow Pulse: When `monthlyNet > 0`, the preview card border pulses with a soft green glow.
  - Continue Button State: Smoothly transitions from disabled (0.35 opacity) to fully active when a non-zero salary is entered.
- **Text & Typography:**
  - Step Indicator: **"STEP 3 OF 5"** (11pt Inter Bold, `#10B981`).
  - Main Headline: **"Your Income & Payday"** (26pt Inter Bold, `#FFFFFF`).
  - Subtitle: **"Enter your take-home pay so we can calculate exactly how much you can spend per day."** (14pt Inter Regular, `#94A3B8`).
  - Input Field 1:
    - Label: **"Net Monthly Take-Home Pay (After Taxes)"**
    - Prefix: Selected currency symbol (e.g. `$`)
    - Placeholder: `0.00`
    - Helper Text: *"Use your actual deposited amount per month."*
  - Input Field 2:
    - Label: **"Pay Frequency"**
    - Segment Options: `[ Monthly ]` `[ Bi-Weekly ]` `[ Weekly ]`
  - Input Field 3:
    - Label: **"Payday Date"**
    - Selector: Horizontal scrollable number strip (Day 1 through Day 31)
    - Selected Display: *"25th of every month (in 20 days)"*
  - Input Field 4 (Optional):
    - Label: **"Employer / Company Name"**
    - Placeholder: *"e.g. Google, Acme Corp, or Freelance"*
  - Live Calculation Feedback Box:
    - Title: **"✨ YOUR DAILY SAFE-TO-SPEND ALLOWANCE"**
    - Display Amount: **"$150.00 / day"** (Large 28pt tabular figure)
    - Explainer: *"Based on $4,500.00 net pay across 30 days in this pay cycle."*
- **Buttons & Controls:**
  - **Back Button (Top Left):** `CircleIconButton` (returns to Step 2).
  - **Progress Bar:** 5-segment pill bar with Step 3 filled.
  - **Custom Number Keypad / AppTextField:** Fast, frictionless numeric entry with haptics.
  - **Primary CTA Button:**
    - Label: **"Continue →"**
    - Style: `AppButton.primary`.
    - State: Enabled only when Net Salary > 0.
    - Action: Validates inputs, saves to draft, advances to Step 4.

---

### Screen 4: Starting Experience Mode (Playground vs Clean Ledger)

*Purpose: Give the user full control over whether they want to explore a rich populated demo environment or start with a brand new, empty ledger.*

- **Visual Assets & Illustration:**
  - Two Large Interactive Mode Selection Cards (`GlassSurface` with radio rings):
    - **Option A (Demo Data Card):**
      - Mini visual illustration showing vibrant category charts, transaction tiles, and AI receipt badge.
      - Glowing badge: `✦ POPULAR FOR EXPLORING`
    - **Option B (Clean Ledger Card):**
      - Minimalist visual illustration showing a clean notebook, fresh checking account, and $0.00 balance card.
      - Badge: `FRESH SLATE`
- **Animation & Motion:**
  - Selection Flip: Tapping a card triggers a spring scale-up (1.02x) on the active card and dims the unselected card to 0.55 opacity.
  - Radio Circle: Spring-filled center dot with checkmark pop-in (120ms spring).
  - Haptics: `AppHaptics.selectionClick()` on selection.
- **Text & Typography:**
  - Step Indicator: **"STEP 4 OF 5"** (11pt Inter Bold, `#10B981`).
  - Main Headline: **"How would you like to start?"** (26pt Inter Bold, `#FFFFFF`).
  - Subtitle: **"Choose whether to explore with realistic sample data or begin fresh with your own numbers."** (14pt Inter Regular, `#94A3B8`).
  - Card 1 (Demo Mode):
    - Title: **"Explore with Demo Playground"**
    - Badge: `RECOMMENDED ✦`
    - Description: *"Pre-loads sample checking accounts, recent transactions, spending charts, and an AI-scanned receipt. Perfect for seeing the full power of the app immediately."*
    - Feature List:
      - ✓ Pre-loaded spending trends & category charts
      - ✓ Sample AI receipt scan with line items
      - ✓ Can be cleared or reset in Settings anytime
  - Card 2 (Clean Mode):
    - Title: **"Start Clean Ledger"**
    - Badge: `FOR EXPERIENCED TRACKERS`
    - Description: *"Initializes your primary accounts and standard budget categories with a $0 balance. Ready for you to log your first real expense."*
    - Feature List:
      - ✓ Zero dummy transactions
      - ✓ Clean, empty charts waiting for real input
      - ✓ Immediate setup with your salary config
- **Buttons & Controls:**
  - **Back Button (Top Left):** `CircleIconButton` (returns to Step 3).
  - **Progress Bar:** 5-segment pill bar with Step 4 filled.
  - **Primary CTA Button:**
    - Label: **"Create My Dashboard →"**
    - Style: `AppButton.primary`.
    - Action: Commits settings to SQLite, runs chosen database seed routine, and advances to Screen 5.

---

### Screen 5: Setup Confirmation & Launch Celebration

*Purpose: Celebrate setup completion, provide a concise summary of what was configured, and build excitement right before entering the core dashboard.*

- **Visual Assets & Illustration:**
  - Primary Visual: [`all_set_check.jpg`](file:///d:/Flutter/BUget%20Tracker/salary_tracker/assets/illustrations/all_set_check.jpg).
  - Artwork Description: Glowing 3D celebratory checkmark badge encased in frosted crystal glass, surrounded by floating gold sparks and emerald light trails.
  - Particle System: `CustomPainter` confetti burst (30 colorful falling shards of green, gold, white, and teal).
  - Summary Card: Premium `GlassSurface` card detailing the user's active configuration.
- **Animation & Motion:**
  - Confetti Explosion: On screen entry, 30 particle vectors explode outward from the center with randomized velocities and gravity deceleration over 2000ms.
  - Badge Pop: The checkmark badge scales in with bouncy spring physics (overshoot 1.15x).
  - Summary Card Slide: Slides up from bottom with `easeOutCubic` (`AppMotion.enterDuration`, 300ms).
  - Haptics: `AppHaptics.mediumImpact()` on screen load to signal major milestone achievement.
- **Text & Typography:**
  - Step Indicator: **"STEP 5 OF 5 • COMPLETED"** (11pt Inter Bold, `#10B981`).
  - Main Headline: **"You're All Set!"** (30pt Inter ExtraBold, `#FFFFFF`).
  - Subtitle: **"Your personalized financial command center is ready."** (15pt Inter Regular, `#94A3B8`).
  - Summary Glass Card:
    - Line 1: `Configured Salary:  [Symbol]4,500.00 / month`
    - Line 2: `Pay Frequency:      Monthly (Next: 25th of month)`
    - Line 3: `Daily Allowance:    [Symbol]150.00 / day safe-to-spend`
    - Line 4: `Initial Database:   Demo Playground (or Clean Ledger)`
    - Line 5: `Data Privacy:       Encrypted On-Device SQLite`
  - Reassurance Microcopy: *"You can adjust your salary, add bank accounts, or edit categories anytime from the Profile tab."*
- **Buttons & Controls:**
  - **Progress Bar:** All 5 segments fully illuminated (100% green bar).
  - **Primary CTA Button:**
    - Label: **"Enter Financial Dashboard 🚀"**
    - Style: `AppButton.primary` (High-contrast ink button, 56pt height).
    - Action: Sets `onboarding_completed = true` in `AppSettings`, replaces route to `/`, and enters the Home Dashboard.

---

### Screen 6: First-Run Guided Home Screen (Day-1 Experience)

*Purpose: Avoid "blank screen confusion" when the user lands on the Home Dashboard for the very first time. Guides them to their next high-value action.*

- **Visual Assets & Illustration:**
  - Contextual Welcome Glass Banner: Positioned at the top of the Home feed, right below the balance card.
  - Icons: Sparkle (`✦`) icon, wave emoji (`👋`), and small camera receipt icon.
  - Nav Bar Spotlight: Subtle breathing glow halo around the center floating `+` button on the `FrostedNavBar`.
- **Animation & Motion:**
  - Banner Reveal: Gentle downward spring slide on home screen load (stiffness: 220, damping: 0.8).
  - Spotlight Pulse: The center `+` button has a repeating breathing halo (scale 1.0 to 1.08, opacity 0.4 to 0.8 over 1800ms) to attract attention without being intrusive.
  - Dismiss Action: Swiping right or tapping "Dismiss" smoothly folds the banner away (200ms).
- **Text & Typography:**
  - Contextual Banner Header: **"👋 Welcome to your new financial headquarters!"**
  - Banner Body Text: **"We've calculated your starting daily safe-to-spend allowance. Tap the '+' button below to log your first expense, or tap the Camera icon to scan a paper receipt with AI."**
  - Quick Action Chips:
    - `[ + Log Expense ]`
    - `[ 📷 Scan Receipt ]`
    - `[ ✕ Dismiss Guide ]`
- **Buttons & Controls:**
  - **Banner Action 1:** "Log First Expense" → Opens custom `AmountKeypad` bottom sheet.
  - **Banner Action 2:** "Scan Receipt" → Opens Camera / Receipt Scanner modal.
  - **Banner Dismiss:** "Dismiss" → Sets `day1_banner_dismissed = true` in `AppSettings`, persisting dismissal so it never annoys the user again.
  - **Floating FrostedNavBar:** 5 tabs (Home, Insight, `+`, Cards, Profile).

---

## Part 3: Architecture & Developer Implementation Checklist

### Files Created / Modified for FTUE:
1. `lib/domain/repositories/i_finance_repository.dart`
   - `isOnboardingCompleted()`, `setOnboardingCompleted(bool)`
   - `getAppSetting(key)`, `setAppSetting(key, value)`
   - `seedInitialFreshData(SalaryProfile)`
2. `lib/data/repositories/finance_repository.dart`
   - SQLite implementations on `AppSettings` table
3. `lib/features/onboarding/models/onboarding_state.dart`
   - State holding selected currency, salary, frequency, payday, and demo mode.
   - `calculateDailyBudgetMinor()` algorithm.
4. `lib/features/onboarding/providers/onboarding_provider.dart`
   - Riverpod `StateNotifier` for wizard draft values.
5. `lib/features/onboarding/screens/onboarding_screen.dart`
   - `PageView` with 5 wizard steps, top animated segmented bar, and spring transitions.
6. `lib/features/onboarding/widgets/`
   - `step_welcome_view.dart` (Welcome Vault & Trust Badge)
   - `step_currency_view.dart` (Interactive Currency Grid & Live Formatter)
   - `step_salary_view.dart` (Salary Keypad, Frequency Switcher, Daily Allowance Meter)
   - `step_mode_view.dart` (Demo Playground vs Clean Ledger selection)
   - `step_celebration_view.dart` (Confetti CustomPainter & Summary Glass Card)
7. `lib/app/router.dart`
   - Guarded route `/onboarding` with automatic redirect for first-time users.
8. `lib/features/home/widgets/day1_welcome_banner.dart`
   - Dismissible contextual banner on `HomeScreen` for Day-1 guidance.

### Test Verification Suite:
- `test/data/onboarding_settings_test.dart` (DB persistence & fresh seeding)
- `test/features/onboarding/onboarding_state_test.dart` (Daily allowance calculations)
- `test/features/onboarding/onboarding_screen_test.dart` (Step progression & validation)
- `test/integration/ftue_flow_integration_test.dart` (Full zero-to-dashboard workflow)
