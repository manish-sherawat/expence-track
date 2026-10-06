import '../../domain/models/account.dart';
import '../../domain/models/ai_insight.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/category.dart';
import '../../domain/models/financial_summary.dart';
import '../../domain/models/merchant.dart';
import '../../domain/models/money.dart';
import '../../domain/models/receipt.dart';
import '../../domain/models/salary_profile.dart';
import '../../domain/models/transaction.dart';

class MockupSeedData {
  static final DateTime now = DateTime(2026, 4, 15, 14, 30);

  // --- Accounts ---
  static const String checkingId = 'acc_checking_01';
  static const String savingsId = 'acc_savings_01';

  static final List<Account> accounts = [
    const Account(
      id: checkingId,
      name: 'Primary Checking',
      type: AccountType.checking,
      balance: Money(842940), // $8,429.40
      lastFour: '4829',
      institution: 'Chase Bank',
      isDefault: true,
    ),
    const Account(
      id: savingsId,
      name: 'High Yield Savings',
      type: AccountType.savings,
      balance: Money(446350), // $4,463.50
      lastFour: '9102',
      institution: 'Marcus by Goldman Sachs',
      isDefault: false,
    ),
  ];

  // Total balance: $8,429.40 + $4,463.50 = $12,892.90
  static const Money totalBalance = Money(1289290);

  // --- Categories ---
  static const String catRent = 'cat_rent';
  static const String catFood = 'cat_food';
  static const String catTransport = 'cat_transport';
  static const String catShopping = 'cat_shopping';
  static const String catSalary = 'cat_salary';
  static const String catSavings = 'cat_savings';

  static final List<Category> categories = [
    const Category(
      id: catRent,
      name: 'Rent',
      iconKey: 'rent',
      colorHex: 0xFF5B616E,
      budgetMonthly: Money(120000), // $1,200.00
    ),
    const Category(
      id: catFood,
      name: 'Food',
      iconKey: 'food',
      colorHex: 0xFFFF5C00,
      budgetMonthly: Money(70000), // $700.00 limit
    ),
    const Category(
      id: catTransport,
      name: 'Transport',
      iconKey: 'transport',
      colorHex: 0xFF2B7FFF,
      budgetMonthly: Money(50000), // $500.00 limit
    ),
    const Category(
      id: catShopping,
      name: 'Shopping',
      iconKey: 'shopping',
      colorHex: 0xFF9855FF,
      budgetMonthly: Money(60000), // $600.00 limit
    ),
    const Category(
      id: catSalary,
      name: 'Salary',
      iconKey: 'wallet',
      colorHex: 0xFF148750,
    ),
    const Category(
      id: catSavings,
      name: 'Savings',
      iconKey: 'chart',
      colorHex: 0xFF0D9488,
    ),
  ];

  // --- Merchants ---
  static const String merchWholeFoods = 'merch_whole_foods';
  static const String merchUber = 'merch_uber';
  static const String merchBlueBottle = 'merch_blue_bottle';
  static const String merchApple = 'merch_apple';
  static const String merchTechCorp = 'merch_tech_corp';
  static const String merchLandlord = 'merch_landlord';

  static final List<Merchant> merchants = [
    const Merchant(
      id: merchWholeFoods,
      name: 'Whole Foods Market',
      category: 'Groceries & Organic Food',
      visitCount: 8,
      totalSpent: Money(48920), // $489.20 across 8 visits
      iconKey: 'food',
      address: '250 E 57th St, New York, NY 10022',
      phone: '(212) 759-8457',
    ),
    const Merchant(
      id: merchUber,
      name: 'Uber Trip',
      category: 'Ride Sharing & Mobility',
      visitCount: 14,
      totalSpent: Money(34210), // $342.10
      iconKey: 'transport',
      address: 'San Francisco, CA',
    ),
    const Merchant(
      id: merchBlueBottle,
      name: 'Blue Bottle Coffee',
      category: 'Coffee & Cafe',
      visitCount: 19,
      totalSpent: Money(12850), // $128.50
      iconKey: 'food',
      address: '1 Rockefeller Plaza, New York, NY',
    ),
    const Merchant(
      id: merchApple,
      name: 'Apple Store',
      category: 'Electronics & Software',
      visitCount: 2,
      totalSpent: Money(29900), // $299.00
      iconKey: 'shopping',
      address: '767 5th Ave, New York, NY 10153',
    ),
    const Merchant(
      id: merchTechCorp,
      name: 'TechCorp LLC',
      category: 'Employer Payroll',
      visitCount: 8,
      totalSpent: Money.zero,
      iconKey: 'wallet',
      address: '500 Howard St, San Francisco, CA',
    ),
    const Merchant(
      id: merchLandlord,
      name: 'Metropolitan Real Estate',
      category: 'Residential Lease',
      visitCount: 4,
      totalSpent: Money(480000), // $4,800.00
      iconKey: 'rent',
    ),
  ];

