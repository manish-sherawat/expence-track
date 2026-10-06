import 'money.dart';

enum AiInsightType {
  overrunWarning,
  savingFound,
  spendingVelocity,
  recurringSubscription,
}

class AiInsight {
  const AiInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.impactAmount,
    this.categoryId,
    this.actionLabel = 'Review & adjust',
    this.routePath = '/insight',
    required this.createdAt,
    this.isDismissed = false,
  });

  final String id;
  final String title;
  final String description;
  final AiInsightType type;
  final Money? impactAmount;
  final String? categoryId;
  final String actionLabel;
  final String routePath;
  final DateTime createdAt;
  final bool isDismissed;

  AiInsight copyWith({
    String? id,
    String? title,
    String? description,
    AiInsightType? type,
    Money? impactAmount,
    String? categoryId,
    String? actionLabel,
    String? routePath,
    DateTime? createdAt,
    bool? isDismissed,
  }) {
    return AiInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      impactAmount: impactAmount ?? this.impactAmount,
      categoryId: categoryId ?? this.categoryId,
      actionLabel: actionLabel ?? this.actionLabel,
      routePath: routePath ?? this.routePath,
      createdAt: createdAt ?? this.createdAt,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiInsight &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
