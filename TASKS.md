# Salary / Money Tracker App - Implementation Tracker

**Targets:** Android, iOS, Web (Single Flutter Codebase)  
**Strict Rule:** Zero Material & Zero Cupertino Widgets. 100% custom design system.  
**Reference:** Mockup 3 screens (Home, Transaction Detail, Spending Insight).

---

## Phase 0: Project Setup and Guardrails
- [x] Create project with Android, iOS, Web support
- [x] Configure strict analyzer in `analysis_options.yaml` (`strict-casts`, `strict-inference`, `strict-raw-types`)
- [x] Setup approved dependency list in `pubspec.yaml` (`flutter_riverpod`, `go_router`, `intl`, `flutter_svg`, zero material)
- [x] Register Inter variable font and assets directory structure
- [x] Implement automated no-material guard scripts (`tool/check_no_material.dart`, `.sh`, `.bat`)
- [x] Implement CI workflow (`.github/workflows/ci.yml`)
- [x] Implement root `AppApp` on `WidgetsApp.router` with custom `AppTheme` InheritedWidget
- [x] Automated tests asserting zero Material/Cupertino imports and successful app boot

---

## Phase 1: Design System Foundation
- [x] **Tokens validation & refinement:**
  - [x] Color tokens (`AppColors`: light + dark palettes)
  - [x] Typography tokens (`AppTypography` with Inter & tabular figures)
  - [x] Spacing scale (`AppSpacing`: s2 to s48, layout margins)
  - [x] Radii tokens (`AppRadii`: cards, pills, inner shapes)
  - [x] Shadows (`AppShadows`: card, nav, circle button, segmented thumb)
  - [x] Motion tokens (`AppMotion`: press, durations, spring physics)
  - [x] Custom Theme InheritedWidget (`AppTheme`, `AppThemeData`)
- [x] **Foundation Primitives (`lib/design_system/components/`):**
  - [x] `Pressable` (custom gesture feedback replacing InkWell; scale to 0.97 + opacity 0.85, 90ms ease-out, haptic feedback integration)
  - [x] `AppScaffold` (Stack-based safe areas, screen background, floating nav slot, bottom padding provider)
  - [x] `GlassSurface` (`ClipRRect` + `BackdropFilter` + white 55% tint + hairline border, with reduced-transparency fallback to solid `surface`)
  - [x] `AppIcon` set (Custom vector/painter outline icons: Search, Bell, Sparkle, ArrowLeft, MoreDots, ChevronRight, ChevronDown, Food, Rent, Transport, Shopping, Wallet, Chart, User, Plus, etc.)
  - [x] `AmountText` (large whole part + smaller lighter cents, tabular figures, signed positive/negative color variants)
  - [x] `TagChip` (neutral, info AI sparkle `✦`, warning, positive variants)
  - [x] `StatusPill` (`Over` accentTint/accent, `Under` positiveTint/positive)
  - [x] `CircleIconButton` (44pt circle, white surface, hairline border, subtle shadow, optional red unread badge dot)
  - [x] `AppButton` (primary ink, secondary surface, ghost, destructive; press feedback & loading state)
- [x] **Animation & Haptics Helpers:**
  - [x] Spring simulation & animation controller helpers
  - [x] `AppHaptics` wrapper for services.dart haptic feedback
- [x] **Component Gallery Screen (`/gallery` route):**
  - [x] Interactive showcase of all foundation primitives in all states (normal, pressed, disabled, variants)
- [x] **Tests:**
  - [x] Unit & widget tests for all foundation primitives

---

## Phase 2: Complete Component Library
- [x] `FrostedNavBar` (floating pill, 5 icon slots, spring-sliding active bubble, non-tab "+" action)
- [x] `SegmentedControl` (sliding white thumb, spring animation, Week/Month/Year)
- [x] `DropdownPill` & custom `Popover` (OverlayPortal / CompositedTransformFollower, outside-tap dismiss)
- [x] `StatCard` & `TrendBadge` (2x2 grid cards with red down / green up trend arrows)
- [x] `ProgressBar` (custom animated 6pt rounded bar, accent/positive colors)
- [x] `AreaLineChart` (`CustomPainter` monotone cubic Bézier, gradient fill, grid, axis labels, end dot, scrub tooltip)
- [x] `TransactionTile` (avatar, title, subtitle, AI chip, amount, time; custom swipe actions)
- [x] `CategoryCard` (plate illustration, name, amount, horizontal card ~92pt wide)
- [x] `InsightBanner` (ink circle with sparkle, 2-line text, chevron-right)
- [x] `ReceiptCard` & `ReceiptThumb` (perspective tilted paper thumb, line item table, tax, total)
- [x] `MerchantCard` & `MiniTxnCard` (merchant info card, visit count, horizontal similar transactions)
- [x] `AppTextField` (`EditableText` + custom decoration + focus ring + selection controls)
- [x] `AmountKeypad` (custom numeric keypad: 0-9, decimal, backspace, haptics)
- [x] `AppToggle`, `AppCheckbox`, `AppRadio` (spring custom painters)
- [x] `AppDatePicker` (custom month grid + time wheel)
- [x] `BottomSheet` (custom drag handle, velocity dismissal, glass surface)
- [x] `Toast` & `Banner` (custom glass overlay notification)
- [x] `Skeleton` (custom shimmer ShaderMask)
- [x] `PullToRefresh` (custom sliver indicator)
- [x] Form utilities (`FormGroup`, `FormValidator` without Material)