  // --- Transactions ---
  static const String txnWholeFoods = 'txn_wf_01';

  static final List<Transaction> transactions = [
    // Today: Apr 14, 2026
    Transaction(
      id: txnWholeFoods,
      accountId: checkingId,
      categoryId: catFood,
      merchantId: merchWholeFoods,
      amount: const Money(-3291), // -$32.91
      timestamp: DateTime(2026, 4, 14, 14, 45),
      title: 'Whole Foods Market',
      subtitle: 'Groceries • 2:45 PM',
      aiSuggestedCategory: 'Groceries',
      aiConfirmed: true,
      cardLastFour: '4829',
      hasReceipt: true,
      type: TransactionType.expense,
    ),
    Transaction(
      id: 'txn_uber_01',
      accountId: checkingId,
      categoryId: catTransport,
      merchantId: merchUber,
      amount: const Money(-2450), // -$24.50
      timestamp: DateTime(2026, 4, 14, 11, 20),
      title: 'Uber Trip',
      subtitle: 'Ride • 11:20 AM',
      aiSuggestedCategory: 'Transport',
      aiConfirmed: true,
      cardLastFour: '4829',
      type: TransactionType.expense,
    ),
    // Yesterday: Apr 13, 2026
    Transaction(
      id: 'txn_salary_01',
      accountId: checkingId,
      categoryId: catSalary,
      merchantId: merchTechCorp,
      amount: const Money(421450), // +$4,214.50
      timestamp: DateTime(2026, 4, 13, 9, 0),
      title: 'Salary Deposit',
      subtitle: 'TechCorp LLC • Direct Deposit',
      aiSuggestedCategory: null,
      aiConfirmed: true,
      type: TransactionType.income,
    ),
    Transaction(
      id: 'txn_blue_bottle_01',
      accountId: checkingId,
      categoryId: catFood,
      merchantId: merchBlueBottle,
      amount: const Money(-675), // -$6.75
      timestamp: DateTime(2026, 4, 13, 9, 15),
      title: 'Blue Bottle Coffee',
      subtitle: 'Cafe • 9:15 AM',
      aiSuggestedCategory: 'Dining',
      aiConfirmed: true,
      cardLastFour: '4829',
      type: TransactionType.expense,
    ),
    // Apr 12, 2026
    Transaction(
      id: 'txn_apple_01',
      accountId: checkingId,
      categoryId: catShopping,
      merchantId: merchApple,
      amount: const Money(-14900), // -$149.00
      timestamp: DateTime(2026, 4, 12, 16, 10),
      title: 'Apple Store',
      subtitle: 'Electronics • 4:10 PM',
      aiSuggestedCategory: 'Electronics',
      aiConfirmed: true,
      cardLastFour: '4829',
      type: TransactionType.expense,
    ),
    // Older April transactions to reach exact totals:
    // Rent: $1,200.00
    Transaction(
      id: 'txn_rent_01',
      accountId: checkingId,
      categoryId: catRent,
      merchantId: merchLandlord,
      amount: const Money(-120000), // -$1,200.00
      timestamp: DateTime(2026, 4, 1, 8, 0),
      title: 'Rent Payment',
      subtitle: 'Monthly Apartment Lease',
      aiConfirmed: true,
      cardLastFour: '4829',
      type: TransactionType.expense,
    ),
    // Second Salary on Apr 1st:
    Transaction(
      id: 'txn_salary_02',
      accountId: checkingId,
      categoryId: catSalary,
      merchantId: merchTechCorp,
      amount: const Money(421450), // +$4,214.50 -> Total Income: $8,429.00
      timestamp: DateTime(2026, 4, 1, 9, 0),
      title: 'Salary Deposit',
      subtitle: 'TechCorp LLC • Direct Deposit',
      aiConfirmed: true,
      type: TransactionType.income,
    ),
    // Additional Food transactions (to reach $850.00 total Food: $32.91 + $6.75 + $810.34)
    Transaction(
      id: 'txn_wf_02',
      accountId: checkingId,
      categoryId: catFood,
      merchantId: merchWholeFoods,
      amount: const Money(-6784), // -$67.84 (matches merchant history)
      timestamp: DateTime(2026, 4, 8, 17, 30),
      title: 'Whole Foods Market',
      subtitle: 'Groceries',
      aiSuggestedCategory: 'Groceries',
      aiConfirmed: true,
      cardLastFour: '4829',
      type: TransactionType.expense,
    ),
    Transaction(
      id: 'txn_wf_03',
      accountId: checkingId,
      categoryId: catFood,
      merchantId: merchWholeFoods,
      amount: const Money(-2450), // -$24.50 (matches merchant history)
      timestamp: DateTime(2026, 4, 2, 12, 15),
      title: 'Whole Foods Market',
      subtitle: 'Groceries',
      aiSuggestedCategory: 'Groceries',
      aiConfirmed: true,
      cardLastFour: '4829',
      type: TransactionType.expense,
    ),
    Transaction(
      id: 'txn_dining_01',
      accountId: checkingId,
      categoryId: catFood,
      amount: const Money(-71800), // -$718.00 -> Food sum = 32.91 + 6.75 + 67.84 + 24.50 + 718.00 = 850.00
      timestamp: DateTime(2026, 4, 10, 19, 45),
      title: 'Gramercy Tavern',
      subtitle: 'Dining Out',
      aiSuggestedCategory: 'Dining',
      aiConfirmed: true,
      cardLastFour: '4829',
      type: TransactionType.expense,
    ),
    // Additional Transport transactions (to reach $420.00 total Transport: $24.50 + $395.50)
    Transaction(
      id: 'txn_transport_01',
      accountId: checkingId,
      categoryId: catTransport,
      amount: const Money(-39550), // -$395.50 -> Transport sum = 24.50 + 395.50 = 420.00
      timestamp: DateTime(2026, 4, 5, 8, 30),
      title: 'MTA Monthly Transit Pass',
      subtitle: 'Subway & Bus',
      aiSuggestedCategory: 'Transport',
      aiConfirmed: true,
      cardLastFour: '4829',
      type: TransactionType.expense,
    ),
    // Additional Shopping transactions (to reach $748.00 total Shopping: $149.00 + $599.00)
    Transaction(
      id: 'txn_shopping_01',
      accountId: checkingId,
      categoryId: catShopping,
      amount: const Money(-59900), // -$599.00 -> Shopping sum = 149.00 + 599.00 = 748.00
      timestamp: DateTime(2026, 4, 6, 14, 20),
      title: 'Nordstrom',
      subtitle: 'Clothing & Apparel',
      aiSuggestedCategory: 'Shopping',
      aiConfirmed: true,
      cardLastFour: '4829',
      type: TransactionType.expense,
    ),
    // Monthly Savings Transfer: $2,190.00
    Transaction(
      id: 'txn_savings_transfer_01',
      accountId: checkingId,
      categoryId: catSavings,
      amount: const Money(-219000), // Transfer out to savings: $2,190.00
      timestamp: DateTime(2026, 4, 1, 10, 0),
      title: 'Transfer to High Yield Savings',
      subtitle: 'Monthly Automated Savings',
      aiConfirmed: true,
      type: TransactionType.transfer,
    ),
  ];

