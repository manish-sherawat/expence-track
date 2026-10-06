import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Custom text input built strictly on [EditableText].
///
/// Strictly ZERO Material / ZERO Cupertino imports.
/// Features:
/// - Custom border and animated focus ring
/// - Placeholder hint text
/// - Optional prefix and suffix icons
/// - Error state with message
/// - Clean tap-to-focus and clear button
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final String? label;
  final String? errorText;
  final AppIconType? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool readOnly;

  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.label,
    this.errorText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.readOnly = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isInternalController = false;
  bool _isInternalFocusNode = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isInternalController = true;
    } else {
      _controller = widget.controller!;
    }

    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }

    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_isInternalController) _controller.dispose();
    if (_isInternalFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = context.text;

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = hasError
        ? colors.accent
        : _hasFocus
            ? colors.primaryInk
            : colors.borderSubtle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: text.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
        ],

        // Input Box
        GestureDetector(
          onTap: () {
            if (!widget.readOnly) {
              _focusNode.requestFocus();
            }
          },
          child: AnimatedContainer(
            duration: AppMotion.durationFast,
            curve: AppMotion.springGentle,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadii.card,
              border: Border.all(
                color: borderColor,
                width: _hasFocus ? 1.5 : 1.0,
              ),
              boxShadow: _hasFocus
                  ? [
                      BoxShadow(
                        color: colors.primaryInk.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  AppIcon(
                    widget.prefixIcon!,
                    size: 18,
                    color: _hasFocus ? colors.primaryInk : colors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.s10),
                ],

                Expanded(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Hint / Placeholder
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (context, value, child) {
                          if (value.text.isEmpty && widget.placeholder != null) {
                            return Text(
                              widget.placeholder!,
                              style: text.bodyMedium.copyWith(
                                color: colors.textTertiary,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // EditableText
                      EditableText(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: text.bodyMedium.copyWith(
                          color: colors.textPrimary,
                        ),
                        cursorColor: colors.primaryInk,
                        backgroundCursorColor: colors.surfaceVariant,
                        obscureText: widget.obscureText,
                        keyboardType: widget.keyboardType,
                        textInputAction: widget.textInputAction,
                        onChanged: widget.onChanged,
                        onSubmitted: widget.onSubmitted,
                        autofocus: widget.autofocus,
                        readOnly: widget.readOnly,
                        selectionColor: colors.primaryInk.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ),

                // Clear button
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    if (value.text.isNotEmpty && !widget.readOnly) {
                      return Pressable(
                        onTap: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.surfaceVariant,
                          ),
                          child: AppIcon(
                            AppIconType.close,
                            size: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),

        // Error message
        if (hasError) ...[
          const SizedBox(height: AppSpacing.s4),
          Text(
            widget.errorText!,
            style: text.caption.copyWith(
              color: colors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
