import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:salary_tracker/data/services/receipt_storage_service.dart';

void main() {
  test('compressImageBytes reduces image dimensions and produces valid bytes', () async {
    // Generate a test high-res image
    final image = img.Image(width: 1200, height: 1600);
    img.fill(image, color: img.ColorRgb8(240, 240, 240));
    // Draw some noise so compression is measurable
    for (int y = 0; y < 100; y++) {
      for (int x = 0; x < 100; x++) {
        image.setPixelRgb(x, y, x % 255, y % 255, 128);
      }
    }
    final rawBytes = img.encodeJpg(image, quality: 100);

    const service = ReceiptStorageService();
    final compressed = await service.compressImageBytes(rawBytes, maxWidth: 600, quality: 75);

    expect(compressed.length, lessThan(rawBytes.length));
    final decoded = img.decodeImage(Uint8List.fromList(compressed));
    expect(decoded, isNotNull);
    expect(decoded!.width, lessThanOrEqualTo(600));
  });

  test('compressImageBytes leaves small images without upscaling', () async {
    final image = img.Image(width: 300, height: 400);
    img.fill(image, color: img.ColorRgb8(200, 200, 200));
    final rawBytes = img.encodeJpg(image);

    const service = ReceiptStorageService();
    final compressed = await service.compressImageBytes(rawBytes, maxWidth: 800, quality: 80);

    final decoded = img.decodeImage(Uint8List.fromList(compressed));
    expect(decoded, isNotNull);
    expect(decoded!.width, equals(300));
  });
}
