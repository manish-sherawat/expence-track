import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/data/services/mlkit_document_scanner_service.dart';

void main() {
  group('MlKitDocumentScannerService', () {
    test('returns sample receipt path when fallback is forced on non-mobile', () async {
      final scanner = MlKitDocumentScannerService(
        isSupportedOverride: false,
        sampleReceiptPath: 'assets/receipts/sample_receipt.jpg',
      );

      final path = await scanner.scanDocument();
      expect(path, equals('assets/receipts/sample_receipt.jpg'));
    });

    test('returns null when user cancels or fallback provides empty path', () async {
      final scanner = MlKitDocumentScannerService(
        isSupportedOverride: false,
        sampleReceiptPath: null,
      );

      final path = await scanner.scanDocument();
      expect(path, isNull);
    });
  });
}
