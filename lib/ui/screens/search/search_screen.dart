import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/seed/mockup_seed_data.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/transaction.dart';
import '../../../providers/finance_providers.dart';

/// Full-screen reactive transaction search with category and type filter chips.
///
/// Strictly 100% custom widgets, ZERO Material / Cupertino.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  String _query = '';
  String? _selectedCategoryId;
  TransactionType? _selectedType;

  final List<String> _suggestedTags = [
    'Whole Foods',
    'Uber',
    'Metropolitan',
    'TechCorp',
    'Blue Bottle',
    'Apple',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final allTransactions = transactionsAsync.value ?? MockupSeedData.transactions;

    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? MockupSeedData.categories;

    // Filter results reactively
    final filtered = allTransactions.where((t) {
      if (_selectedCategoryId != null && t.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_selectedType != null && t.type != _selectedType) {
        return false;
      }
      if (_query.isNotEmpty) {
        final titleMatch = t.title.toLowerCase().contains(_query);
        final subtitleMatch = t.subtitle.toLowerCase().contains(_query);
        final noteMatch = t.note?.toLowerCase().contains(_query) ?? false;
        final category = _findCategoryName(categories, t.categoryId).toLowerCase();
        final categoryMatch = category.contains(_query);
        return titleMatch || subtitleMatch || noteMatch || categoryMatch;
      }
      return true;
    }).toList();

    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Search Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.s12,
              ),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: AppIconType.arrowLeft,
                    semanticLabel: 'Back',
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(
                    child: AppTextField(
                      controller: _searchController,
                      placeholder: 'Search merchants, notes, categories...',
                      prefixIcon: AppIconType.search,
                      autofocus: true,
                    ),
                  ),
                  if (_query.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.s8),
                    Pressable(
                      onTap: () {
                        _searchController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: AppRadii.fullPill,
                        ),
                        child: Text(
                          'Clear',
                          style: text.caption.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 2. Filter Chips (Horizontal Carousel)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                physics: const BouncingScrollPhysics(),
                children: [
                  // All categories chip
                  _buildFilterChip(
                    label: 'All Categories',
                    isSelected: _selectedCategoryId == null,
                    onTap: () => setState(() => _selectedCategoryId = null),
                    colors: colors,
                    text: text,
                  ),
                  const SizedBox(width: AppSpacing.s8),

                  // Category chips
                  ...categories.map((cat) {
                    final isSelected = _selectedCategoryId == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.s8),
                      child: _buildFilterChip(
                        label: cat.name,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = isSelected ? null : cat.id;
                          });
                        },
                        colors: colors,
                        text: text,
                      ),
                    );
                  }),

                  const SizedBox(width: AppSpacing.s8),

                  // Type chips: Expenses vs Income
                  _buildFilterChip(
                    label: 'Expenses Only',
                    isSelected: _selectedType == TransactionType.expense,
                    onTap: () {
                      setState(() {
                        _selectedType = _selectedType == TransactionType.expense
                            ? null
                            : TransactionType.expense;
                      });
                    },
                    colors: colors,
                    text: text,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _buildFilterChip(
                    label: 'Income Only',
                    isSelected: _selectedType == TransactionType.income,
                    onTap: () {
                      setState(() {
                        _selectedType = _selectedType == TransactionType.income
                            ? null
                            : TransactionType.income;
                      });
                    },
                    colors: colors,
                    text: text,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s12),

            // 3. Search Results or Suggestions
            Expanded(
              child: _query.isEmpty && _selectedCategoryId == null && _selectedType == null
                  ? _buildEmptyQuerySuggestions(colors, text)
                  : _buildResultsList(filtered, colors, text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyQuerySuggestions(AppColors colors, AppTypography text) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUGGESTED SEARCHES',
            style: text.overline.copyWith(
              color: colors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: _suggestedTags.map((tag) {
              return Pressable(
                onTap: () {
                  _searchController.text = tag;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: tag.length),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadii.fullPill,
                    border: Border.all(color: colors.borderSubtle, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        AppIconType.search,
                        size: 14,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tag,
                        style: text.caption.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.s32),
          Center(
            child: Column(
              children: [
                AppIcon(
                  AppIconType.search,
                  size: 48,
                  color: colors.textTertiary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  'Search across transactions, categories & notes',
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<Transaction> transactions, AppColors colors, AppTypography text) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                AppIconType.receipt,
                size: 44,
                color: colors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'No matching transactions found',
                style: text.headline.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try searching with a different merchant name or clear filters',
                style: text.caption.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.s8,
      ),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final txn = transactions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s8),
          child: TransactionTile(
            transaction: txn,
            onTap: () => context.push('/transaction/${txn.id}'),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required AppColors colors,
    required AppTypography text,
  }) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.durationFast,
        curve: AppMotion.springGentle,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryInk : colors.surface,
          borderRadius: AppRadii.fullPill,
          border: Border.all(
            color: isSelected ? colors.primaryInk : colors.borderSubtle,
            width: 1,
          ),
          boxShadow: isSelected ? AppShadows.card : null,
        ),
        child: Center(
          child: Text(
            label,
            style: text.caption.copyWith(
              color: isSelected ? colors.surface : colors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _findCategoryName(List<Category> categories, String id) {
    for (final c in categories) {
      if (c.id == id) return c.name;
    }
    return id;
  }
}
