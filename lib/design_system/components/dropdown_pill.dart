import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Item for [DropdownPill].
class DropdownItem<T> {
  final T value;
  final String label;
  final AppIconType? icon;

  const DropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// A compact dropdown pill button with anchored popover overlay.
///
/// Features:
/// - Pill shape with label and chevron-down
/// - Anchored menu using [LayerLink] and [OverlayEntry]
/// - Tap-outside dismissal via invisible scrim
/// - 100% zero Material/Cupertino
class DropdownPill<T> extends StatefulWidget {
  final T selectedValue;
  final List<DropdownItem<T>> items;
  final ValueChanged<T> onSelected;
  final String? placeholder;

  const DropdownPill({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
    this.placeholder,
  });

  @override
  State<DropdownPill<T>> createState() => _DropdownPillState<T>();
}

class _DropdownPillState<T> extends State<DropdownPill<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Outside tap dismiss area
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
              ),
            ),

            // Anchored popover card
            Positioned(
              width: 180,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadii.card,
                    border: Border.all(
                      color: colors.borderSubtle,
                      width: 0.5,
                    ),
                    boxShadow: AppShadows.cardHover,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.items.map((item) {
                      final isSelected = item.value == widget.selectedValue;
                      return Pressable(
                        onTap: () {
                          widget.onSelected(item.value);
                          _removeOverlay();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          color: isSelected
                              ? colors.surfaceVariant
                              : const Color(0x00000000),
                          child: Row(
                            children: [
                              if (item.icon != null) ...[
                                AppIcon(
                                  item.icon!,
                                  size: 16,
                                  color: isSelected
                                      ? colors.primaryInk
                                      : colors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: text.subheadline.copyWith(
                                    color: isSelected
                                        ? colors.primaryInk
                                        : colors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.primaryInk,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = context.text;

    final currentItem = widget.items.firstWhere(
      (item) => item.value == widget.selectedValue,
      orElse: () => widget.items.first,
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: Pressable(
        onTap: _toggleDropdown,
        hapticType: AppHapticType.selection,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.fullPill,
            border: Border.all(
              color: _isOpen ? colors.primaryInk : colors.borderSubtle,
              width: 0.5,
            ),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentItem.label,
                style: text.subheadline.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              AppIcon(
                _isOpen ? AppIconType.chevronUp : AppIconType.chevronDown,
                size: 14,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
