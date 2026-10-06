# Phase 12: Hardware Integration & On-Device Camera OCR Design Specification

- **Date**: 2026-10-06
- **Status**: Draft for User Review
- **Author**: Antigravity Assistant & Engineering Team
- **Target Application**: Salary Tracker (Zero Material, Zero Cupertino custom design system)

---

## 1. Executive Summary & Goals

Currently in the application, tapping "Scan" or "Rescan" in `AddTransactionScreen` simulates receipt parsing using static mock text inside `LocalAiService`.

Phase 12 transforms this into a true hardware-integrated, on-device document scanning and OCR pipeline. Users will be able to point their phone camera at physical paper receipts, obtain auto-detected boundaries and perspective-corrected crops, perform offline on-device text recognition, optionally enrich with Gemini 1.5 Flash cloud parsing when online, compress the receipt to WebP for minimal disk footprint, and auto-populate the transaction with merchant name, category, tax, and itemized lines.

### Core Architecture Highlights
1. **Native Document Scanner**: Utilize `google_mlkit_document_scanner` for Android & iOS to achieve automatic paper edge detection, perspective correction, shadow removal, multi-page / single-page mode, and flashlight control.
2. **Custom Zero-Material Post-Crop Review Screen**: 100% custom UI built without Material/Cupertino widgets, featuring an interactive receipt preview, animated neon scan-line beam, instant parsed breakdown preview, and one-tap approval.
3. **Dual OCR & Parsing Engine**:
   - **Offline-First**: `google_mlkit_text_recognition` runs on-device, feeding raw text blocks into `LocalAiService.parseReceiptText` with heuristic regex matching for totals, tax, merchant, and line items.
   - **Pro Cloud AI (Online)**: `RemoteAiService` connects to Gemini 1.5 Flash API (when user enables AI features and has network connectivity) for multimodal understanding or high-accuracy structured extraction.
4. **Local WebP Image Optimization**: Compress raw camera captures down to ~150-250KB WebP before persisting to app storage, linking the local file path directly into the Drift `Receipt` entity.
5. **Cross-Platform Graceful Fallback**: Web, macOS, and Windows fall back to a zero-Material file/gallery picker or mock receipt loader, ensuring zero crashes on desktop/web environments.

---

## 2. Technical Dependencies & Platform Setup

### 2.1 Dependencies in `pubspec.yaml`
```yaml
dependencies:
  google_mlkit_document_scanner: ^0.3.0   # Native edge detection & auto-cropping
  google_mlkit_text_recognition: ^0.14.0   # On-device offline OCR engine
  image: ^4.3.0                            # Image decoding, rotation, and WebP compression
  path_provider: ^2.1.5                    # Local receipt image file storage
```

### 2.2 Native Permissions
- **Android** (`AndroidManifest.xml`):
  - `<uses-permission android:name="android.permission.CAMERA"/>`
  - Document scanner uses Google Play Services ML Kit dynamic module.
- **iOS** (`Info.plist`):
  - `NSCameraUsageDescription` (already present)
  - `NSPhotoLibraryUsageDescription` (already present)

---

## 3. End-to-End Scanning & Parsing Workflow

```
[AddTransactionScreen: "Scan" Button]
                │
                ▼
  Check Platform & Availability
   ├─ If iOS / Android: Launch Native Google ML Kit Document Scanner
   └─ If Desktop / Web / Simulator: Launch Zero-Material Gallery / Sample Picker
                │
                ▼
        [Cropped Receipt Image]
                │
     ┌──────────┴────────────────────────┐
     ▼                                   ▼
[WebP Compression]             [OCR & Parsing Pipeline]
• Compress using `image` pkg    • Run `google_mlkit_text_recognition`
• Save to local App Documents   • If Online & Pro AI enabled:
• Target size: < 250 KB             Gemini 1.5 Flash API structured parse
                                • Else / Fallback:
                                    LocalAiService regex & layout parser
     └──────────┬────────────────────────┘
                │
                ▼
[ReceiptScannerReviewScreen (Zero-Material)]
• Pinch & pan high-res receipt viewer
• Animated laser scanning line effect
• Card preview: Merchant, Date, Subtotal, Tax, Total, Item count
• Actions: "Use This Receipt" / "Retake" / "Edit Manually"
                │
                ▼
[Pop back to AddTransactionScreen]
• Auto-fill amount, merchant title, category, and date
• Attach `Receipt` model with itemized lines and local image path
```

