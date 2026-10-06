import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/design_system/tokens/tokens.dart';
import 'package:salary_tracker/domain/models/money.dart';
import 'package:salary_tracker/domain/models/receipt.dart';
import 'package:salary_tracker/domain/services/i_ai_service.dart';
import 'package:salary_tracker/ui/screens/scanner/receipt_scanner_review_screen.dart';

void main() {
  testWidgets('ReceiptScannerReviewScreen displays merchant, total, and action buttons', (tester) async {
    final scanResult = ReceiptScanResult(
      merchantName: "Trader Joe's",
      timestamp: DateTime(2026, 10, 6),
      items: const [
        ReceiptLineItem(
          id: '1',
          receiptId: 'r1',
          name: 'Organic Bananas',
          quantity: 1,
          price: Money(199),
        ),
      ],
      subtotal: const Money(199),
      tax: const Money(15),
      total: const Money(214),
      confidenceScore: 0.99,
      rawText: "Trader Joe's Total 2.14",
    );

    await tester.pumpWidget(
      AppTheme(
        data: AppThemeData.dark(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ReceiptScannerReviewScreen(
            imagePath: 'dummy_receipt.jpg',
            initialResult: scanResult,
          ),
        ),
      ),
    );

    expect(find.text("Trader Joe's"), findsOneWidget);
    expect(find.text('Confirm & Use'), findsOneWidget);
    expect(find.text('Retake'), findsOneWidget);
  });
}
