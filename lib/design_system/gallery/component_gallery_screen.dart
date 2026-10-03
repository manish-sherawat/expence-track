import 'package:flutter/widgets.dart';
import '../components/components.dart';
import '../tokens/tokens.dart';

/// Interactive Component Gallery for developing, testing, and reviewing
/// all custom design system primitives with zero Material/Cupertino dependencies.
class ComponentGalleryScreen extends StatefulWidget {
  const ComponentGalleryScreen({super.key});

  @override
  State<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends State<ComponentGalleryScreen> {
  bool _isDark = false;
  bool _reduceTransparency = false;
  bool _reduceMotion = false;
  bool _buttonLoading = false;
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    final themeData = _isDark
        ? AppThemeData.dark(
            reduceTransparency: _reduceTransparency,
            reduceMotion: _reduceMotion,
          )
        : AppThemeData.light(
            reduceTransparency: _reduceTransparency,
            reduceMotion: _reduceMotion,
          );

    return AppTheme(
      data: themeData,
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final text = context.text;

          return AppScaffold(
            backgroundColor: colors.screenBase,
            topBar: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.s12,
              ),
              decoration: BoxDecoration(
                color: colors.bg,
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('DESIGN SYSTEM', style: text.overline),
                      const SizedBox(height: AppSpacing.s2),
                      Text('Component Gallery', style: text.screenTitle),
                    ],
                  ),
                  Row(
                    children: [
                      // Quick theme toggles
                      TagChip(
                        label: _isDark ? '🌙 Dark' : '☀️ Light',
                        variant: TagChipVariant.neutral,
                        onTap: () => setState(() => _isDark = !_isDark),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      TagChip(
                        label: _reduceTransparency ? 'Solid' : 'Glass',
                        variant: _reduceTransparency
                            ? TagChipVariant.warning
                            : TagChipVariant.info,
                        onTap: () => setState(
                            () => _reduceTransparency = !_reduceTransparency),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      TagChip(
                        label: _reduceMotion ? 'No Motion' : 'Motion',
                        variant: _reduceMotion
                            ? TagChipVariant.warning
                            : TagChipVariant.neutral,
                        onTap: () => setState(() => _reduceMotion = !_reduceMotion),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              children: [
                _buildSection(
                  title: '1. AmountText (Tabular Figures & Currency)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Display Tier (44pt / 28pt cents):', style: text.label),
                      const SizedBox(height: AppSpacing.s4),
                      const AmountText(amountMinor: 1289290), // $12,892.90
                      const SizedBox(height: AppSpacing.s12),

                      Text('Signed Colored Variants:', style: text.label),
                      const SizedBox(height: AppSpacing.s4),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Income (+):', style: text.caption),
                                const AmountText(
                                  amountMinor: 842900,
                                  size: AmountTextSize.stat,
                                  signStyle: AmountSignStyle.signedWithColor,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Expenses (-):', style: text.caption),
                                const AmountText(
                                  amountMinor: -321800,
                                  size: AmountTextSize.stat,
                                  signStyle: AmountSignStyle.signedWithColor,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Row Tier:', style: text.caption),
                                const AmountText(
                                  amountMinor: -6784, // -$67.84
                                  size: AmountTextSize.row,
                                  signStyle: AmountSignStyle.negativeColorOnly,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '2. GlassSurface (Frosted Glass & Fallback)',
                  child: Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      borderRadius: AppRadii.card,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFF26A1B),
                          Color(0xFF0B8FE0),
                          Color(0xFF12A038),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    alignment: Alignment.center,
                    child: GlassSurface(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      borderRadius: AppRadii.innerBalanceCard,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'FROSTED GLASS CONTAINER',
                                style: text.overline.copyWith(color: colors.textPrimary),
                              ),
                              const SizedBox(height: AppSpacing.s4),
                              Text(
                                _reduceTransparency
                                    ? 'Reduced Transparency (Solid)'
                                    : 'Sigma 20px Blur + 55% Tint',
                                style: text.label.copyWith(color: colors.textPrimary),
                              ),
                            ],
                          ),
                          TagChip.ai(label: '✦ Glass'),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '3. Pressable (Scale & Opacity Feedback)',
                  child: Row(
                    children: [
                      Expanded(
                        child: Pressable(
                          onPressed: () => setState(() => _counter++),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.s16),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: AppRadii.card,
                              border: Border.all(color: colors.border),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text('Tap to Test Scale 0.97', style: text.body),
                                const SizedBox(height: AppSpacing.s4),
                                Text('Tapped: $_counter times', style: text.caption),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Pressable(
                          enabled: false,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.s16),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: AppRadii.card,
                              border: Border.all(color: colors.border),
                            ),
                            alignment: Alignment.center,
                            child: Text('Disabled State', style: text.body),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '4. CircleIconButton (44pt Targets)',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircleIconButton(
                        icon: AppIconType.search,
                        semanticLabel: 'Search',
                        onPressed: () {},
                      ),
                      CircleIconButton(
                        icon: AppIconType.bell,
                        hasBadge: true,
                        semanticLabel: 'Notifications',
                        onPressed: () {},
                      ),
                      CircleIconButton(
                        icon: AppIconType.arrowLeft,
                        semanticLabel: 'Back',
                        onPressed: () {},
                      ),
                      CircleIconButton(
                        icon: AppIconType.moreDots,
                        semanticLabel: 'More Options',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '5. Chips & Status Pills',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: [
                          const TagChip(label: 'Groceries'),
                          TagChip.ai(label: '✦ Food'),
                          TagChip.ai(label: '✦ Shopping'),
                          const TagChip(label: 'Warning', variant: TagChipVariant.warning),
                          const TagChip(label: 'Saved', variant: TagChipVariant.positive),
                          StatusPill.over(),
                          StatusPill.under(),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '6. AppButton (Variants & States)',
                  child: Column(
                    children: [
                      AppButton(
                        label: 'Primary Action (Ink)',
                        isFullWidth: true,
                        onPressed: () {},
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Secondary',
                              variant: AppButtonVariant.secondary,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: AppButton(
                              label: 'Destructive',
                              variant: AppButtonVariant.destructive,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: _buttonLoading ? 'Loading...' : 'Toggle Loading',
                              variant: AppButtonVariant.secondary,
                              isLoading: _buttonLoading,
                              onPressed: () {
                                setState(() => _buttonLoading = !_buttonLoading);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          const Expanded(
                            child: AppButton(
                              label: 'Disabled',
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '7. Vector Icon Catalog (100% Custom)',
                  child: Wrap(
                    spacing: AppSpacing.s16,
                    runSpacing: AppSpacing.s16,
                    children: AppIconType.values.map((type) {
                      return Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: AppRadii.border12,
                          border: Border.all(color: colors.border),
                        ),
                        child: Column(
                          children: [
                            AppIcon(type, size: 24, color: colors.textPrimary),
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              type.name,
                              style: text.caption.copyWith(fontSize: 9.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: AppScaffold.bottomNavScrollPadding),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    final colors = context.colors;
    final text = context.text;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: AppRadii.card,
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.sectionTitle),
          const SizedBox(height: AppSpacing.s12),
          child,
        ],
      ),
    );
  }
}
