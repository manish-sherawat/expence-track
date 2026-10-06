# Roadmap to Final Production Release
## Salary & Money Tracker — Path from Complete MVP to App Store / Play Store Launch

> **Current Status:**
> - Complete zero-Material custom design system & token engine
> - 100% test coverage across core flows (81/81 automated tests passing)
> - Drift SQLite database with seed data, reactive streams, and local state
> - Rule-based AI forecasting, receipt parser simulation, and overrun prediction
> - Light / Dark themes, accessibility modes, and web-responsive framing
> - Production APK built and verified on physical hardware

---

## 0. First-Time User Experience (FTUE) & Onboarding Engine (CURRENT FOCUS)
**Status: Fully Specified, Ready for Implementation**
- [ ] **Zero-Registration Local Onboarding:** Instant onboarding without cloud lock-in or account requirements.
- [ ] **Guarded Route (`/onboarding`):** Route redirection ensuring first-time users complete setup before landing on dashboard.
- [ ] **5-Step Interactive Wizard:** Top animated segmented pill progress bar with back-navigation.
- [ ] **Currency Selection:** Support for `$ USD`, `€ EUR`, `£ GBP`, `₹ INR`, `¥ JPY`, `$ CAD`, `$ AUD` with live formatting preview.
- [ ] **Interactive Salary Engine:** Live daily safe-to-spend allowance calculation with real-time count-up animation.
- [ ] **Experience Mode Selection:** Choice between "Explore with Demo Data" (playground) vs. "Start Clean Ledger".
- [ ] **Celebration & Guided Home:** Confetti particle launch animation and Day-1 contextual welcome banner on Home dashboard.

---

## 1. Real AI & Hardware Receipt Scanner (Camera OCR)
Currently, the receipt scanner uses simulated OCR (`LocalAiService`) with deterministic line item parsing.
- [ ] **Live Camera & Photo Library Integration:**
  - Add camera viewfinder with rectangular receipt guide overlay (using custom zero-Material camera preview or `image_picker`).
  - Edge detection & auto-cropping for paper receipts.
- [ ] **Production OCR Pipeline:**
  - **On-Device:** Integrate Google ML Kit (`google_mlkit_text_recognition`) for instantaneous offline text extraction without server cost.
  - **Cloud AI (Optional/Pro Tier):** Connect to Gemini 1.5 Flash / Google Cloud Document AI for advanced itemized receipt decomposition (store name, date, tax, discounts, line items, and payment method).
- [ ] **Receipt Storage & Compression:**
  - Compress scanned receipts locally (WebP format) to prevent bloating the phone's storage.
  - Cloud receipt image backup (AWS S3 or Cloudflare R2 with encrypted presigned URLs).

---

## 2. Bank Integration & Automated Transaction Feed (Optional / Pro Feature)
Currently, all transactions are entered manually or seeded via `MockupSeedData`.
- [ ] **Open Banking / Plaid Integration:**
  - Plaid Link or Teller API integration for direct read-only bank feed syncing (Chase, Bank of America, Wells Fargo, etc.).
  - Automatic transaction ingestion via scheduled background workers (`workmanager` for Android / Background Tasks for iOS).
- [ ] **Transaction Reconciliation:**
  - Auto-match physical receipt scans with pending or posted card transactions by date, amount, and last 4 digits.

---



## 4. App Security & Biometric Protection
Financial applications handle sensitive personal data and require dedicated privacy guards.
- [ ] **Biometric App Lock:**
  - Face ID, Touch ID, and Android Fingerprint / Biometric authentication on app launch or resume (`local_auth` styled with custom primitives).
  - Privacy screen blur / snapshot shield when the app is in the background or app switcher.
- [ ] **Secure Storage for Sensitive Tokens:**
  - Store API tokens, user session keys, and account identifiers using `flutter_secure_storage` (iOS Keychain & Android Keystore).

---

