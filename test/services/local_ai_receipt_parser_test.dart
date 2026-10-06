import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/data/services/local_ai_service.dart';

void main() {
  group('LocalAiService Receipt Text Parsing', () {
    const service = LocalAiService();

    test('extracts merchant, subtotal, tax, total, and line items accurately', () async {
      const rawOcr = '''
Target Store #2814
1. Dish Soap        \$3.49
2. Paper Towels     \$8.99
3. AA Batteries     \$12.50
SUBTOTAL: \$24.98
TAX: \$2.12
TOTAL: \$27.10
''';

      final result = await service.parseReceiptText(rawOcr);

      expect(result.merchantName, contains('Target'));
      expect(result.total.cents, equals(2710));
      expect(result.tax.cents, equals(212));
      expect(result.subtotal.cents, equals(2498));
      expect(result.items.length, greaterThanOrEqualTo(3));
      expect(result.items.first.price.cents, equals(349));
    });

    test('handles balance due, amount due and lowercase tags', () async {
      const rawOcr = '''
TRADER JOE'S
Almond Milk 1.99
Organic Bananas 0.89
Avocados 3.99
Tax: 0.45
Balance Due: \$7.32
''';

      final result = await service.parseReceiptText(rawOcr);

      expect(result.merchantName, contains("TRADER JOE'S"));
      expect(result.total.cents, equals(732));
      expect(result.tax.cents, equals(45));
      expect(result.items.length, equals(3));
    });

    test('calculates total from items if explicit TOTAL line is missing', () async {
      const rawOcr = '''
Corner Bakery
Croissant 4.50
Latte 5.50
''';

      final result = await service.parseReceiptText(rawOcr);

      expect(result.merchantName, contains('Corner Bakery'));
      expect(result.total.cents, equals(1000)); // 4.50 + 5.50
      expect(result.items.length, equals(2));
    });
  });
}
