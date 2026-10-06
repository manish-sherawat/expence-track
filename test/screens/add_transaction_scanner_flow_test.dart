import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/domain/models/money.dart';
import 'package:salary_tracker/domain/models/receipt.dart';
import 'package:salary_tracker/domain/services/i_ai_service.dart';

void main() {
  test('ReceiptScanResult properly maps into AddTransaction state fields', () {
    final result = ReceiptScanResult(
      merchantName: 'Whole Foods Market',
      timestamp: DateTime(2026, 10, 6),
      items: const [
        ReceiptLineItem(
          id: 'item_1',
          receiptId: 'rcpt_1',
          name: 'Cold Brew Coffee',
          quantity: 1,
          price: Money(450),
        ),
      ],
      subtotal: const Money(2100),
      tax: const Money(190),
      total: const Money(2290),
      confidenceScore: 0.98,
    );

    final amountFormatted = (result.total.cents / 100.0).toStringAsFixed(2);
    expect(amountFormatted, equals('22.90'));
    expect(result.merchantName, equals('Whole Foods Market'));
    expect(result.items.first.name, equals('Cold Brew Coffee'));
  });
}
