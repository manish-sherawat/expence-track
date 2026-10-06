import 'package:flutter/widgets.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../domain/models/category.dart';

class CategorySpendingItem {
  const CategorySpendingItem({
    required this.category,
    required this.amountCents,
    required this.percentage,
    required this.icon,
  });

  final Category category;
  final int amountCents;
  final double percentage;
  final AppIconType icon;
}

class CategorySpendingCarousel extends StatelessWidget {
  const CategorySpendingCarousel({
    super.key,
    required this.items,
    this.onSeeAllTap,
    this.onCategoryTap,
  });

  final List<CategorySpendingItem> items;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<Category>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Spending by Category',
                  style: text.headline.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              if (onSeeAllTap != null)
                Pressable(
                  onPressed: onSeeAllTap,
                  child: Text(
                    'See all',
                    style: text.caption.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s12),

        // Horizontal Carousel
        SizedBox(
          height: (MediaQuery.maybeTextScalerOf(context)?.scale(160.0) ?? 160.0).clamp(156.0, 230.0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.s12),
            itemBuilder: (context, index) {
              final item = items[index];
              return CategoryCard(
                title: item.category.name,
                amountCents: item.amountCents,
                percentage: item.percentage,
                icon: item.icon,
                onTap: onCategoryTap != null ? () => onCategoryTap!(item.category) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
