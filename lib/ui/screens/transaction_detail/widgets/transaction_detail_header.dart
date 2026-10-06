import 'package:flutter/widgets.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

/// Header for Transaction Detail Screen (Screen 2).
///
/// Features:
/// - Circular back button (`CircleIconButton` with `arrowLeft`)
/// - Screen title "Transaction Detail"
/// - Circular more "..." button with anchored glass popover menu
/// - 100% custom, zero Material/Cupertino
class TransactionDetailHeader extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onEdit;
  final VoidCallback? onExportPdf;
  final VoidCallback? onDelete;

  const TransactionDetailHeader({
    super.key,
    required this.onBack,
    this.onEdit,
    this.onExportPdf,
    this.onDelete,
  });

  @override
  State<TransactionDetailHeader> createState() => _TransactionDetailHeaderState();
}

class _TransactionDetailHeaderState extends State<TransactionDetailHeader> {
  final LayerLink _moreButtonLayerLink = LayerLink();
  OverlayEntry? _popoverOverlay;
  bool _isMenuOpen = false;

  @override
  void dispose() {
    _popoverOverlay?.remove();
    _popoverOverlay = null;
    super.dispose();
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _removePopover();
    } else {
      _showPopover();
    }
  }

  void _removePopover() {
    _popoverOverlay?.remove();
    _popoverOverlay = null;
    if (mounted) {
      setState(() => _isMenuOpen = false);
    }
  }

  void _showPopover() {
    final overlay = Overlay.of(context);
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    _popoverOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Outside dismissal barrier
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removePopover,
              ),
            ),

            // Anchored popover card
            Positioned(
              width: 200,
              child: CompositedTransformFollower(
                link: _moreButtonLayerLink,
                showWhenUnlinked: false,
                offset: const Offset(-156, 52),
                child: GlassSurface(
                  borderRadius: AppRadii.card,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem(
                        icon: AppIconType.sparkle,
                        label: 'Edit Transaction',
                        onTap: () {
                          _removePopover();
                          widget.onEdit?.call();
                        },
                        textStyle: text.subheadline.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        iconColor: colors.textPrimary,
                      ),
                      _buildMenuItem(
                        icon: AppIconType.receipt,
                        label: 'Export Receipt PDF',
                        onTap: () {
                          _removePopover();
                          widget.onExportPdf?.call();
                        },
                        textStyle: text.subheadline.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        iconColor: colors.textPrimary,
                      ),
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: colors.borderSubtle,
                      ),
                      _buildMenuItem(
                        icon: AppIconType.close,
                        label: 'Delete Transaction',
                        onTap: () {
                          _removePopover();
                          widget.onDelete?.call();
                        },
                        textStyle: text.subheadline.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                        iconColor: colors.accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_popoverOverlay!);
    setState(() => _isMenuOpen = true);
  }

  Widget _buildMenuItem({
    required AppIconType icon,
    required String label,
    required VoidCallback onTap,
    required TextStyle textStyle,
    required Color iconColor,
  }) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            AppIcon(icon, size: 16, color: iconColor),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: Text(
                label,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final text = theme.text;
    final colors = theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Back Button
          CircleIconButton(
            icon: AppIconType.arrowLeft,
            semanticLabel: 'Go Back',
            onTap: widget.onBack,
          ),

          // Title
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
              child: Center(
                child: Text(
                  'Transaction Detail',
                  style: text.headline.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          // Circular More "..." Button with LayerLink
          CompositedTransformTarget(
            link: _moreButtonLayerLink,
            child: CircleIconButton(
              icon: AppIconType.moreDots,
              semanticLabel: 'More Options',
              onTap: _toggleMenu,
            ),
          ),
        ],
      ),
    );
  }
}
