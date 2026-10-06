import 'money.dart';

enum AccountType {
  checking,
  savings,
  creditCard,
  investment,
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.lastFour,
    this.institution = 'Default Bank',
    this.isDefault = false,
  });

  final String id;
  final String name;
  final AccountType type;
  final Money balance;
  final String? lastFour;
  final String institution;
  final bool isDefault;

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    Money? balance,
    String? lastFour,
    String? institution,
    bool? isDefault,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      lastFour: lastFour ?? this.lastFour,
      institution: institution ?? this.institution,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
