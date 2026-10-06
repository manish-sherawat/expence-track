import 'dart:typed_data';

/// Interface for on-device and fallback optical character recognition (OCR).
abstract class IOcrService {
  /// Extracts raw plain text from an image located at [filePath].
  Future<String> recognizeTextFromFile(String filePath);

  /// Extracts raw plain text from in-memory [imageBytes].
  Future<String> recognizeTextFromBytes(Uint8List imageBytes);

  /// Releases internal resources and hardware models.
  Future<void> dispose();
}