  // --- Receipts ---
  static final Receipt wholeFoodsReceipt = Receipt(
    id: 'rcpt_wf_01',
    transactionId: txnWholeFoods,
    merchantName: 'Whole Foods Market',
    timestamp: DateTime(2026, 4, 14, 14, 45),
    items: const [
      ReceiptLineItem(
        id: 'item_1',
        receiptId: 'rcpt_wf_01',
        name: 'Organic Oat Milk',
        quantity: 2,
        price: Money(998), // $9.98
      ),
      ReceiptLineItem(
        id: 'item_2',
        receiptId: 'rcpt_wf_01',
        name: 'Avocados (Hass)',
        quantity: 4,
        price: Money(600), // $6.00
      ),
      ReceiptLineItem(
        id: 'item_3',
        receiptId: 'rcpt_wf_01',
        name: 'Greek Yogurt 32oz',
        quantity: 1,
        price: Money(749), // $7.49
      ),
      ReceiptLineItem(
        id: 'item_4',
        receiptId: 'rcpt_wf_01',
        name: 'Artisan Sourdough',
        quantity: 1,
        price: Money(699), // $6.99
      ),
    ],
    subtotal: const Money(3046), // $30.46
    tax: const Money(245), // $2.45
    total: const Money(3291), // $32.91
    rawOcrText: 'WHOLE FOODS MARKET #1042\n250 E 57TH ST\nORGANIC OAT MILK 2 @ 4.99: 9.98\nHASS AVOCADOS 4 @ 1.50: 6.00\nGREEK YOGURT 32OZ: 7.49\nARTISAN SOURDOUGH: 6.99\nSUBTOTAL: 30.46\nTAX: 2.45\nTOTAL: 32.91\nVISA *4829',
  );

