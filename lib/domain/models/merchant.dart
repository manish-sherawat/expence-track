import 'money.dart';

class Merchant {
  const Merchant({
    required this.id,
    required this.name,
    this.category = 'Retail',
    this.visitCount = 1,
    this.totalSpent = Money.zero,
    this.iconKey = 'shopping',
    this.address,
    this.phone,
  });

  final String id;
  final String name;
  final String category;
  final int visitCount;
  final Money totalSpent;
  final String iconKey;
  final String? address;
  final String? phone;

  Merchant copyWith({
    String? id,
    String? name,
    String? category,
    int? visitCount,
    Money? totalSpent,
    String? iconKey,
    String? address,
    String? phone,
  }) {
    return Merchant(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      visitCount: visitCount ?? this.visitCount,
      totalSpent: totalSpent ?? this.totalSpent,
      iconKey: iconKey ?? this.iconKey,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Merchant &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