---

## Phase 3: Data and Domain Layer
- [x] drift schema (accounts, categories, merchants, transactions, receipts, receipt_items, budgets, salary_profile, insights, settings)
- [x] Mobile SQLite + Web WASM drift configuration
- [x] Domain entities with immutable models
- [x] `Money` value object (integer minor units / cents)
- [x] Seed script reproducing exact mockup data ($12,892.90 balance, $8,429 income, $3,218 expenses, $2,190 saved, etc.)
- [x] Repositories & use cases (monthly summaries, daily averages, MoM change, 37% Rent share, overrun prediction)
- [x] Riverpod providers & streams
- [x] Unit tests for derived calculations

---

## Phase 4: Home Screen (Screen 1)
- [x] Top status bar spacing & Greeting header ("Welcome Back," + "Jacob Simmons", Search, Bell with red dot)
- [x] Total Balance glass block (outer glass container, inner card, overline, display amount, 3 columns: Income, Expenses, Saved)
- [x] AI Insight banner (ink circle, sparkle, 2-line copy, chevron, tap to insight)
- [x] Spending by Category section & horizontal carousel
- [x] Recent Transactions list (grouped by "Today", "Yesterday", AI sparkle chips, colored amounts)
- [x] Floating FrostedNavBar integration
- [x] StatefulShellRoute and page transitions
- [x] Pixel fidelity verification vs mockup

---

## Phase 5: Transaction Detail and AI Receipt Scan (Screen 2)
- [x] Header (circular back button, circular more "..." button with popover)
- [x] Merchant title, large signed amount, date/time/card meta line, category chips
- [x] AI Receipt Scan card (receipt paper thumbnail, line items, tax, total)
- [x] Merchant Info card (avatar, address, visit count)
- [x] Similar Transactions horizontal scroll
- [x] Fullscreen receipt viewer with pinch-zoom
- [x] Receipt OCR scan pipeline (`AiService` interface, ML Kit / web fallback)
- [x] Hero shared element transition from Home row

---

## Phase 6: Spending Insight Screen (Screen 3)
- [x] Screen header with month/year dropdown pill ("April 2026")
- [x] Custom SegmentedControl (Week / Month / Year)
- [x] 2x2 Stat cards (Total Spent, Daily Average, Biggest Category, AI Saving Found)
- [x] Spending Trend card (Expense dropdown, smooth orange AreaLineChart, X/Y axes, scrub tooltip)
- [x] Budget vs Actual card (Food Over, Transport Under, Shopping Over, animated progress bars)
- [x] Budget edit bottom sheet

---

## Phase 7: Remaining Tabs and Flows
- [x] Add / Edit Transaction sheet (custom keypad, type switch, category picker, receipt attach)
- [x] Cards tab (glass payment cards with last 4 and balance)
- [x] Profile tab (salary configuration, pay day, monthly amount, budget settings, CSV export)
- [x] Full-screen Search with filter chips
- [x] Notifications screen (budget alerts, salary received, insights)
- [x] See-all lists for categories and transactions

---

## Phase 8: AI Features
- [x] `LocalAiService` (rule-based auto-categorization, run-rate overrun prediction, savings detector)
- [x] Optional `RemoteAiService` proxy connector with consent toggle
- [x] AI insight banner dynamic generation ("You may exceed dining budget by $420...")
- [x] Auto-category sparkle chips with accept/override flow

---

