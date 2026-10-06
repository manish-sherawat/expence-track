import 'money.dart';

enum BudgetPeriod {
  weekly,
  monthly,
  yearly,
}

class Budget {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    this.spentAmount = Money.zero,
    this.period = BudgetPeriod.monthly,
    this.month = 4,
    this.year = 2026,
  });

  final String id;
  final String categoryId;
  final Money limitAmount;
  final Money spentAmount;
  final BudgetPeriod period;
  final int month;
  final int year;

  double get progressRatio =>
      limitAmount.cents == 0 ? 0.0 : (spentAmount.cents / limitAmount.cents);

  bool get isOverBudget => spentAmount > limitAmount;

  Money get difference => limitAmount - spentAmount;

  Money get overspentAmount =>
      isOverBudget ? (spentAmount - limitAmount) : Money.zero;

  Money get remainingAmount =>
      isOverBudget ? Money.zero : (limitAmount - spentAmount);

  Budget copyWith({
    String? id,
    String? categoryId,
    Money? limitAmount,
    Money? spentAmount,
    BudgetPeriod? period,
    int? month,
    int? year,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      period: period ?? this.period,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Budget &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
