import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/seed/mockup_seed_data.dart';
import '../../../data/services/local_ai_service.dart';
import '../../../data/services/mlkit_document_scanner_service.dart';
import '../../../data/services/mlkit_ocr_service.dart';
import '../../../data/services/receipt_storage_service.dart';
import '../../../design_system/components/components.dart' hide ReceiptLineItem;
import '../../../design_system/tokens/tokens.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/money.dart';
import '../../../domain/models/receipt.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/services/i_ai_service.dart';
import '../../../providers/finance_providers.dart';
import '../scanner/receipt_scanner_review_screen.dart';

/// Screen for adding a new transaction or editing an existing one.
///
/// Features:
/// - Custom tactile numeric keypad (AmountKeypad)
/// - Expense vs Income segmented switch
/// - Real-time AI category suggestion chip as user types merchant name
/// - Category selector with custom icon badges
/// - Account / Card picker dropdown
/// - Optional receipt attachment with AI auto-fill
/// - 100% custom widgets, zero Material / Cupertino
class AddTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? initialTransaction;

  const AddTransactionScreen({
    super.key,
    this.initialTransaction,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late TransactionType _type;
  String _amountInput = '0';
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  String? _aiSuggestedCategory;
  bool _hasReceipt = false;
  Receipt? _scannedReceipt;

  final LocalAiService _aiService = const LocalAiService();

  @override
  void initState() {
    super.initState();
    final init = widget.initialTransaction;
    if (init != null) {
      _type = init.type;
      final dollars = init.amount.cents.abs() / 100.0;
      _amountInput = dollars.toStringAsFixed(2);
      _titleController = TextEditingController(text: init.title);
      _notesController = TextEditingController(text: init.note ?? '');
      _selectedCategoryId = init.categoryId;
      _selectedAccountId = init.accountId;
      _hasReceipt = init.hasReceipt;
    } else {
      _type = TransactionType.expense;
      _amountInput = '0';
      _titleController = TextEditingController();
      _notesController = TextEditingController();
      _selectedCategoryId = MockupSeedData.catFood;
      _selectedAccountId = MockupSeedData.checkingId;
      _hasReceipt = false;
    }

    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    final text = _titleController.text.trim();
    if (text.length >= 3) {
      _aiService.suggestCategoryForMerchant(text).then((suggested) {
        if (mounted && suggested != null && suggested != _selectedCategoryId) {
          setState(() {
            _aiSuggestedCategory = suggested;
          });
        }
      });
    } else {
      if (_aiSuggestedCategory != null) {
        setState(() {
          _aiSuggestedCategory = null;
        });
      }
    }
  }

  int get _amountCents {
    final parsed = double.tryParse(_amountInput) ?? 0.0;
    final minor = (parsed * 100).round();
    return _type == TransactionType.expense ? -minor.abs() : minor.abs();
  }

  void _handleDigit(String digit) {
    setState(() {
      if (_amountInput == '0') {
        _amountInput = digit;
      } else {
        // Enforce max 2 decimal places
        if (_amountInput.contains('.')) {
          final parts = _amountInput.split('.');
          if (parts[1].length < 2) {
            _amountInput += digit;
          }
        } else if (_amountInput.length < 7) {
          _amountInput += digit;
        }
      }
    });
  }

  void _handleDecimal() {
    setState(() {
      if (!_amountInput.contains('.')) {
        _amountInput += '.';
      }
    });
  }

  void _handleBackspace() {
    setState(() {
      if (_amountInput.length <= 1) {
        _amountInput = '0';
      } else {
        _amountInput = _amountInput.substring(0, _amountInput.length - 1);
        if (_amountInput.isEmpty) _amountInput = '0';
      }
    });
  }

  Future<void> _handleScanReceipt() async {
    try {
      final scannerService = MlKitDocumentScannerService(
        sampleReceiptPath: 'assets/receipts/sample_receipt.jpg',
      );
      final imagePath = await scannerService.scanDocument();
      if (imagePath == null || !mounted) return;

      final ocrService = MlKitOcrService();
      final rawText = await ocrService.recognizeTextFromFile(imagePath);
      await ocrService.dispose();

      final parsed = await _aiService.parseReceiptText(rawText);
      if (!mounted) return;

      final confirmedResult = await Navigator.of(context).push<ReceiptScanResult>(
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => ReceiptScannerReviewScreen(
            imagePath: imagePath,
            initialResult: parsed,
            onRetake: () {
              Navigator.of(context).pop();
              _handleScanReceipt();
            },
          ),
        ),
      );

      if (confirmedResult != null && mounted) {
        setState(() {
          _hasReceipt = true;
          _amountInput = (confirmedResult.total.cents / 100.0).toStringAsFixed(2);
          if (confirmedResult.merchantName.isNotEmpty) {
            _titleController.text = confirmedResult.merchantName;
          }
        });

        String savedPath = imagePath;
        try {
          const storageService = ReceiptStorageService();
          savedPath = await storageService.saveReceiptImage(sourcePath: imagePath);
        } catch (_) {}

        final receiptId = 'rcpt_${DateTime.now().millisecondsSinceEpoch}';
        final receiptItems = confirmedResult.items.map((ReceiptLineItem item) {
          return ReceiptLineItem(
            id: 'item_${DateTime.now().microsecondsSinceEpoch}_${item.name.hashCode}',
            receiptId: receiptId,
            name: item.name,
            quantity: item.quantity,
            price: item.price,
          );
        }).toList();

        final receipt = Receipt(
          id: receiptId,
          transactionId: widget.initialTransaction?.id ?? '',
          merchantName: confirmedResult.merchantName,
          timestamp: DateTime.now(),
          items: receiptItems,
          subtotal: confirmedResult.subtotal,
          tax: confirmedResult.tax,
          total: confirmedResult.total,
          rawOcrText: confirmedResult.rawText,
          imageUrl: savedPath,
        );

        if (mounted) {
          setState(() {
            _scannedReceipt = receipt;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }
    if (_amountCents == 0) {
      return;
    }

    final repo = ref.read(financeRepositoryProvider);
    final id = widget.initialTransaction?.id ?? 'txn_${DateTime.now().millisecondsSinceEpoch}';
    final cardLastFour = _selectedAccountId == MockupSeedData.checkingId ? '4829' : '9102';

    final transaction = Transaction(
      id: id,
      accountId: _selectedAccountId ?? MockupSeedData.checkingId,
      categoryId: _selectedCategoryId ?? MockupSeedData.catFood,
      amount: Money(_amountCents),
      timestamp: widget.initialTransaction?.timestamp ?? DateTime.now(),
      title: title,
      subtitle: _type == TransactionType.expense ? 'Card payment' : 'Direct deposit',
      note: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      cardLastFour: cardLastFour,
      hasReceipt: _hasReceipt,
      type: _type,
      aiConfirmed: _aiSuggestedCategory != null && _selectedCategoryId == _aiSuggestedCategory,
    );

    if (widget.initialTransaction != null) {
      await repo.updateTransaction(transaction);
    } else {
      await repo.addTransaction(transaction);
    }

    if (_scannedReceipt != null) {
      final linkedReceipt = _scannedReceipt!.copyWith(transactionId: id);
      await repo.saveReceipt(linkedReceipt);
    }

    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? MockupSeedData.categories;

    final accountsAsync = ref.watch(accountsStreamProvider);
    final accounts = accountsAsync.value ?? MockupSeedData.accounts;

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.s32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Navigation Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.s12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleIconButton(
                      icon: AppIconType.close,
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    Text(
                      widget.initialTransaction != null ? 'Edit Transaction' : 'New Transaction',
                      style: text.headline.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Pressable(
                      onTap: _handleSave,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.primaryInk,
                          borderRadius: AppRadii.fullPill,
                        ),
                        child: Text(
                          'Save',
                          style: text.subheadline.copyWith(
                            color: colors.surface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s12),

              // 2. Type Switch (Expense vs Income)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: SegmentedControl<TransactionType>(
                  segments: const [TransactionType.expense, TransactionType.income],
                  selectedSegment: _type,
                  onSegmentSelected: (newType) {
                    setState(() => _type = newType);
                  },
                  labelBuilder: (type) => type == TransactionType.expense ? 'Expense' : 'Income',
                ),
              ),

              const SizedBox(height: AppSpacing.s24),

              // 3. Amount Display
              Center(
                child: Column(
                  children: [
                    Text(
                      _type == TransactionType.expense ? 'AMOUNT SPENT' : 'AMOUNT RECEIVED',
                      style: text.overline.copyWith(
                        color: colors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    AmountText(
                      amountMinor: _amountCents,
                      size: AmountTextSize.display,
                      signStyle: AmountSignStyle.signedWithColor,
                      isPositive: _type == TransactionType.income,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s20),

              // 4. Amount Keypad
              AmountKeypad(
                onDigitPressed: _handleDigit,
                onDecimalPressed: _handleDecimal,
                onBackspacePressed: _handleBackspace,
                onLongPressBackspace: () => setState(() => _amountInput = '0'),
              ),

              const SizedBox(height: AppSpacing.s24),

              // 5. Merchant / Description Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: AppTextField(
                  controller: _titleController,
                  label: 'Merchant / Description',
                  placeholder: 'e.g. Whole Foods Market, Coffee, Uber',
                  prefixIcon: AppIconType.search,
                ),
              ),

              // AI Suggestion Banner
              if (_aiSuggestedCategory != null) ...[
                const SizedBox(height: AppSpacing.s8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                  child: Pressable(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = _aiSuggestedCategory;
                        _aiSuggestedCategory = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.accentTint,
                        borderRadius: AppRadii.card,
                        border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          AppIcon(AppIconType.sparkle, size: 16, color: colors.accent),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: Text(
                              'AI Suggestion: Set category to ${_categoryNameById(categories, _aiSuggestedCategory!)}',
                              style: text.caption.copyWith(
                                color: colors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            'Apply',
                            style: text.caption.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.s16),

              // 6. Category Picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Text(
                  'Category',
                  style: text.subheadline.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat.id == _selectedCategoryId;
                    return Pressable(
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.primaryInk : colors.surface,
                          borderRadius: AppRadii.fullPill,
                          border: Border.all(
                            color: isSelected ? colors.primaryInk : colors.borderSubtle,
                            width: 1,
                          ),
                          boxShadow: isSelected ? AppShadows.card : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(
                              _categoryIcon(cat.iconKey),
                              size: 14,
                              color: isSelected ? colors.surface : colors.primaryInk,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat.name,
                              style: text.caption.copyWith(
                                color: isSelected ? colors.surface : colors.textPrimary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.s20),

              // 7. Account Picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Text(
                  'Payment Account',
                  style: text.subheadline.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Row(
                  children: [
                    for (int i = 0; i < accounts.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Pressable(
                          onTap: () => setState(() => _selectedAccountId = accounts[i].id),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.s12),
                            decoration: BoxDecoration(
                              color: accounts[i].id == _selectedAccountId ? colors.surfaceVariant : colors.surface,
                              borderRadius: AppRadii.card,
                              border: Border.all(
                                color: accounts[i].id == _selectedAccountId ? colors.accent : colors.borderSubtle,
                                width: accounts[i].id == _selectedAccountId ? 1.5 : 0.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  accounts[i].name,
                                  style: text.caption.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '•••• ${accounts[i].lastFour}',
                                  style: text.caption.copyWith(
                                    color: colors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s20),

              // 8. AI Receipt Attachment Trigger
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadii.card,
                    border: Border.all(color: colors.borderSubtle, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.accentTint,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AppIcon(
                            AppIconType.receipt,
                            size: 20,
                            color: colors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hasReceipt ? 'Receipt Attached (4 items)' : 'Attach Receipt',
                              style: text.subheadline.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _hasReceipt
                                  ? 'Verified with local OCR'
                                  : 'Scan paper receipt to auto-fill line items',
                              style: text.caption.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      AppButton(
                        label: _hasReceipt ? 'Rescan' : 'Scan',
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.compact,
                        leadingIcon: AppIconType.sparkle,
                        onPressed: _handleScanReceipt,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s20),

              // 9. Notes Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: AppTextField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  placeholder: 'Add details or tags...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryNameById(List<Category> categories, String id) {
    for (final c in categories) {
      if (c.id == id) return c.name;
    }
    return id;
  }

  AppIconType _categoryIcon(String key) {
    switch (key) {
      case 'rent':
        return AppIconType.rent;
      case 'food':
        return AppIconType.food;
      case 'transport':
        return AppIconType.transport;
      case 'shopping':
        return AppIconType.shopping;
      case 'wallet':
        return AppIconType.wallet;
      default:
        return AppIconType.sparkle;
    }
  }
}
