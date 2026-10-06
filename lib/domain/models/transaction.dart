import 'money.dart';

enum TransactionType {
  expense,
  income,
  transfer,
}

class Transaction {
  const Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    this.merchantId,
    required this.amount,
    required this.timestamp,
    required this.title,
    required this.subtitle,
    this.note,
    this.aiSuggestedCategory,
    this.aiConfirmed = false,
    this.cardLastFour,
    this.hasReceipt = false,
    this.type = TransactionType.expense,
  });

  final String id;
  final String accountId;
  final String categoryId;
  final String? merchantId;
  final Money amount;
  final DateTime timestamp;
  final String title;
  final String subtitle;
  final String? note;
  final String? aiSuggestedCategory;
  final bool aiConfirmed;
  final String? cardLastFour;
  final bool hasReceipt;
  final TransactionType type;

  bool get isExpense => type == TransactionType.expense || (type != TransactionType.income && amount.isNegative);
  bool get isIncome => type == TransactionType.income || (type != TransactionType.expense && amount.isPositive);

  Transaction copyWith({
    String? id,
    String? accountId,
    String? categoryId,
    String? merchantId,
    Money? amount,
    DateTime? timestamp,
    String? title,
    String? subtitle,
    String? note,
    String? aiSuggestedCategory,
    bool? aiConfirmed,
    String? cardLastFour,
    bool? hasReceipt,
    TransactionType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      merchantId: merchantId ?? this.merchantId,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      note: note ?? this.note,
      aiSuggestedCategory: aiSuggestedCategory ?? this.aiSuggestedCategory,
      aiConfirmed: aiConfirmed ?? this.aiConfirmed,
      cardLastFour: cardLastFour ?? this.cardLastFour,
      hasReceipt: hasReceipt ?? this.hasReceipt,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