## 5. Native Platform Polish & Mobile Operating System Hooks
- [ ] **App Icon & Native Launch Splash Screen:**
  - Generate high-resolution adaptive app icons across all Android densities (`mipmap-xxxhdpi`) and iOS sizes (`AppIcon.appiconset`).
  - Configure native launch splash screens (`flutter_native_splash`) matching the app's `#0B0D12` dark / `#F5F6FA` light background to eliminate initial white flicker.
- [ ] **System Push Notifications:**
  - Firebase Cloud Messaging (FCM) or Apple APNs for real scheduled notifications:
    - Payday salary deposit confirmation.
    - Weekly spending recap and AI overrun warnings.
    - Bill due date reminders.
- [ ] **iOS & Android Home Screen Widgets:**
  - iOS WidgetKit & Android Glance widgets displaying current balance, remaining daily budget, and quick "+" add transaction shortcut.

---

---

## 7. App Store & Google Play Release Requirements (Compliance & Legal)
- [ ] **Legal Documents:**
  - Publicly hosted Privacy Policy URL (compliant with GDPR, CCPA, and App Store guidelines).
  - Terms of Service / End User License Agreement (EULA).
  - Financial Services Disclaimer: *"Salary Tracker is an expense tracking tool and does not provide certified financial, legal, or investment advice."*
- [ ] **Account Deletion Flow:**
  - In-app "Delete All Data & Account" button under Profile screen (mandatory for Apple App Store guideline 5.1.1).
- [ ] **In-App Review Prompt:**
  - Implement native store review prompt (`in_app_review`) triggered after meaningful milestones (e.g. after adding 10 transactions or 1 month of usage).
- [ ] **Release Signing & Store Assets:**
  - Generate release keystore for Android (`key.jks`) and configure `signingConfigs` in `android/app/build.gradle.kts`.
  - Apple Developer Account provisioning profiles & App Store Distribution certificates.
  - 6.7" & 6.5" iPhone screenshots, 10" iPad screenshots, Google Play feature graphics (1024x500), and store description copy.

---

## 8. Crash Reporting, Telemetry & Performance Monitoring
- [ ] **Crash Analytics:**
  - Integrate Sentry or Firebase Crashlytics to monitor unhandled exceptions and ANRs (Application Not Responding) in production.
  - Ensure financial amounts, bank account numbers, and personal names are sanitized/scrubbed from error breadcrumbs.
- [ ] **Product Analytics:**
  - Privacy-first analytics (PostHog or Mixpanel) to monitor feature usage (e.g., % of users scanning receipts vs typing manually).

---

## Prioritized Implementation Roadmap

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 0: First-Time User Experience (FTUE) (CURRENT FOCUS)  │
│ • Zero-Registration 5-Step Onboarding Wizard                │
│ • Local Currency Selection & Live Daily Allowance Engine    │
│ • Demo vs Clean Ledger Mode & Day-1 Welcome Guide           │
├─────────────────────────────────────────────────────────────┤
│ PHASE A: Native Launch Readiness (1–2 Days)                │
│ • Custom App Launcher Icons & Splash Screen                 │
│ • Android Keystore Signing & AAB Production Build           │
│ • Privacy Policy & Terms of Service Web Pages               │
├─────────────────────────────────────────────────────────────┤
│ PHASE B: Live Hardware Inputs (2–4 Days)                    │
│ • Real Camera Receipt Capture (ML Kit on-device OCR)        │
│ • Local Image Compression & File Storage                    │
│ • Biometric Lock (Face ID / Fingerprint via local_auth)     │

│ PHASE D: Store Publishing & Growth (Ongoing)                │
│ • App Store & Play Store Listing Assets & Screenshots       │
│ • Crashlytics & Privacy-Preserving Analytics                │
│ • Plaid Live Bank Feed Ingestion (Post-Launch Expansion)    │
└─────────────────────────────────────────────────────────────┘
```