  // --- Budgets ---
  static final List<Budget> budgets = [
    const Budget(
      id: 'bgt_food_apr26',
      categoryId: catFood,
      limitAmount: Money(70000), // $700.00
      spentAmount: Money(85000), // $850.00 (Over by $150.00)
      month: 4,
      year: 2026,
    ),
    const Budget(
      id: 'bgt_transport_apr26',
      categoryId: catTransport,
      limitAmount: Money(50000), // $500.00
      spentAmount: Money(42000), // $420.00 (Under by $80.00)
      month: 4,
      year: 2026,
    ),
    const Budget(
      id: 'bgt_shopping_apr26',
      categoryId: catShopping,
      limitAmount: Money(60000), // $600.00
      spentAmount: Money(74800), // $748.00 (Over by $148.00)
      month: 4,
      year: 2026,
    ),
    const Budget(
      id: 'bgt_rent_apr26',
      categoryId: catRent,
      limitAmount: Money(120000), // $1,200.00
      spentAmount: Money(120000), // $1,200.00 (Exact)
      month: 4,
      year: 2026,
    ),
  ];

  // --- Salary Profile ---
  static final SalaryProfile salaryProfile = SalaryProfile(
    id: 'sal_profile_01',
    monthlyGross: const Money(1050000), // $10,500.00
    monthlyNet: const Money(842900), // $8,429.00
    payDayOfMonth: 15,
    employerName: 'TechCorp LLC',
    taxWithheld: const Money(157100), // $1,571.00
    deductions: const Money(50000), // $500.00 (401k & Healthcare)
    savingsGoalMonthly: const Money(219000), // $2,190.00
    nextPayDate: DateTime(2026, 4, 15),
  );

  // --- AI Insights ---
  static final List<AiInsight> insights = [
    AiInsight(
      id: 'insight_dining_overrun',
      title: 'Dining Budget Velocity Warning',
      description:
          'You may exceed dining budget by \$420 by month end based on current velocity.',
      type: AiInsightType.overrunWarning,
      impactAmount: const Money(42000), // $420.00
      categoryId: catFood,
      actionLabel: 'Review & adjust',
      routePath: '/insight',
      createdAt: DateTime(2026, 4, 14, 10, 0),
    ),
    AiInsight(
      id: 'insight_sub_savings',
      title: 'Subscription Optimization',
      description: 'Found \$184.00/mo in unused streaming & recurring gym memberships.',
      type: AiInsightType.savingFound,
      impactAmount: const Money(18400), // $184.00
      categoryId: catShopping,
      actionLabel: 'View details',
      routePath: '/insight',
      createdAt: DateTime(2026, 4, 12, 14, 0),
    ),
  ];

  // --- Financial Summary ---
  static const FinancialSummary summary = FinancialSummary(
    month: 4,
    year: 2026,
    totalBalance: totalBalance, // $12,892.90
    totalIncome: Money(842900), // $8,429.00
    totalExpenses: Money(321800), // $3,218.00
    totalSaved: Money(219000), // $2,190.00
    dailyAverage: Money(10726), // $107.26 (30 days in April)
    momChangePercentage: -4.2, // -4.2% vs March 2026
    rentSharePercentage: 37.0, // 37% of total expenses
    biggestCategoryName: 'Rent',
    biggestCategoryAmount: Money(120000), // $1,200.00
    aiSavingsFound: Money(18400), // $184.00
  );
}
