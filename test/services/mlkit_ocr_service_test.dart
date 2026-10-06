import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/data/services/mlkit_ocr_service.dart';

void main() {
  group('MlKitOcrService', () {
    test('recognizeTextFromFile returns fallback text on non-mobile platform override', () async {
      final ocr = MlKitOcrService(isSupportedOverride: false);
      final text = await ocr.recognizeTextFromFile('dummy_path.jpg');

      expect(text, contains('Whole Foods Market'));
      expect(text, contains('TOTAL:'));

      await ocr.dispose();
    });

    test('recognizeTextFromBytes returns fallback text on non-mobile platform override', () async {
      final ocr = MlKitOcrService(isSupportedOverride: false);
      final text = await ocr.recognizeTextFromBytes(Uint8List.fromList([1, 2, 3]));

      expect(text, contains('Whole Foods Market'));

      await ocr.dispose();
    });
  });
}
