import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/seed/mockup_seed_data.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../domain/models/models.dart';
import '../../../providers/finance_providers.dart';

/// User Profile and Salary Configuration screen (Tab 3).
///
/// Features:
/// - User details with avatar and membership tier
/// - Salary configuration card ($8,429 net salary, gross, taxes, payday)
/// - Savings target progress tracker
/// - App preferences with custom AppToggle switches
/// - Mockup data reset and CSV export actions
/// - 100% custom components, ZERO Material / Cupertino
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _aiCategorizationEnabled = true;
  bool _receiptOcrEnabled = true;
  bool _biometricLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final repo = ref.read(financeRepositoryProvider);
    final aiCat = await repo.getAppSetting('pref_ai_categorization', defaultValue: 'true');
    final rcptOcr = await repo.getAppSetting('pref_receipt_ocr', defaultValue: 'true');
    final bioLock = await repo.getAppSetting('pref_biometric_lock', defaultValue: 'false');
    if (mounted) {
      setState(() {
        _aiCategorizationEnabled = aiCat == 'true';
        _receiptOcrEnabled = rcptOcr == 'true';
        _biometricLockEnabled = bioLock == 'true';
      });
    }
  }

  Future<void> _updatePreference(String key, bool value) async {
    final repo = ref.read(financeRepositoryProvider);
    await repo.setAppSetting(key, value.toString());
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  void _handleEditName(String currentName) {
    final controller = TextEditingController(text: currentName);
    AppBottomSheet.show<void>(
      context: context,
      title: 'Edit Display Name',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Update your display name across your financial reports and greeting cards.',
              style: context.text.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            AppTextField(
              controller: controller,
              label: 'Full Name',
              placeholder: 'e.g. Jacob Simmons',
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.s20),
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
                    label: 'Save',
                    variant: AppButtonVariant.primary,
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      Navigator.of(context).pop();
                      final repo = ref.read(financeRepositoryProvider);
                      await repo.setAppSetting('user_name', text);
                      ref.invalidate(userNameProvider);
                      if (mounted) {
                        AppToast.show(
                          context,
                          'Profile name updated',
                          type: AppToastType.success,
                        );
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
  }

  void _handleEditSalary(SalaryProfile currentSalary) {
    final employerCtrl = TextEditingController(text: currentSalary.employerName);
    final netCtrl = TextEditingController(
      text: (currentSalary.monthlyNet.cents / 100).toStringAsFixed(0),
    );
    final dayCtrl = TextEditingController(text: currentSalary.payDayOfMonth.toString());

    AppBottomSheet.show<void>(
      context: context,
      title: 'Configure Monthly Income',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: employerCtrl,
              label: 'Employer / Income Source',
              placeholder: 'e.g. TechCorp Inc.',
            ),
            const SizedBox(height: AppSpacing.s12),
            AppTextField(
              controller: netCtrl,
              label: 'Monthly Net Income (\$)',
              placeholder: '8429',
            ),
            const SizedBox(height: AppSpacing.s12),
            AppTextField(
              controller: dayCtrl,
              label: 'Pay Day of Month (1-31)',
              placeholder: '15',
            ),
            const SizedBox(height: AppSpacing.s20),
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
                    label: 'Save',
                    variant: AppButtonVariant.primary,
                    onPressed: () async {
                      final emp = employerCtrl.text.trim();
                      final netParsed = double.tryParse(netCtrl.text.trim()) ?? 0.0;
                      final dayParsed = int.tryParse(dayCtrl.text.trim()) ?? 15;
                      final updated = currentSalary.copyWith(
                        employerName: emp.isNotEmpty ? emp : currentSalary.employerName,
                        monthlyNet: Money((netParsed * 100).round()),
                        payDayOfMonth: dayParsed.clamp(1, 31),
                      );
                      Navigator.of(context).pop();
                      final repo = ref.read(financeRepositoryProvider);
                      await repo.updateSalaryProfile(updated);
                      if (mounted) {
                        AppToast.show(
                          context,
                          'Salary baseline updated',
                          type: AppToastType.success,
                        );
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
  }

  void _handleResetSeedData() {
    AppBottomSheet.show<void>(
      context: context,
      title: 'Reset to Mockup Data',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This will reset all accounts, categories, and transactions to the exact mockup values (\$12,892.90 balance, \$8,429.00 income).',
              style: context.text.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
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
                    label: 'Reset Now',
                    variant: AppButtonVariant.destructive,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final repo = ref.read(financeRepositoryProvider);
                      await repo.seedMockupData();
                      if (mounted) {
                        AppToast.show(
                          context,
                          'Mockup data restored successfully',
                          type: AppToastType.success,
                        );
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
  }

  Future<void> _handleExportAllCsv() async {
    final repo = ref.read(financeRepositoryProvider);
    final csv = await repo.exportDatabaseToCsv();
    final lineCount = csv.split('\n').where((l) => l.trim().isNotEmpty).length;

    if (!mounted) return;
    await AppBottomSheet.show<void>(
      context: context,
      title: 'Database CSV Export',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$lineCount records formatted into standard CSV. Ready for Excel, Google Sheets, or personal backups.',
              style: context.text.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Container(
              height: 120,
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: context.colors.surfaceVariant,
                borderRadius: AppRadii.card,
                border: Border.all(color: context.colors.borderSubtle, width: 0.5),
              ),
              child: SingleChildScrollView(
                child: Text(
                  csv,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Close',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: AppButton(
                    label: 'Copy CSV',
                    variant: AppButtonVariant.primary,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: csv));
                      if (mounted) {
                        Navigator.of(context).pop();
                        AppToast.show(
                          context,
                          'CSV copied to clipboard!',
                          type: AppToastType.success,
                        );
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    final salaryAsync = ref.watch(salaryProfileStreamProvider);
    final salary = salaryAsync.value ?? MockupSeedData.salaryProfile;
    final userName = ref.watch(userNameProvider).value ?? 'Jacob Simmons';

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header & Profile Hero
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.s20,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primaryInk,
                        border: Border.all(color: colors.borderSubtle, width: 1.5),
                        boxShadow: AppShadows.card,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(userName),
                          style: text.title1.copyWith(
                            color: colors.surface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  userName,
                                  style: text.title2.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Pressable(
                                onTap: () => _handleEditName(userName),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceVariant,
                                    borderRadius: AppRadii.fullPill,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppIcon(AppIconType.sparkle, size: 10, color: colors.primaryInk),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Edit',
                                        style: text.caption.copyWith(
                                          color: colors.primaryInk,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'jacob.simmons@email.com',
                            style: text.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s8),

              // 2. Salary Configuration Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: GlassSurface(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  borderRadius: AppRadii.cardLarge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: colors.positiveTint,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: AppIcon(
                                      AppIconType.wallet,
                                      size: 18,
                                      color: colors.positive,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'MONTHLY INCOME',
                                        style: text.overline.copyWith(
                                          color: colors.textSecondary,
                                          letterSpacing: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        salary.employerName,
                                        style: text.subheadline.copyWith(
                                          color: colors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.surfaceVariant,
                                  borderRadius: AppRadii.fullPill,
                                ),
                                child: Text(
                                  'Day ${salary.payDayOfMonth}',
                                  style: text.caption.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Pressable(
                                onTap: () => _handleEditSalary(salary),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colors.primaryInk,
                                    borderRadius: AppRadii.fullPill,
                                  ),
                                  child: Text(
                                    'Edit',
                                    style: text.caption.copyWith(
                                      color: colors.surface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),

                      // Net Salary Display
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AmountText(
                          amountMinor: salary.monthlyNet.cents,
                          size: AmountTextSize.title,
                          isPositive: true,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Net monthly income baseline for expense budget tracking',
                        style: text.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s16),
                      Container(height: 0.5, color: colors.borderSubtle),
                      const SizedBox(height: AppSpacing.s12),

                      // Breakdown rows
                      _buildSalaryRow(
                        'Gross Income',
                        salary.monthlyGross.format(),
                        colors.textPrimary,
                        text,
                      ),
                      const SizedBox(height: 6),
                      _buildSalaryRow(
                        'Federal & State Tax',
                        '-${salary.taxWithheld.format()}',
                        colors.textSecondary,
                        text,
                      ),
                      const SizedBox(height: 6),
                      _buildSalaryRow(
                        'Pre-tax Deductions & 401(k)',
                        '-${salary.deductions.format()}',
                        colors.textSecondary,
                        text,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s16),

              // 3. Savings Target Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: GlassSurface(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  borderRadius: AppRadii.cardLarge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'MONTHLY SAVINGS TARGET',
                              style: text.overline.copyWith(
                                color: colors.textSecondary,
                                letterSpacing: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          const StatusPill(
                            label: 'On Track',
                            isPositive: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                salary.savingsGoalMonthly.format(),
                                style: text.title2.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Text(
                            '100% of goal',
                            style: text.caption.copyWith(
                              color: colors.positive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      const ProgressBar(
                        progress: 1.0,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        'Automatically transferred to High Yield Savings (4.25% APY)',
                        style: text.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s20),

              // 4. App Preferences Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Text(
                  'PREFERENCES & AI',
                  style: text.overline.copyWith(
                    color: colors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadii.cardLarge,
                    border: Border.all(color: colors.borderSubtle, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      _buildToggleRow(
                        icon: AppIconType.sparkle,
                        title: 'AI Auto-Categorization',
                        subtitle: 'Predict merchant categories instantly',
                        value: _aiCategorizationEnabled,
                        onChanged: (v) {
                          setState(() => _aiCategorizationEnabled = v);
                          _updatePreference('pref_ai_categorization', v);
                        },
                        colors: colors,
                        text: text,
                      ),
                      Container(height: 0.5, color: colors.borderSubtle),
                      _buildToggleRow(
                        icon: AppIconType.receipt,
                        title: 'Paper Receipt OCR',
                        subtitle: 'Local on-device receipt item extraction',
                        value: _receiptOcrEnabled,
                        onChanged: (v) {
                          setState(() => _receiptOcrEnabled = v);
                          _updatePreference('pref_receipt_ocr', v);
                        },
                        colors: colors,
                        text: text,
                      ),
                      Container(height: 0.5, color: colors.borderSubtle),
                      _buildToggleRow(
                        icon: AppIconType.shield,
                        title: 'Biometric Passcode',
                        subtitle: 'Require biometric authentication on app launch',
                        value: _biometricLockEnabled,
                        onChanged: (v) {
                          setState(() => _biometricLockEnabled = v);
                          _updatePreference('pref_biometric_lock', v);
                          AppToast.show(
                            context,
                            v ? 'Biometric security activated' : 'Biometric security disabled',
                            type: AppToastType.neutral,
                          );
                        },
                        colors: colors,
                        text: text,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s20),

              // 5. Data & Reset Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Text(
                  'DATA & REPOSITORY',
                  style: text.overline.copyWith(
                    color: colors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadii.cardLarge,
                    border: Border.all(color: colors.borderSubtle, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      _buildActionRow(
                        title: 'Export Full Database (CSV)',
                        subtitle: 'Save all transactions and accounts to disk',
                        actionLabel: 'Export',
                        onTap: _handleExportAllCsv,
                        colors: colors,
                        text: text,
                      ),
                      Container(height: 0.5, color: colors.borderSubtle),
                      _buildActionRow(
                        title: 'Launch Onboarding Tour',
                        subtitle: 'Revisit the 5-step wizard and illustrations',
                        actionLabel: 'Launch',
                        onTap: () => context.push('/onboarding'),
                        colors: colors,
                        text: text,
                      ),
                      Container(height: 0.5, color: colors.borderSubtle),
                      _buildActionRow(
                        title: 'Reset to Mockup Data',
                        subtitle: 'Re-seed database to original mockup state',
                        actionLabel: 'Reset',
                        isDestructive: true,
                        onTap: _handleResetSeedData,
                        colors: colors,
                        text: text,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s24),

              // Footer App Info
              Center(
                child: Column(
                  children: [
                    Text(
                      'Expense Tracker • 100% Zero Material / Cupertino',
                      style: text.caption.copyWith(
                        color: colors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Build v1.0.0 (Production Architecture)',
                      style: text.caption.copyWith(
                        color: colors.textTertiary,
                        fontSize: 10,
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

  Widget _buildSalaryRow(String label, String value, Color valueColor, AppTypography text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: text.bodyMedium.copyWith(
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: text.bodyMedium.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required AppIconType icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppColors colors,
    required AppTypography text,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: AppIcon(icon, size: 18, color: colors.primaryInk),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.subheadline.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppToggle(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
    required AppColors colors,
    required AppTypography text,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.subheadline.copyWith(
                    color: isDestructive ? colors.accent : colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          AppButton(
            label: actionLabel,
            variant: isDestructive ? AppButtonVariant.destructive : AppButtonVariant.secondary,
            size: AppButtonSize.compact,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
