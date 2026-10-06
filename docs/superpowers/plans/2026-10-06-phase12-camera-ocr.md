# Phase 12: Hardware Integration & On-Device Camera OCR Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement hardware document scanning, offline on-device ML Kit OCR, WebP receipt image compression, zero-Material review screen, and optional Gemini 1.5 Flash cloud parser for the Salary Tracker app.

**Architecture:** A native document scanner (`google_mlkit_document_scanner`) auto-detects paper edges and perspective-crops receipts. The cropped image is compressed to WebP via `package:image` to save storage (<250KB), processed via on-device `google_mlkit_text_recognition`, parsed via regex/layout heuristics in `LocalAiService` (with optional Gemini 1.5 Flash fallback via `RemoteAiService`), and reviewed on a custom zero-Material `ReceiptScannerReviewScreen` before auto-populating `AddTransactionScreen`.

**Tech Stack:** Flutter 3.47.5, Dart 3.13.4, `google_mlkit_document_scanner`, `google_mlkit_text_recognition`, `image`, `path_provider`, Riverpod, GoRouter, zero-Material custom design system.

**Spec:** [docs/superpowers/specs/2026-10-06-phase12-camera-ocr-design.md](file:///d:/Flutter/BUget%20Tracker/salary_tracker/docs/superpowers/specs/2026-10-06-phase12-camera-ocr-design.md)

## Global Constraints

- 100% Zero-Material and Zero-Cupertino widget architecture: no `Scaffold`, `AppBar`, `ElevatedButton`, `Icons`, etc.
- All UI components must use `AppTheme`, `AppColors`, `AppSpacing`, `AppRadii`, `AppMotion`, and existing design tokens.
- Offline-first: The application must fully function without an active internet connection using ML Kit and LocalAiService.
- Cross-platform support: Non-mobile platforms (Desktop/Web/Simulators) must gracefully fall back to sample/mock receipt picking without crashing.
- Static analysis clean: `dart analyze` must pass with 0 warnings or errors.

## Review Focus

- Missing camera hardware on desktop/simulators: Document scanner handles platform errors gracefully and falls back to mock/file picker.
- Corrupted or unreadable image bytes: Image compression service validates bytes before decoding and handles errors without app crashes.
- Malformed receipt text with missing totals: Regex parser extracts what is present and safely defaults confidence/totals without null pointer exceptions.
- Zero-Material adherence: Scanner review screen strictly uses custom painters, `GestureDetector`, and design system widgets.
- Memory leaks: All `TextRecognizer` instances and controllers are properly disposed.

---

### Task 1: Add Dependencies & Platform Permissions

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml:1-10`
- Test: CLI validation via `flutter pub get` and `dart analyze`

**Interfaces:**
- Consumes: Flutter SDK packages
- Produces: `google_mlkit_document_scanner`, `google_mlkit_text_recognition`, `image`, `path_provider` packages in project

- [ ] **Step 1: Add dependencies to pubspec.yaml**

Add `google_mlkit_document_scanner: ^0.6.1`, `google_mlkit_text_recognition: ^0.17.1`, `image: ^4.10.1`, and `path_provider: ^2.1.6` to `pubspec.yaml` under `dependencies`.

- [ ] **Step 2: Add CAMERA permission to AndroidManifest.xml**

Add `<uses-permission android:name="android.permission.CAMERA"/>` to `android/app/src/main/AndroidManifest.xml`.

- [ ] **Step 3: Run flutter pub get and dart analyze**

Run: `flutter pub get`
Run: `dart analyze`
Expected: 0 issues found.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml
git commit -m "feat(phase12): add camera ocr dependencies and android permissions"
```

---

### Task 2: Image Compression & Local Receipt Storage Service

**Files:**
- Create: `lib/domain/services/i_receipt_storage_service.dart`
- Create: `lib/data/services/receipt_storage_service.dart`
- Test: `test/services/receipt_storage_service_test.dart`

**Interfaces:**
- Consumes: `package:image`
- Produces: `IReceiptStorageService.compressImageBytes(List<int> rawBytes, {int targetQuality, int maxWidth}) -> Future<List<int>>` and `saveReceiptImage(...) -> Future<String>`

- [ ] **Step 1: Write the failing test**

```dart
// test/services/receipt_storage_service_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:salary_tracker/data/services/receipt_storage_service.dart';

void main() {
  test('compressImageBytes reduces image dimensions and outputs valid bytes', () async {
    final image = img.Image(width: 1200, height: 1600);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    final rawBytes = img.encodeJpg(image);

    final service = ReceiptStorageService();
    final compressed = await service.compressImageBytes(rawBytes, maxWidth: 600, quality: 75);

    expect(compressed.length, lessThan(rawBytes.length));
    final decoded = img.decodeImage(Uint8List.fromList(compressed));
    expect(decoded, isNotNull);
    expect(decoded!.width, lessThanOrEqualTo(600));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/receipt_storage_service_test.dart`
Expected: Compilation failure (ReceiptStorageService does not exist).

- [ ] **Step 3: Write interface and implementation**

Create `IReceiptStorageService` in `lib/domain/services/i_receipt_storage_service.dart` and `ReceiptStorageService` in `lib/data/services/receipt_storage_service.dart` that decodes with `package:image`, resizes if wider than `maxWidth`, encodes to JPEG/WebP with quality compression, and saves to local file path when directory is provided.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/receipt_storage_service_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/services/i_receipt_storage_service.dart lib/data/services/receipt_storage_service.dart test/services/receipt_storage_service_test.dart
git commit -m "feat(phase12): implement receipt image compression and storage service"
```

---

### Task 3: ML Kit OCR Service & Enhanced Regex Receipt Parser

**Files:**
- Create: `lib/domain/services/i_ocr_service.dart`
- Create: `lib/data/services/mlkit_ocr_service.dart`
- Modify: `lib/data/services/local_ai_service.dart:80-150`
- Test: `test/services/local_ai_receipt_parser_test.dart`

**Interfaces:**
- Consumes: `google_mlkit_text_recognition`, raw receipt text
- Produces: `IOcrService.recognizeTextFromFile(String filePath) -> Future<String>`, `IOcrService.recognizeTextFromBytes(List<int> bytes) -> Future<String>`, and enhanced `LocalAiService.parseReceiptText(String ocrText) -> Future<ReceiptScanResult>`

- [ ] **Step 1: Write the failing test**

```dart
// test/services/local_ai_receipt_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/data/services/local_ai_service.dart';

void main() {
  test('parseReceiptText extracts merchant, subtotal, tax, total, and itemized lines', () async {
    const rawOcr = '''
Target Store #2814
1. Dish Soap        $3.49
2. Paper Towels     $8.99
3. AA Batteries     $12.50
SUBTOTAL: $24.98
TAX: $2.12
TOTAL: $27.10
''';

    const service = LocalAiService();
    final result = await service.parseReceiptText(rawOcr);

    expect(result.merchantName, contains('Target'));
    expect(result.total.cents, equals(2710));
    expect(result.tax.cents, equals(212));
    expect(result.subtotal.cents, equals(2498));
    expect(result.items.length, greaterThanOrEqualTo(3));
  });
}
```

- [ ] **Step 2: Run test to verify it fails or needs refinement**

Run: `flutter test test/services/local_ai_receipt_parser_test.dart`
Expected: Verify behavior against complex receipts.

- [ ] **Step 3: Implement IOcrService, MlKitOcrService, and enhance LocalAiService.parseReceiptText**

1. Create `IOcrService` in `lib/domain/services/i_ocr_service.dart`.
2. Create `MlKitOcrService` in `lib/data/services/mlkit_ocr_service.dart` with `TextRecognizer` lifecycle management and cross-platform guard.
3. Enhance `LocalAiService.parseReceiptText` with regex patterns for `TOTAL`, `TAX`, `SUBTOTAL`, merchant name extraction from header lines, and line items extraction.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/local_ai_receipt_parser_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/services/i_ocr_service.dart lib/data/services/mlkit_ocr_service.dart lib/data/services/local_ai_service.dart test/services/local_ai_receipt_parser_test.dart
git commit -m "feat(phase12): implement ML Kit OCR service and robust receipt text parser"
```

---

### Task 4: Hardware Document Scanner Service with Fallback

**Files:**
- Create: `lib/domain/services/i_document_scanner_service.dart`
- Create: `lib/data/services/mlkit_document_scanner_service.dart`
- Test: `test/services/document_scanner_service_test.dart`

**Interfaces:**
- Consumes: `google_mlkit_document_scanner`
- Produces: `IDocumentScannerService.scanDocument() -> Future<String?>`

- [ ] **Step 1: Write the failing test**

```dart
// test/services/document_scanner_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/data/services/mlkit_document_scanner_service.dart';

void main() {
  test('MlKitDocumentScannerService returns sample path when fallback is enabled', () async {
    final scanner = MlKitDocumentScannerService(
      isSupportedPlatformOverride: false,
      sampleReceiptPath: 'assets/receipts/sample_receipt.jpg',
    );

    final path = await scanner.scanDocument();
    expect(path, equals('assets/receipts/sample_receipt.jpg'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/document_scanner_service_test.dart`
Expected: Compilation failure (service does not exist).

- [ ] **Step 3: Implement IDocumentScannerService and MlKitDocumentScannerService**

Create `IDocumentScannerService` and `MlKitDocumentScannerService` using `DocumentScanner(options: DocumentScannerOptions(pageLimit: 1, mode: ScannerMode.filter))` on iOS/Android, and graceful mock/sample fallback on Web/Desktop.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/document_scanner_service_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/services/i_document_scanner_service.dart lib/data/services/mlkit_document_scanner_service.dart test/services/document_scanner_service_test.dart
git commit -m "feat(phase12): implement ML Kit document scanner service with fallback"
```

---

### Task 5: Zero-Material Scanner Review Screen (`ReceiptScannerReviewScreen`)

**Files:**
- Create: `lib/ui/screens/scanner/widgets/scanning_laser_overlay.dart`
- Create: `lib/ui/screens/scanner/receipt_scanner_review_screen.dart`
- Test: `test/screens/receipt_scanner_review_screen_test.dart`

**Interfaces:**
- Consumes: `ReceiptScanResult`, `imagePath`, design system tokens
- Produces: `ReceiptScannerReviewScreen` widget returning `ReceiptScanResult?` on confirm

- [ ] **Step 1: Write the failing widget test**

```dart
// test/screens/receipt_scanner_review_screen_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/domain/models/money.dart';
import 'package:salary_tracker/domain/services/i_ai_service.dart';
import 'package:salary_tracker/ui/screens/scanner/receipt_scanner_review_screen.dart';

void main() {
  testWidgets('ReceiptScannerReviewScreen displays merchant, total, and action buttons', (tester) async {
    final scanResult = ReceiptScanResult(
      merchantName: 'Trader Joe\'s',
      timestamp: DateTime.now(),
      items: const [],
      subtotal: const Money(1500),
      tax: const Money(120),
      total: const Money(1620),
      confidenceScore: 0.99,
      rawText: 'Trader Joe\'s TOTAL: $16.20',
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ReceiptScannerReviewScreen(
          imagePath: '',
          initialResult: scanResult,
        ),
      ),
    );

    expect(find.text('Trader Joe\'s'), findsOneWidget);
    expect(find.text('Confirm & Use'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/receipt_scanner_review_screen_test.dart`
Expected: Compilation failure.

- [ ] **Step 3: Implement ScanningLaserOverlay and ReceiptScannerReviewScreen**

1. Create `ScanningLaserOverlay` using `CustomPainter` with an animated neon gradient beam scanning vertically across the image.
2. Create `ReceiptScannerReviewScreen` using zero-Material components:
   - Header with back button and "Receipt Scan" title.
   - Interactive image container (`InteractiveViewer`) with laser animation while parsing.
   - Bottom summary card displaying merchant name, total formatted with `AmountText`, subtotal, tax, item count badge.
   - Secondary button "Retake" and Primary button "Confirm & Use".

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/receipt_scanner_review_screen_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/screens/scanner/widgets/scanning_laser_overlay.dart lib/ui/screens/scanner/receipt_scanner_review_screen.dart test/screens/receipt_scanner_review_screen_test.dart
git commit -m "feat(phase12): build zero-Material receipt scanner review screen"
```

---

### Task 6: Wire Scanner Workflow into `AddTransactionScreen` & Router

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `lib/ui/screens/add_transaction/add_transaction_screen.dart:144-165`
- Test: `test/screens/add_transaction_scanner_flow_test.dart`

**Interfaces:**
- Consumes: `IDocumentScannerService`, `IOcrService`, `IReceiptStorageService`, `ReceiptScannerReviewScreen`
- Produces: Live hardware scanning integration in `AddTransactionScreen`

- [ ] **Step 1: Write integration test for AddTransactionScreen scanner flow**

```dart
// test/screens/add_transaction_scanner_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/domain/models/money.dart';
import 'package:salary_tracker/domain/services/i_ai_service.dart';

void main() {
  test('ReceiptScanResult properly maps into AddTransaction state fields', () {
    final result = ReceiptScanResult(
      merchantName: 'Whole Foods Market',
      timestamp: DateTime(2026, 10, 6),
      items: const [],
      subtotal: const Money(2100),
      tax: const Money(190),
      total: const Money(2290),
      confidenceScore: 0.98,
    );

    final amountFormatted = (result.total.cents / 100.0).toStringAsFixed(2);
    expect(amountFormatted, equals('22.90'));
    expect(result.merchantName, equals('Whole Foods Market'));
  });
}
```

- [ ] **Step 2: Run test to verify it passes**

Run: `flutter test test/screens/add_transaction_scanner_flow_test.dart`

- [ ] **Step 3: Connect scanner in AddTransactionScreen and register route in router.dart**

In `lib/ui/screens/add_transaction/add_transaction_screen.dart`:
- Replace simulated text in `_handleScanReceipt()` with call to `MlKitDocumentScannerService.scanDocument()`.
- On image captured: run OCR + compression, open `ReceiptScannerReviewScreen`.
- On confirm: populate `_amountInput`, `_titleController`, attach receipt details and image path.

- [ ] **Step 4: Run flutter test and dart analyze**

Run: `flutter test`
Run: `dart analyze`
Expected: All tests pass, 0 analyzer issues.

- [ ] **Step 5: Commit**

```bash
git add lib/app/router.dart lib/ui/screens/add_transaction/add_transaction_screen.dart test/screens/add_transaction_scanner_flow_test.dart
git commit -m "feat(phase12): wire live receipt document scanning into add transaction screen"
```

---

### Task 7: Pro Cloud AI Parser Connector (Gemini 1.5 Flash API)

**Files:**
- Create: `lib/data/services/gemini_receipt_parser.dart`
- Modify: `lib/data/services/remote_ai_service.dart:25-50`
- Test: `test/services/gemini_receipt_parser_test.dart`

**Interfaces:**
- Consumes: Gemini API endpoints / structured JSON response
- Produces: `GeminiReceiptParser.parseReceipt({required String ocrText, String? apiKey}) -> Future<ReceiptScanResult>`

- [ ] **Step 1: Write the unit test**

```dart
// test/services/gemini_receipt_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/data/services/gemini_receipt_parser.dart';

void main() {
  test('GeminiReceiptParser parses structured JSON into ReceiptScanResult', () {
    const mockJson = '''
{
  "merchantName": "Costco Wholesale",
  "subtotalCents": 8450,
  "taxCents": 680,
  "totalCents": 9130,
  "suggestedCategory": "Groceries",
  "items": [
    {"name": "Organic Eggs 24pk", "qty": 1, "priceCents": 899},
    {"name": "Paper Towels", "qty": 1, "priceCents": 2199}
  ]
}
''';
    final result = GeminiReceiptParser.parseStructuredJson(mockJson);
    expect(result.merchantName, equals('Costco Wholesale'));
    expect(result.total.cents, equals(9130));
    expect(result.items.length, equals(2));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/gemini_receipt_parser_test.dart`
Expected: Compilation failure.

- [ ] **Step 3: Implement GeminiReceiptParser and hook into RemoteAiService**

Create `GeminiReceiptParser` and wire into `RemoteAiService.parseReceiptText()` when user consent is enabled, falling back to `LocalAiService` on network errors or missing API key.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/gemini_receipt_parser_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/services/gemini_receipt_parser.dart lib/data/services/remote_ai_service.dart test/services/gemini_receipt_parser_test.dart
git commit -m "feat(phase12): add Gemini 1.5 Flash cloud AI parser connector"
```

---

### Task 8: Full Verification & TASKS.md Checklist Update

**Files:**
- Modify: `TASKS.md:188-195`
- Test: Full test suite & static analysis

- [ ] **Step 1: Run complete test suite**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 2: Run dart analyze**

Run: `dart analyze`
Expected: 0 warnings, 0 errors.

- [ ] **Step 3: Update TASKS.md Phase 12 items to completed**

Check off all Phase 12 checklist items in `TASKS.md`:
```markdown
## Phase 12: Hardware Integration & On-Device Camera OCR (COMPLETED)
- [x] Custom zero-Material camera viewfinder with rectangular paper guide overlay / review screen
- [x] Google ML Kit (`google_mlkit_text_recognition`) offline text extraction
- [x] Edge detection, perspective correction, and auto-cropping for paper receipts via `google_mlkit_document_scanner`
- [x] Local receipt compression (WebP/JPEG) to prevent storage bloat
- [x] Optional Pro Cloud AI Parser connector (Gemini 1.5 Flash API)
```

- [ ] **Step 4: Commit**

```bash
git add TASKS.md
git commit -m "docs(tasks): mark phase 12 hardware camera and ocr as completed"
```
