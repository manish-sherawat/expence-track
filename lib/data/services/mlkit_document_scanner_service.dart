import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import '../../domain/services/i_document_scanner_service.dart';

/// Document scanner service utilizing Google ML Kit Document Scanner on mobile
/// with automatic edge detection, perspective correction, and shadow filtering.
class MlKitDocumentScannerService implements IDocumentScannerService {
  final bool isSupportedPlatform;
  final String? sampleReceiptPath;
  final DocumentScanner? _scannerOverride;

  MlKitDocumentScannerService({
    bool? isSupportedOverride,
    this.sampleReceiptPath,
    DocumentScanner? scannerOverride,
  })  : isSupportedPlatform = isSupportedOverride ??
            (!kIsWeb && (Platform.isAndroid || Platform.isIOS)),
        _scannerOverride = scannerOverride;

  @override
  Future<String?> scanDocument() async {
    if (!isSupportedPlatform) {
      // Graceful fallback on web, desktop, and test simulators
      return sampleReceiptPath;
    }

    try {
      final options = DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        mode: ScannerMode.full,
        pageLimit: 1,
        isGalleryImport: true,
      );

      final scanner = _scannerOverride ?? DocumentScanner(options: options);
      final DocumentScanningResult result = await scanner.scanDocument();

      if (result.images != null && result.images!.isNotEmpty) {
        return result.images!.first;
      }
      return null;
    } catch (_) {
      // If hardware scanner fails or user cancels, fallback safely
      return sampleReceiptPath;
    }
  }
}
