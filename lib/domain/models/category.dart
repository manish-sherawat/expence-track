import 'money.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorHex,
    this.budgetMonthly,
    this.parentCategoryId,
  });

  final String id;
  final String name;
  final String iconKey;
  final int colorHex;
  final Money? budgetMonthly;
  final String? parentCategoryId;

  Category copyWith({
    String? id,
    String? name,
    String? iconKey,
    int? colorHex,
    Money? budgetMonthly,
    String? parentCategoryId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      budgetMonthly: budgetMonthly ?? this.budgetMonthly,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
