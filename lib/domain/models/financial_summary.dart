import 'money.dart';

class FinancialSummary {
  const FinancialSummary({
    required this.month,
    required this.year,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSaved,
    required this.dailyAverage,
    required this.momChangePercentage,
    required this.rentSharePercentage,
    required this.biggestCategoryName,
    required this.biggestCategoryAmount,
    required this.aiSavingsFound,
  });

  final int month;
  final int year;
  final Money totalBalance;
  final Money totalIncome;
  final Money totalExpenses;
  final Money totalSaved;
  final Money dailyAverage;
  final double momChangePercentage;
  final double rentSharePercentage;
  final String biggestCategoryName;
  final Money biggestCategoryAmount;
  final Money aiSavingsFound;

  /// Percentage of income saved (e.g. 0.26 for 26%).
  double get savingsRate =>
      totalIncome.cents == 0 ? 0.0 : (totalSaved.cents / totalIncome.cents);

  /// Percentage of income spent.
  double get expenseRatio =>
      totalIncome.cents == 0 ? 0.0 : (totalExpenses.cents / totalIncome.cents);

  /// Aliases and convenience getters
  String get topCategoryName => biggestCategoryName;
  double get topCategoryPercentage => rentSharePercentage;
  double get monthOverMonthExpenseChange => momChangePercentage;
  Money get dailyAverageExpense => dailyAverage;
  Money get topCategorySpend => biggestCategoryAmount;
  Money get projectedSavings => aiSavingsFound;

  FinancialSummary copyWith({
    int? month,
    int? year,
    Money? totalBalance,
    Money? totalIncome,
    Money? totalExpenses,
    Money? totalSaved,
    Money? dailyAverage,
    double? momChangePercentage,
    double? rentSharePercentage,
    String? biggestCategoryName,
    Money? biggestCategoryAmount,
    Money? aiSavingsFound,
  }) {
    return FinancialSummary(
      month: month ?? this.month,
      year: year ?? this.year,
      totalBalance: totalBalance ?? this.totalBalance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalSaved: totalSaved ?? this.totalSaved,
      dailyAverage: dailyAverage ?? this.dailyAverage,
      momChangePercentage: momChangePercentage ?? this.momChangePercentage,
      rentSharePercentage: rentSharePercentage ?? this.rentSharePercentage,
      biggestCategoryName: biggestCategoryName ?? this.biggestCategoryName,
      biggestCategoryAmount: biggestCategoryAmount ?? this.biggestCategoryAmount,
      aiSavingsFound: aiSavingsFound ?? this.aiSavingsFound,
    );
  }
}
