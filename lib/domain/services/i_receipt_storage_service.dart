import 'dart:typed_data';

/// Contract for processing, compressing, and persisting receipt images locally.
abstract class IReceiptStorageService {
  /// Compresses [rawBytes], ensuring width does not exceed [maxWidth],
  /// and returns compressed image bytes (JPEG/WebP) with target [quality] (1-100).
  Future<List<int>> compressImageBytes(
    List<int> rawBytes, {
    int maxWidth = 1080,
    int quality = 80,
  });

  /// Compresses the image at [sourcePath] and saves it into the local app documents
  /// directory under a unique filename (e.g., `receipt_<timestamp>.jpg`), returning
  /// the saved local file path.
  Future<String> saveReceiptImage({
    required String sourcePath,
    String? customFileName,
  });

  /// Reads raw bytes from a stored receipt image path.
  Future<Uint8List?> readReceiptImageBytes(String filePath);
}
