import 'package:flutter/widgets.dart';

import '../../domain/models/transaction.dart';
import '../tokens/tokens.dart';
import 'amount_text.dart';
import 'app_icon.dart';
import 'pressable.dart';
import 'tag_chip.dart';

/// Swipe action button definition for [TransactionTile].
class TransactionSwipeAction {
  final AppIconType icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const TransactionSwipeAction({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });
}

/// A premium zero-Material transaction tile.
///
/// Features:
/// - 44pt circular icon avatar
/// - Title and subtitle with strict typography
/// - Optional AI chip (e.g. '✦ Split', '✦ Recurring')
/// - Signed currency display with tabular figures
/// - Horizontal swipe gesture to reveal contextual actions
class TransactionTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final int amountCents;
  final bool isIncome;
  final AppIconType icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String? aiChipLabel;
  final String? timeString;
  final VoidCallback? onTap;
  final List<TransactionSwipeAction>? actions;
  final Transaction? transaction;

  const TransactionTile({
    super.key,
    this.title = '',
    this.subtitle = '',
    this.amountCents = 0,
    this.isIncome = false,
    this.icon = AppIconType.shopping,
    this.iconColor,
    this.iconBackgroundColor,
    this.aiChipLabel,
    this.timeString,
    this.onTap,
    this.actions,
    this.transaction,
  });

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _swipeController;
  double _dragExtent = 0.0;
  bool _isOpened = false;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: AppMotion.durationNormal,
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.actions == null || widget.actions!.isEmpty) return;
    setState(() {
      _dragExtent = (_dragExtent + details.primaryDelta!).clamp(-140.0, 0.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.actions == null || widget.actions!.isEmpty) return;
    if (_dragExtent < -50) {
      _openSwipe();
    } else {
      _closeSwipe();
    }
  }

  void _openSwipe() {
    setState(() {
      _dragExtent = -140.0;
      _isOpened = true;
    });
  }

  void _closeSwipe() {
    setState(() {
      _dragExtent = 0.0;
      _isOpened = false;
    });
  }

  AppIconType _categoryIcon(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'food':
      case 'dining':
      case 'groceries':
        return AppIconType.food;
      case 'rent':
      case 'housing':
        return AppIconType.rent;
      case 'transport':
      case 'transit':
        return AppIconType.transport;
      case 'shopping':
        return AppIconType.shopping;
      case 'income':
      case 'salary':
        return AppIconType.wallet;
      default:
        return AppIconType.shopping;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    final t = widget.transaction;
    final title = t != null ? t.title : widget.title;
    final subtitle = t != null ? t.subtitle : widget.subtitle;
    final amountCents = t != null ? t.amount.cents : widget.amountCents;
    final isIncome = t != null ? t.isIncome : widget.isIncome;
    final aiChipLabel = t != null ? t.aiSuggestedCategory : widget.aiChipLabel;
    final icon = (widget.icon == AppIconType.shopping && t != null)
        ? _categoryIcon(t.categoryId)
        : widget.icon;

    final avatarBg = widget.iconBackgroundColor ?? colors.surfaceVariant;
    final avatarFg = widget.iconColor ?? colors.primaryInk;

    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      color: colors.surface,
      child: Row(
        children: [
          // 44pt circular icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
            child: Center(
              child: AppIcon(icon, size: 20, color: avatarFg),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),

          // Title & Subtitle + AI Chip
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: text.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (aiChipLabel != null) ...[
                      const SizedBox(width: AppSpacing.s6),
                      TagChip(
                        label: aiChipLabel,
                        variant: TagChipVariant.ai,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),

          // Amount + Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: AmountText(
                  amountMinor: isIncome ? amountCents : -amountCents,
                  size: AmountTextSize.row,
                  signStyle: isIncome
                      ? AmountSignStyle.signedWithColor
                      : AmountSignStyle.negativeColorOnly,
                ),
              ),
              if (widget.timeString != null) ...[
                const SizedBox(height: 3),
                Text(
                  widget.timeString!,
                  style: text.caption.copyWith(
                    color: colors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (widget.actions == null || widget.actions!.isEmpty) {
      return Pressable(onTap: widget.onTap, child: content);
    }

    // Swipeable container
    return ClipRRect(
      child: Stack(
        children: [
          // Background action buttons
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: widget.actions!.map((action) {
                return GestureDetector(
                  onTap: () {
                    _closeSwipe();
                    action.onTap();
                  },
                  child: Container(
                    width: 70,
                    color: action.backgroundColor,
                    child: Center(
                      child: AppIcon(
                        action.icon,
                        size: 20,
                        color: action.foregroundColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Foreground sliding tile
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: AnimatedContainer(
              duration: _isOpened ? AppMotion.durationFast : Duration.zero,
              curve: AppMotion.springGentle,
              transform: Matrix4.translationValues(_dragExtent, 0, 0),
              child: Pressable(
                onTap: () {
                  if (_isOpened) {
                    _closeSwipe();
                  } else {
                    widget.onTap?.call();
                  }
                },
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