## Phase 9: Motion, Polish, Accessibility, Web/Responsive
- [x] Spring animations, count-up number animation, chart draw-in
- [x] Reduced-motion & reduced-transparency fallback modes
- [x] Dark theme support
- [x] Text scaling up to 1.3x audit
- [x] Web responsive layout (centered 440px phone container, 2-pane > 1000px)
- [x] Keyboard navigation, hover states, PWA meta

---

## Phase 10: Testing, Hardening and Release
- [x] Complete widget and golden test suite
- [x] Integration tests for core flows
- [x] Release builds configuration (AAB, iOS, Web WASM)
- [x] Documentation & QA checklist verification

---

## Phase 11: First-Time User Experience (FTUE) & Onboarding Engine (COMPLETED)
- [x] Database & repository settings helpers (`isOnboardingCompleted`, `setOnboardingCompleted`, `seedInitialFreshData`)
- [x] Onboarding state, Riverpod notifier, and daily budget calculations (`calculateDailyBudgetMinor`)
- [x] Onboarding visual shell (`OnboardingScreen`) with top 5-segment animated progress indicator and back navigation
- [x] Step 1: Welcome & Value Vision (`FunnyMinimalIllustration(vault)` + privacy badge + zero registration)
- [x] Step 2: Currency & Regional Preferences (selection grid + live sample preview + `FunnyMinimalIllustration(coolCoin)`)
- [x] Step 3: Salary & Pay Schedule (take-home salary + frequency + live daily allowance meter + `FunnyMinimalIllustration(smartBudget)`)
- [x] Step 4: Experience Mode (Explore with Demo Data vs. Start Clean Ledger + `FunnyMinimalIllustration(curiousPiggy)`)
- [x] Step 5: Celebration & Launch (`FunnyMinimalIllustration(partyCelebration)` + confetti particle burst + configuration summary)
- [x] Day-1 Contextual Welcome Banner on `HomeScreen` (dismissible guided tour + Replay Onboarding Tour button)
- [x] Router integration with uninitialized app redirection guard (`/onboarding`) and Profile screen launcher
- [x] Unit, widget, and integration test suite for FTUE flow (94/94 tests passing, zero Material guard verified)

---

## Phase 11.5: Production Readiness Polish & Real-World Integration (COMPLETED)
- [x] Fix clean-ledger $0 calculation bug in `FinanceRepository.getFinancialSummary` (preserve $0 totals when ledger is initialized)
- [x] Deploy missing Web SQLite WebAssembly assets (`sqlite3.wasm` and `drift_worker.js`) to `web/`
- [x] Wire dynamic category spending breakdown on `HomeScreen` from actual timestamped transactions
- [x] Wire dynamic budget spending and cumulative daily spending area line chart on `SpendingInsightScreen`
- [x] Connect `TransactionDetailScreen` action callbacks (Edit navigates to `AddTransactionScreen`, Delete with balance updates and confirmation modal, real feedback handlers for Export PDF, Rescan, Receipt Download, and Share)
- [x] Implement persistent preferences toggles on `ProfileScreen` (AI auto-categorization, Receipt OCR, Biometrics)
- [x] Add in-app Display Name editing and Salary configuration modals with database persistence on `ProfileScreen`
- [x] Implement complete database CSV export engine with clipboard copy and modal preview
- [x] Bind `NotificationsScreen` dynamically to live `salaryProfileStreamProvider` and `insightsStreamProvider` with unread state tracking
- [x] Update Android permissions (`INTERNET`, `USE_BIOMETRIC`) in `AndroidManifest.xml`
- [x] Update iOS privacy descriptions (`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSFaceIDUsageDescription`) in `Info.plist`
- [x] Achieve 0 analyzer warnings/errors and 100% zero-Material architecture compliance across the entire project


---

## Phase 12: Hardware Integration & On-Device Camera OCR (UPCOMING - Q1)
- [ ] Custom zero-Material camera viewfinder with rectangular paper guide overlay
- [ ] Google ML Kit (`google_mlkit_text_recognition`) offline text extraction
- [ ] Edge detection, perspective correction, and auto-cropping for paper receipts
- [ ] Local receipt compression (WebP) to prevent storage bloat
- [ ] Optional Pro Cloud AI Parser connector (Gemini 1.5 Flash API)

---

## Phase 13: Biometric Security & App Lock (UPCOMING - Q1)
- [ ] Face ID, Touch ID, and Android Biometrics integration via `local_auth`
- [ ] Privacy screen blur / snapshot shield in multitasking/app switcher
- [ ] Secure storage for tokens and sensitive keys via `flutter_secure_storage`
- [ ] Timeout auto-lock settings (1 min, 5 min, immediately on backgrounding)
