import 'package:drift/drift.dart';

@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // checking, savings, creditCard, investment
  IntColumn get balanceMinor => integer()();
  TextColumn get lastFour => text().nullable()();
  TextColumn get institution => text().withDefault(const Constant('Default Bank'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconKey => text()();
  IntColumn get colorHex => integer()();
  IntColumn get budgetMonthlyMinor => integer().nullable()();
  TextColumn get parentCategoryId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MerchantRow')
class Merchants extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text().withDefault(const Constant('Retail'))();
  IntColumn get visitCount => integer().withDefault(const Constant(1))();
  IntColumn get totalSpentMinor => integer().withDefault(const Constant(0))();
  TextColumn get iconKey => text().withDefault(const Constant('shopping'))();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get merchantId => text().nullable().references(Merchants, #id)();
  IntColumn get amountMinor => integer()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get title => text()();
  TextColumn get subtitle => text()();
  TextColumn get note => text().nullable()();
  TextColumn get aiSuggestedCategory => text().nullable()();
  BoolColumn get aiConfirmed => boolean().withDefault(const Constant(false))();
  TextColumn get cardLastFour => text().nullable()();
  BoolColumn get hasReceipt => boolean().withDefault(const Constant(false))();
  TextColumn get type => text().withDefault(const Constant('expense'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ReceiptRow')
class Receipts extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get merchantName => text()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get subtotalMinor => integer()();
  IntColumn get taxMinor => integer()();
  IntColumn get totalMinor => integer()();
  TextColumn get rawOcrText => text().nullable()();
  TextColumn get imageUrl => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ReceiptItemRow')
class ReceiptItems extends Table {
  TextColumn get id => text()();
  TextColumn get receiptId => text().references(Receipts, #id)();
  TextColumn get name => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get priceMinor => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BudgetRow')
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  IntColumn get limitMinor => integer()();
  IntColumn get spentMinor => integer().withDefault(const Constant(0))();
  TextColumn get period => text().withDefault(const Constant('monthly'))();
  IntColumn get month => integer()();
  IntColumn get year => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SalaryProfileRow')
class SalaryProfiles extends Table {
  TextColumn get id => text()();
  IntColumn get monthlyGrossMinor => integer()();
  IntColumn get monthlyNetMinor => integer()();
  IntColumn get payDayOfMonth => integer().withDefault(const Constant(15))();
  TextColumn get employerName => text().withDefault(const Constant('TechCorp LLC'))();
  IntColumn get taxWithheldMinor => integer().withDefault(const Constant(0))();
  IntColumn get deductionsMinor => integer().withDefault(const Constant(0))();
  IntColumn get savingsGoalMonthlyMinor => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextPayDate => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('InsightRow')
class Insights extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get type => text()();
  IntColumn get impactAmountMinor => integer().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get actionLabel => text().withDefault(const Constant('Review & adjust'))();
  TextColumn get routePath => text().withDefault(const Constant('/insight'))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isDismissed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