---

## 4. Component & Class Architecture

### 4.1 Services Layer

#### `IReceiptScannerService` (`lib/domain/services/i_receipt_scanner_service.dart`)
```dart
abstract class IReceiptScannerService {
  /// Launches native document scanner or platform fallback.
  /// Returns cropped image file path, or null if cancelled.
  Future<String?> scanDocument();

  /// Compresses input image to WebP and saves in app storage directory.
  Future<String> compressAndSaveReceiptImage(String sourcePath);
}
```

#### `MlKitDocumentScannerService` (`lib/data/services/mlkit_document_scanner_service.dart`)
- Implements `IReceiptScannerService`.
- Uses `DocumentScanner(options: DocumentScannerOptions(...))` configured for:
  - Document format: JPEG
  - Page limit: 1 (single receipt)
  - Scanner mode: `ScannerMode.filter` (full edge detection + enhancement filters)
- Handles errors and platform exceptions cleanly.

#### `MlKitOcrService` (`lib/data/services/mlkit_ocr_service.dart`)
- Uses `TextRecognizer(script: TextRecognitionScript.latin)`.
- Accepts image path or bytes.
- Returns recognized text string and bounding box block hierarchy.
- Properly disposes recognizer when done.

#### `GeminiReceiptParser` (`lib/data/services/gemini_receipt_parser.dart`)
- Integrated into `RemoteAiService`.
- Calls Gemini 1.5 Flash endpoint with structured JSON schema prompt.
- Extracts line items: `[{ name: String, qty: int, priceCents: int }]`, `subtotalCents`, `taxCents`, `totalCents`, `merchantName`, `suggestedCategory`.
- Gracefully falls back to `LocalAiService` on timeout or HTTP failure.

---

### 4.2 Presentation Layer (Zero Material UI)

#### `ReceiptScannerReviewScreen` (`lib/ui/screens/scanner/receipt_scanner_review_screen.dart`)
1. **Visual Structure**:
   - Top Bar: Zero-Material custom header with Back button, title "Review Scan", and status badge ("OCR Verified" / "Processing...").
   - Center Body: Image preview with interactive pinch-zoom (`InteractiveViewer`), overlaid with a scanning laser line animation (`CustomPainter`).
   - Bottom Sheet Card:
     - Extracted Merchant Title (editable inline or tap to confirm)
     - Total Amount highlighted with `AmountText`
     - Breakdown summary: Subtotal, Tax, and itemized preview chip list
     - Secondary "Retake" button and Primary "Confirm & Use" button

2. **Styling & Tokens**:
   - Background: `colors.background` with subtle radial blur
   - Borders: `AppRadii.card` with `colors.borderSubtle`
   - Typography: `context.text.headlineSmall`, `context.text.bodyMedium`
   - Haptics: `AppHaptics.medium()` on capture, `AppHaptics.success()` on parsing complete

---

## 5. Fallback & Cross-Platform Strategy

- **On Android & iOS Devices**: Full native Google ML Kit document scanner with hardware edge detection.
- **On Simulators / Desktop / Web**:
  - Tapping "Scan" opens a Zero-Material modal offering:
    1. "Choose Image from Files / Gallery"
    2. "Load Sample Receipt (Demo Mode)"
  - Processes through OCR or LocalAiService sample text, allowing developers and reviewers to test the entire flow on any platform without a physical camera.

---

## 6. Verification & Test Plan

1. **Unit Tests**:
   - `test/services/local_ai_service_receipt_parser_test.dart`: Test regex extraction against various receipt layouts (supermarket, restaurant, gas station).
   - `test/services/receipt_compression_test.dart`: Verify image compression reduces file size by at least 60% without breaking readability.
2. **Widget Tests**:
   - `test/screens/receipt_scanner_review_screen_test.dart`: Test rendering of the review screen, laser animation, and action button interactions.
3. **Integration Flow Test**:
   - Verify tapping "Scan" -> Review -> Confirm navigates back to `AddTransactionScreen` with all fields populated.
4. **Static Analysis**:
   - `dart analyze` passes with 0 warnings.
   - Zero Material and Zero Cupertino widget verification check.
