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
  int _navIndex = 0;
  String _selectedSegment = 'Month';
  String _selectedMonth = 'Apr 2026';
  bool _toggleVal = true;
  bool _checkboxVal = true;
  int _radioVal = 1;
  String _keypadInput = '245.50';

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
            floatingBottomBar: FrostedNavBar(
              selectedIndex: _navIndex,
              onItemSelected: (idx) => setState(() => _navIndex = idx),
              onCenterAction: () => showAppToast(
                context,
                message: '✦ Quick Add Action Tapped!',
                icon: AppIconType.plus,
              ),
              leftItems: const [
                FrostedNavBarItem(icon: AppIconType.wallet, label: 'Wallet'),
                FrostedNavBarItem(icon: AppIconType.chart, label: 'Analytics'),
              ],
              rightItems: const [
                FrostedNavBarItem(icon: AppIconType.bell, label: 'Alerts'),
                FrostedNavBarItem(icon: AppIconType.user, label: 'Profile'),
              ],
            ),
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

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '8. SegmentedControl & DropdownPill',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SegmentedControl<String>(
                        segments: const ['Week', 'Month', 'Year'],
                        selectedSegment: _selectedSegment,
                        onSegmentSelected: (seg) => setState(() => _selectedSegment = seg),
                        labelBuilder: (seg) => seg,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          Text('Select Period:', style: text.label),
                          const SizedBox(width: AppSpacing.s12),
                          DropdownPill<String>(
                            selectedValue: _selectedMonth,
                            items: const [
                              DropdownItem(value: 'Mar 2026', label: 'March 2026'),
                              DropdownItem(value: 'Apr 2026', label: 'April 2026'),
                              DropdownItem(value: 'May 2026', label: 'May 2026'),
                            ],
                            onSelected: (val) => setState(() => _selectedMonth = val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '9. StatCards & Animated ProgressBar',
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Total Spent',
                              amountCents: 321800,
                              trendPercentage: -4.2,
                              isPositiveGood: false,
                              trendContext: 'vs last month',
                              icon: AppIconType.shopping,
                            ),
                          ),
                          SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: StatCard(
                              title: 'Daily Average',
                              amountCents: 10726,
                              trendPercentage: 2.1,
                              isPositiveGood: true,
                              trendContext: '30 days',
                              icon: AppIconType.chart,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Budget Used (68%)', style: text.caption),
                              Text(r'$2,190.00 / $3,218.00', style: text.caption),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s6),
                          const ProgressBar(progress: 0.68, height: 6),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '10. AreaLineChart (Spline + Gradient + Scrub)',
                  child: const SizedBox(
                    height: 200,
                    child: AreaLineChart(
                      data: [
                        ChartDataPoint(label: 'Apr 1', valueCents: 12000),
                        ChartDataPoint(label: 'Apr 5', valueCents: 24000),
                        ChartDataPoint(label: 'Apr 10', valueCents: 18000),
                        ChartDataPoint(label: 'Apr 15', valueCents: 32000),
                        ChartDataPoint(label: 'Apr 20', valueCents: 21000),
                        ChartDataPoint(label: 'Apr 25', valueCents: 29000),
                        ChartDataPoint(label: 'Apr 30', valueCents: 38000),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '11. TransactionTiles (Avatar, AI Chip, Signed)',
                  child: Column(
                    children: [
                      TransactionTile(
                        title: 'Acme Corporation',
                        subtitle: 'Bi-weekly Direct Deposit',
                        amountCents: 842900,
                        isIncome: true,
                        timeString: 'Today, 9:00 AM',
                        icon: AppIconType.wallet,
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      TransactionTile(
                        title: 'Whole Foods Market',
                        subtitle: 'Groceries & Household',
                        amountCents: 6784,
                        isIncome: false,
                        timeString: '2:45 PM',
                        aiChipLabel: '✦ Food',
                        icon: AppIconType.food,
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      TransactionTile(
                        title: 'Sunset Apartments',
                        subtitle: 'Monthly Rent Payment',
                        amountCents: 120000,
                        isIncome: false,
                        timeString: 'Yesterday',
                        aiChipLabel: '✦ Rent',
                        icon: AppIconType.rent,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '12. Category Cards & Insight Banner',
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            CategoryCard(
                              title: 'Food & Dining',
                              amountCents: 124000,
                              percentage: 38.5,
                              icon: AppIconType.food,
                              onTap: () {},
                            ),
                            const SizedBox(width: AppSpacing.s10),
                            CategoryCard(
                              title: 'Rent & Utils',
                              amountCents: 120000,
                              percentage: 37.0,
                              icon: AppIconType.rent,
                              onTap: () {},
                            ),
                            const SizedBox(width: AppSpacing.s10),
                            CategoryCard(
                              title: 'Shopping',
                              amountCents: 45000,
                              percentage: 14.0,
                              icon: AppIconType.shopping,
                              onTap: () {},
                            ),
                            const SizedBox(width: AppSpacing.s10),
                            CategoryCard(
                              title: 'Transport',
                              amountCents: 32800,
                              percentage: 10.5,
                              icon: AppIconType.transport,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      InsightBanner(
                        headline: 'AI Smart Insight',
                        subheadline: 'You spent 12% less on dining this week compared to your 30-day average.',
                        onTap: () => showAppToast(
                          context,
                          message: '✦ Tapped Insight Banner!',
                          icon: AppIconType.sparkle,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '13. Receipt Card & Receipt Thumbnail',
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ReceiptThumb(
                            onTap: () => showAppToast(
                              context,
                              message: 'Receipt Thumbnail Tapped!',
                              icon: AppIconType.receipt,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('AI Scanned Receipt', style: text.rowTitle),
                                const SizedBox(height: 4),
                                Text(
                                  'Rotated paper thumb with dashed perforation line and zoom preview.',
                                  style: text.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      const ReceiptCard(
                        merchantName: 'Whole Foods Market',
                        dateString: 'April 14, 2026 • 2:45 PM',
                        items: [
                          ReceiptLineItem(name: 'Organic Oat Milk', quantity: 2, priceCents: 998),
                          ReceiptLineItem(name: 'Avocados (Hass)', quantity: 4, priceCents: 600),
                          ReceiptLineItem(name: 'Greek Yogurt 32oz', quantity: 1, priceCents: 749),
                          ReceiptLineItem(name: 'Artisan Sourdough', quantity: 1, priceCents: 699),
                        ],
                        subtotalCents: 3046,
                        taxCents: 245,
                        totalCents: 3291,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '14. Merchant Card with Mini History',
                  child: const MerchantCard(
                    name: 'Whole Foods Market',
                    category: 'Groceries & Organic Food',
                    totalSpentCents: 48920,
                    visitCount: 8,
                    icon: AppIconType.food,
                    recentTransactions: [
                      MiniTxnCard(dateString: 'Apr 14', title: 'Organic Grocery', amountCents: 3291),
                      MiniTxnCard(dateString: 'Apr 08', title: 'Weekly Groceries', amountCents: 6784),
                      MiniTxnCard(dateString: 'Apr 02', title: 'Produce & Snacks', amountCents: 2450),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '15. AppTextField & AmountKeypad',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppTextField(
                        label: 'Transaction Description',
                        placeholder: 'e.g. Dinner with Friends...',
                        prefixIcon: AppIconType.search,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Keypad Input:', style: text.label),
                          Text(
                            r'$' + (_keypadInput.isEmpty ? '0.00' : _keypadInput),
                            style: text.title2.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      AmountKeypad(
                        onDigitPressed: (digit) => setState(() => _keypadInput += digit),
                        onDecimalPressed: () => setState(() => _keypadInput += '.'),
                        onBackspacePressed: () => setState(() {
                          if (_keypadInput.isNotEmpty) {
                            _keypadInput = _keypadInput.substring(0, _keypadInput.length - 1);
                          }
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '16. Custom Selection Controls',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          AppToggle(
                            value: _toggleVal,
                            onChanged: (val) => setState(() => _toggleVal = val),
                          ),
                          const SizedBox(height: 6),
                          Text('Toggle', style: text.caption),
                        ],
                      ),
                      Column(
                        children: [
                          AppCheckbox(
                            value: _checkboxVal,
                            onChanged: (val) => setState(() => _checkboxVal = val),
                          ),
                          const SizedBox(height: 6),
                          Text('Checkbox', style: text.caption),
                        ],
                      ),
                      Column(
                        children: [
                          AppRadio<int>(
                            value: 1,
                            groupValue: _radioVal,
                            onChanged: (val) => setState(() => _radioVal = val),
                          ),
                          const SizedBox(height: 6),
                          Text('Radio', style: text.caption),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                _buildSection(
                  title: '17. Shimmer Skeleton & Loading Spinner',
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppLoadingSpinner(size: 28),
                          SizedBox(width: AppSpacing.s16),
                          Skeleton.circle(size: 44),
                          SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Skeleton(width: 140, height: 16),
                                SizedBox(height: 6),
                                Skeleton(width: double.infinity, height: 12),
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
                  title: '18. Overlays (AppBottomSheet & AppToast)',
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Trigger Toast',
                          variant: AppButtonVariant.secondary,
                          onPressed: () => showAppToast(
                            context,
                            message: '✦ Notification successfully dispatched!',
                            icon: AppIconType.sparkle,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: AppButton(
                          label: 'Bottom Sheet',
                          onPressed: () => showAppBottomSheet<void>(
                            context: context,
                            builder: (ctx) => Padding(
                              padding: const EdgeInsets.all(AppSpacing.s24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Zero-Material Bottom Sheet', style: text.sectionTitle),
                                  const SizedBox(height: AppSpacing.s8),
                                  Text(
                                    'Smooth velocity-aware drag dismissal with hairline handle and backdrop blur.',
                                    style: text.body,
                                  ),
                                  const SizedBox(height: AppSpacing.s20),
                                  AppButton(
                                    label: 'Dismiss Sheet',
                                    isFullWidth: true,
                                    onPressed: () => Navigator.of(ctx).pop(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
