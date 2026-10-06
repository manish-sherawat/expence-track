import 'money.dart';

class SalaryProfile {
  const SalaryProfile({
    required this.id,
    required this.monthlyGross,
    required this.monthlyNet,
    this.payDayOfMonth = 15,
    this.employerName = 'TechCorp LLC',
    this.taxWithheld = Money.zero,
    this.deductions = Money.zero,
    this.savingsGoalMonthly = Money.zero,
    this.nextPayDate,
  });

  final String id;
  final Money monthlyGross;
  final Money monthlyNet;
  final int payDayOfMonth;
  final String employerName;
  final Money taxWithheld;
  final Money deductions;
  final Money savingsGoalMonthly;
  final DateTime? nextPayDate;

  SalaryProfile copyWith({
    String? id,
    Money? monthlyGross,
    Money? monthlyNet,
    int? payDayOfMonth,
    String? employerName,
    Money? taxWithheld,
    Money? deductions,
    Money? savingsGoalMonthly,
    DateTime? nextPayDate,
  }) {
    return SalaryProfile(
      id: id ?? this.id,
      monthlyGross: monthlyGross ?? this.monthlyGross,
      monthlyNet: monthlyNet ?? this.monthlyNet,
      payDayOfMonth: payDayOfMonth ?? this.payDayOfMonth,
      employerName: employerName ?? this.employerName,
      taxWithheld: taxWithheld ?? this.taxWithheld,
      deductions: deductions ?? this.deductions,
      savingsGoalMonthly: savingsGoalMonthly ?? this.savingsGoalMonthly,
      nextPayDate: nextPayDate ?? this.nextPayDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalaryProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
