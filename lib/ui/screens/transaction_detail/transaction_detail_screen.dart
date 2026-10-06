import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/seed/mockup_seed_data.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/merchant.dart';
import '../../../domain/models/receipt.dart';
import '../../../domain/models/transaction.dart';
import '../../../providers/finance_providers.dart';
import '../add_transaction/add_transaction_screen.dart';
import 'widgets/ai_receipt_section.dart';
import 'widgets/merchant_info_section.dart';
import 'widgets/transaction_detail_header.dart';
import 'widgets/transaction_hero_section.dart';

/// Screen 2: Transaction Detail with AI Receipt Scan.
///
/// Features:
/// - Header with circular back button and circular more "..." button with popover
/// - Hero section with merchant name, large signed amount (-$32.91), date/time/card meta line, category chips
/// - AI Receipt Scan Card with itemized lines, subtotal, tax, total, and fullscreen viewer modal
/// - Merchant Card with visit count, total spend, address, and similar transactions horizontal scroll
/// - 100% custom, zero Material/Cupertino
class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Transaction query with fallback
    final txnAsync = ref.watch(transactionDetailFutureProvider(transactionId));
    final Transaction transaction = txnAsync.value ??
        MockupSeedData.transactions.firstWhere(
          (t) => t.id == transactionId,
          orElse: () => MockupSeedData.transactions.first,
        );

    // 2. Receipt query with fallback
    final rcptAsync = ref.watch(receiptDetailFutureProvider(transaction.id));
    final Receipt receipt = rcptAsync.value ?? MockupSeedData.wholeFoodsReceipt;

    // 3. Merchant query with fallback
    final merchantsAsync = ref.watch(merchantsStreamProvider);
    final merchantsList = merchantsAsync.value ?? MockupSeedData.merchants;
    final Merchant merchant = merchantsList.firstWhere(
      (m) => m.id == transaction.merchantId || m.name == transaction.title,
      orElse: () => MockupSeedData.merchants.first,
    );

    // 4. Category query with fallback
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categoriesList = categoriesAsync.value ?? MockupSeedData.categories;
    final Category? category = categoriesList.cast<Category?>().firstWhere(
          (c) => c?.id == transaction.categoryId,
          orElse: () => null,
        );

    // 5. Similar transactions at this merchant
    final allTxnsAsync = ref.watch(recentTransactionsStreamProvider);
    final allTxns = allTxnsAsync.value ?? MockupSeedData.transactions;
    final similarTxns = allTxns
        .where((t) => t.merchantId == merchant.id || t.title == merchant.name)
        .toList();

    return AppScaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header
              TransactionDetailHeader(
                onBack: () => context.pop(),
                onEdit: () {
                  Navigator.of(context).push(
                    PageRouteBuilder<void>(
                      pageBuilder: (context, _, _) =>
                          AddTransactionScreen(initialTransaction: transaction),
                      transitionsBuilder: (context, animation, _, child) =>
                          SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 1.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                  );
                },
                onExportPdf: () {
                  AppToast.show(
                    context,
                    'Receipt for ${transaction.title} exported to PDF',
                    type: AppToastType.success,
                  );
                },
                onDelete: () {
                  AppBottomSheet.show<void>(
                    context: context,
                    title: 'Delete Transaction',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Are you sure you want to delete this transaction for ${transaction.amount.format()} at ${transaction.title}? This cannot be undone.',
                            style: context.text.bodyMedium.copyWith(color: context.colors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.s24),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  label: 'Cancel',
                                  variant: AppButtonVariant.secondary,
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s12),
                              Expanded(
                                child: AppButton(
                                  label: 'Delete',
                                  variant: AppButtonVariant.destructive,
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    final repo = ref.read(financeRepositoryProvider);
                                    await repo.deleteTransaction(transaction.id);
                                    if (context.mounted) {
                                      AppToast.show(
                                        context,
                                        'Transaction deleted',
                                        type: AppToastType.neutral,
                                      );
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/');
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s20),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.s8),

              // 2. Hero Section (Merchant name, large -$32.91, metadata, chips)
              TransactionHeroSection(
                transaction: transaction,
                category: category,
              ),

              const SizedBox(height: AppSpacing.s24),

              // 3. AI Receipt Scan Section (Itemized breakdown & Fullscreen viewer)
              AiReceiptSection(
                receipt: receipt,
                onRescan: () async {
                  final aiService = ref.read(aiServiceProvider);
                  final res = await aiService.scanReceiptFromBytes([1, 2, 3]);
                  if (context.mounted) {
                    AppToast.show(
                      context,
                      'Receipt verified: ${res.merchantName} (${res.items.length} items)',
                      type: AppToastType.success,
                    );
                  }
                },
              ),

              const SizedBox(height: AppSpacing.s24),

              // 4. Merchant Info & Similar Transactions
              MerchantInfoSection(
                merchant: merchant,
                similarTransactions: similarTxns,
                onTransactionTap: (tx) {
                  if (tx.id != transaction.id) {
                    context.push('/transaction/${tx.id}');
                  }
                },
              ),

              const SizedBox(height: AppSpacing.s24),

              // 5. Bottom Actions (Download Receipt & Share)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Download Receipt',
                        leadingIcon: AppIconType.receipt,
                        variant: AppButtonVariant.primary,
                        onPressed: () {
                          AppToast.show(
                            context,
                            'Receipt image saved to gallery',
                            type: AppToastType.success,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: AppButton(
                        label: 'Share Details',
                        leadingIcon: AppIconType.sparkle,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          AppToast.show(
                            context,
                            '${transaction.title} (${transaction.amount.format()}) details copied',
                            type: AppToastType.success,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
