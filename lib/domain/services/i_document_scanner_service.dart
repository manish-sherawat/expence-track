/// Interface for hardware document scanning with edge detection and perspective auto-crop.
abstract class IDocumentScannerService {
  /// Launches the native document scanner viewfinder or fallback picker.
  /// Returns the local file path of the cropped receipt image, or `null` if cancelled.
  Future<String?> scanDocument();
}
