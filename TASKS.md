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
- [ ] `FrostedNavBar` (floating pill, 5 icon slots, spring-sliding active bubble, non-tab "+" action)
- [ ] `SegmentedControl` (sliding white thumb, spring animation, Week/Month/Year)
- [ ] `DropdownPill` & custom `Popover` (OverlayPortal / CompositedTransformFollower, outside-tap dismiss)
- [ ] `StatCard` & `TrendBadge` (2x2 grid cards with red down / green up trend arrows)
- [ ] `ProgressBar` (custom animated 6pt rounded bar, accent/positive colors)
- [ ] `AreaLineChart` (`CustomPainter` monotone cubic Bézier, gradient fill, grid, axis labels, end dot, scrub tooltip)
- [ ] `TransactionTile` (avatar, title, subtitle, AI chip, amount, time; custom swipe actions)
- [ ] `CategoryCard` (plate illustration, name, amount, horizontal card ~92pt wide)
- [ ] `InsightBanner` (ink circle with sparkle, 2-line text, chevron-right)
- [ ] `ReceiptCard` & `ReceiptThumb` (perspective tilted paper thumb, line item table, tax, total)
- [ ] `MerchantCard` & `MiniTxnCard` (merchant info card, visit count, horizontal similar transactions)
- [ ] `AppTextField` (`EditableText` + custom decoration + focus ring + selection controls)
- [ ] `AmountKeypad` (custom numeric keypad: 0-9, decimal, backspace, haptics)
- [ ] `AppToggle`, `AppCheckbox`, `AppRadio` (spring custom painters)
- [ ] `AppDatePicker` (custom month grid + time wheel)
- [ ] `BottomSheet` (custom drag handle, velocity dismissal, glass surface)
- [ ] `Toast` & `Banner` (custom glass overlay notification)
- [ ] `Skeleton` (custom shimmer ShaderMask)
- [ ] `PullToRefresh` (custom sliver indicator)
- [ ] Form utilities (`FormGroup`, `FormValidator` without Material)

---

## Phase 3: Data and Domain Layer
- [ ] drift schema (accounts, categories, merchants, transactions, receipts, receipt_items, budgets, salary_profile, insights, settings)
- [ ] Mobile SQLite + Web WASM drift configuration
- [ ] Domain entities with immutable models
- [ ] `Money` value object (integer minor units / cents)
- [ ] Seed script reproducing exact mockup data ($12,892.90 balance, $8,429 income, $3,218 expenses, $2,190 saved, etc.)
- [ ] Repositories & use cases (monthly summaries, daily averages, MoM change, 37% Rent share, overrun prediction)
- [ ] Riverpod providers & streams
- [ ] Unit tests for derived calculations

---

## Phase 4: Home Screen (Screen 1)
- [ ] Top status bar spacing & Greeting header ("Welcome Back," + "Jacob Simmons", Search, Bell with red dot)
- [ ] Total Balance glass block (outer glass container, inner card, overline, display amount, 3 columns: Income, Expenses, Saved)
- [ ] AI Insight banner (ink circle, sparkle, 2-line copy, chevron, tap to insight)
- [ ] Spending by Category section & horizontal carousel
- [ ] Recent Transactions list (grouped by "Today", "Yesterday", AI sparkle chips, colored amounts)
- [ ] Floating FrostedNavBar integration
- [ ] StatefulShellRoute and page transitions
- [ ] Pixel fidelity verification vs mockup

---

## Phase 5: Transaction Detail and AI Receipt Scan (Screen 2)
- [ ] Header (circular back button, circular more "..." button with popover)
- [ ] Merchant title, large signed amount, date/time/card meta line, category chips
- [ ] AI Receipt Scan card (receipt paper thumbnail, line items, tax, total)
- [ ] Merchant Info card (avatar, address, visit count)
- [ ] Similar Transactions horizontal scroll
- [ ] Fullscreen receipt viewer with pinch-zoom
- [ ] Receipt OCR scan pipeline (`AiService` interface, ML Kit / web fallback)
- [ ] Hero shared element transition from Home row

---

## Phase 6: Spending Insight Screen (Screen 3)
- [ ] Screen header with month/year dropdown pill ("April 2026")
- [ ] Custom SegmentedControl (Week / Month / Year)
- [ ] 2x2 Stat cards (Total Spent, Daily Average, Biggest Category, AI Saving Found)
- [ ] Spending Trend card (Expense dropdown, smooth orange AreaLineChart, X/Y axes, scrub tooltip)
- [ ] Budget vs Actual card (Food Over, Transport Under, Shopping Over, animated progress bars)
- [ ] Budget edit bottom sheet

---

## Phase 7: Remaining Tabs and Flows
- [ ] Add / Edit Transaction sheet (custom keypad, type switch, category picker, receipt attach)
- [ ] Cards tab (glass payment cards with last 4 and balance)
- [ ] Profile tab (salary configuration, pay day, monthly amount, budget settings, CSV export)
- [ ] Full-screen Search with filter chips
- [ ] Notifications screen (budget alerts, salary received, insights)
- [ ] See-all lists for categories and transactions

---

## Phase 8: AI Features
- [ ] `LocalAiService` (rule-based auto-categorization, run-rate overrun prediction, savings detector)
- [ ] Optional `RemoteAiService` proxy connector with consent toggle
- [ ] AI insight banner dynamic generation ("You may exceed dining budget by $420...")
- [ ] Auto-category sparkle chips with accept/override flow

---

## Phase 9: Motion, Polish, Accessibility, Web/Responsive
- [ ] Spring animations, count-up number animation, chart draw-in
- [ ] Reduced-motion & reduced-transparency fallback modes
- [ ] Dark theme support
- [ ] Text scaling up to 1.3x audit
- [ ] Web responsive layout (centered 440px phone container, 2-pane > 1000px)
- [ ] Keyboard navigation, hover states, PWA meta

---

## Phase 10: Testing, Hardening and Release
- [ ] Complete widget and golden test suite
- [ ] Integration tests for core flows
- [ ] Release builds configuration (AAB, iOS, Web WASM)
- [ ] Documentation & QA checklist verification
