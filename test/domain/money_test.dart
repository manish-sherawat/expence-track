import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/domain/models/money.dart';

void main() {
  group('Money Value Object Tests', () {
    test('Constructors and getters work with integer minor units', () {
      const m1 = Money(1289290); // $12,892.90
      expect(m1.cents, 1289290);
      expect(m1.asDollars, 12892.90);
      expect(m1.dollarPart, 12892);
      expect(m1.centPart, 90);
      expect(m1.isPositive, isTrue);
      expect(m1.isNegative, isFalse);
      expect(m1.isZero, isFalse);

      final m2 = Money.fromDollars(12.50);
      expect(m2.cents, 1250);
      expect(m2.dollarPart, 12);
      expect(m2.centPart, 50);

      expect(Money.zero.cents, 0);
      expect(Money.zero.isZero, isTrue);
    });

    test('Arithmetic operations preserve exact integer cents', () {
      const a = Money(10050); // $100.50
      const b = Money(2525);  // $25.25

      expect((a + b).cents, 12575); // $125.75
      expect((a - b).cents, 7525);  // $75.25
      expect((b * 2).cents, 5050);   // $50.50
      expect((a / 2).cents, 5025);   // $50.25
      expect((-a).cents, -10050);
      expect((-a).abs().cents, 10050);
    });

    test('Comparison and equality work correctly', () {
      const a = Money(1000);
      const b = Money(2000);
      const c = Money(1000);

      expect(a == c, isTrue);
      expect(a == b, isFalse);
      expect(a < b, isTrue);
      expect(b > a, isTrue);
      expect(a <= c, isTrue);
      expect(a >= c, isTrue);
      expect(a.compareTo(b), isNegative);
    });

    test('Parsing currency strings handles commas, dollars, and negatives', () {
      final p1 = Money.parse(r'$12,892.90');
      expect(p1.cents, 1289290);

      final p2 = Money.parse('-32.91');
      expect(p2.cents, -3291);

      final p3 = Money.parse(r'  +$4,214.50  ');
      expect(p3.cents, 421450);

      expect(() => Money.parse('invalid'), throwsFormatException);
    });

    test('Formatting outputs consistent currency representations', () {
      const m = Money(1289290);
      expect(m.format(), r'$12,892.90');
      expect(m.format(signed: true), r'+$12,892.90');
      expect(m.format(includeSymbol: false), '12,892.90');

      const negativeM = Money(-3291);
      expect(negativeM.format(), r'-$32.91');
      expect(negativeM.format(signed: true), r'-$32.91');
      expect(negativeM.format(includeSymbol: false), '-32.91');

      const compactThousand = Money(1250000); // $12,500.00
      expect(compactThousand.format(compact: true), r'$12.5k');

      const compactMillion = Money(120000000); // $1,200,000.00
      expect(compactMillion.format(compact: true), r'$1.2M');
    });

    test('Prevents currency mismatch calculations', () {
      const usd = Money(100, currency: 'USD');
      const eur = Money(100, currency: 'EUR');

      expect(() => usd + eur, throwsArgumentError);
      expect(() => usd < eur, throwsArgumentError);
    });
  });
}
