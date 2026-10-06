import 'package:intl/intl.dart';

/// Immutable representation of monetary value in minor units (cents).
/// Prevents IEEE 754 floating-point rounding errors in financial math.
class Money implements Comparable<Money> {
  const Money(this.cents, {this.currency = 'USD'});

  /// Creates [Money] from a floating point dollar amount (e.g. 12.50 -> 1250 cents).
  factory Money.fromDollars(double dollars, {String currency = 'USD'}) {
    return Money((dollars * 100).round(), currency: currency);
  }

  /// Zero money constant.
  static const Money zero = Money(0);

  /// The amount in minor units (e.g. 1289290 = $12,892.90).
  final int cents;

  /// The ISO-4217 currency code (e.g. 'USD').
  final String currency;

  /// Returns floating point dollar representation. Use only for display/conversions.
  double get asDollars => cents / 100.0;

  /// Integer whole dollar portion (positive).
  int get dollarPart => cents.abs() ~/ 100;

  /// Integer cent portion (0-99).
  int get centPart => cents.abs() % 100;

  bool get isPositive => cents > 0;
  bool get isNegative => cents < 0;
  bool get isZero => cents == 0;

  /// Returns absolute value of this [Money].
  Money abs() => Money(cents.abs(), currency: currency);

  /// Negates this [Money].
  Money operator -() => Money(-cents, currency: currency);

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(cents + other.cents, currency: currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(cents - other.cents, currency: currency);
  }

  Money operator *(num multiplier) {
    return Money((cents * multiplier).round(), currency: currency);
  }

  Money operator /(num divisor) {
    if (divisor == 0) throw ArgumentError.value(divisor, 'divisor', 'Cannot divide by zero');
    return Money((cents / divisor).round(), currency: currency);
  }

  bool operator <(Money other) {
    _assertSameCurrency(other);
    return cents < other.cents;
  }

  bool operator <=(Money other) {
    _assertSameCurrency(other);
    return cents <= other.cents;
  }

  bool operator >(Money other) {
    _assertSameCurrency(other);
    return cents > other.cents;
  }

  bool operator >=(Money other) {
    _assertSameCurrency(other);
    return cents >= other.cents;
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return cents.compareTo(other.cents);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Money && other.cents == cents && other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(cents, currency);

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
  }

  /// Parses a string representation (e.g. "$12,892.90" or "-32.91" or "100") into [Money].
  factory Money.parse(String value, {String currency = 'USD'}) {
    final sanitized = value.replaceAll(RegExp(r'[\$,\s]'), '');
    final parsed = double.tryParse(sanitized);
    if (parsed == null) {
      throw FormatException('Invalid currency string: $value');
    }
    return Money.fromDollars(parsed, currency: currency);
  }

  /// Standard formatted representation (e.g. "$12,892.90" or "-$32.91").
  String get formatted => format();

  /// Formats the money into a string.
  /// Example: "$12,892.90", "+$4,214.50", "-$32.91"
  String format({
    bool includeSymbol = true,
    bool signed = false,
    bool compact = false,
  }) {
    final symbol = includeSymbol ? _currencySymbol(currency) : '';
    final sign = signed
        ? (isPositive ? '+' : (isNegative ? '-' : ''))
        : (isNegative ? '-' : '');

    final absCents = cents.abs();
    final whole = absCents ~/ 100;
    final cent = absCents % 100;

    final formatter = NumberFormat('#,##0', 'en_US');
    final formattedWhole = formatter.format(whole);
    final formattedCent = cent.toString().padLeft(2, '0');

    if (compact && absCents >= 100000000) {
      // Compact millions: $1.2M
      final millions = absCents / 100000000.0;
      return '$sign$symbol${millions.toStringAsFixed(1)}M';
    }

    if (compact && absCents >= 100000) {
      // Compact thousands: $12.5k
      final thousands = absCents / 100000.0;
      return '$sign$symbol${thousands.toStringAsFixed(1)}k';
    }

    return '$sign$symbol$formattedWhole.$formattedCent';
  }

  static String _currencySymbol(String code) {
    switch (code) {
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'USD':
      default:
        return r'$';
    }
  }

  @override
  String toString() => format();
}
