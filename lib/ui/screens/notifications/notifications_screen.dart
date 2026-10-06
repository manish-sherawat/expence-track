import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/seed/mockup_seed_data.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../providers/finance_providers.dart';

enum NotificationType { budget, salary, ai, payment }

class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final NotificationType type;
  bool isRead;
  final String? route;

  AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
    this.route,
  });
}

/// Notifications and Alerts screen.
///
/// Features:
/// - Categorized alert notifications (Budget, Salary, AI, Recurring)
/// - Visual unread indicators
/// - Mark all as read action
/// - Interactive tap-to-navigate for AI insights
/// - 100% custom components, ZERO Material / Cupertino
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final Set<String> _readIds = {'notif_rent_scheduled'};
  NotificationType? _selectedFilter;

  List<AppNotificationItem> _buildNotificationsList() {
    final salary = ref.watch(salaryProfileStreamProvider).value ?? MockupSeedData.salaryProfile;
    final liveInsights = ref.watch(insightsStreamProvider).value ?? [];

    final list = <AppNotificationItem>[
      AppNotificationItem(
        id: 'notif_salary_deposit',
        title: 'Income Deposit Confirmed',
        message: '${salary.employerName} deposited ${salary.monthlyNet.format()} net income into your primary account.',
        timeAgo: '2h ago',
        type: NotificationType.salary,
        isRead: _readIds.contains('notif_salary_deposit'),
      ),
      AppNotificationItem(
        id: 'notif_dining_warning',
        title: 'Dining Budget Warning',
        message: 'You have spent \$489.20 (81%) of your \$600.00 dining budget with 12 days remaining.',
        timeAgo: '5h ago',
        type: NotificationType.budget,
        isRead: _readIds.contains('notif_dining_warning'),
        route: '/insight',
      ),
    ];

    // Add real AI insights
    for (final insight in liveInsights) {
      list.add(
        AppNotificationItem(
          id: 'insight_${insight.id}',
          title: insight.title,
          message: insight.description,
          timeAgo: '1d ago',
          type: NotificationType.ai,
          isRead: _readIds.contains('insight_${insight.id}'),
          route: insight.routePath,
        ),
      );
    }

    if (liveInsights.isEmpty) {
      list.add(
        AppNotificationItem(
          id: 'notif_ai_default',
          title: 'AI Savings Detected',
          message: 'AI analyzed your grocery and dining spending: shifting 2 meals could save \$140.00/mo.',
          timeAgo: '1d ago',
          type: NotificationType.ai,
          isRead: _readIds.contains('notif_ai_default'),
          route: '/insight',
        ),
      );
    }

    list.add(
      AppNotificationItem(
        id: 'notif_rent_scheduled',
        title: 'Rent Payment Scheduled',
        message: 'Scheduled automatic rent transfer of \$1,200.00 for Metropolitan Real Estate.',
        timeAgo: '3d ago',
        type: NotificationType.payment,
        isRead: _readIds.contains('notif_rent_scheduled'),
      ),
    );

    return list;
  }

  void _markAllAsRead(List<AppNotificationItem> items) {
    setState(() {
      for (final n in items) {
        _readIds.add(n.id);
      }
    });
    AppToast.show(
      context,
      'All notifications marked as read',
      type: AppToastType.neutral,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    final allNotifications = _buildNotificationsList();
    final unreadCount = allNotifications.where((n) => !n.isRead).length;

    final filtered = allNotifications.where((n) {
      if (_selectedFilter != null && n.type != _selectedFilter) {
        return false;
      }
      return true;
    }).toList();

    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.s12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
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
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications',
                                style: text.title2.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '$unreadCount unread alert${unreadCount == 1 ? '' : 's'}',
                                style: text.caption.copyWith(
                                  color: colors.textSecondary,
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
                  if (unreadCount > 0)
                    Pressable(
                      onTap: () => _markAllAsRead(allNotifications),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: AppRadii.fullPill,
                        ),
                        child: Text(
                          'Mark All Read',
                          style: text.caption.copyWith(
                            color: colors.primaryInk,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Filter Pills
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildFilterTab('All', null, colors, text),
                  const SizedBox(width: AppSpacing.s8),
                  _buildFilterTab('Budget', NotificationType.budget, colors, text),
                  const SizedBox(width: AppSpacing.s8),
                  _buildFilterTab('Income', NotificationType.salary, colors, text),
                  const SizedBox(width: AppSpacing.s8),
                  _buildFilterTab('AI Insights', NotificationType.ai, colors, text),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s12),

            // 3. Notification List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications in this category',
                        style: text.subheadline.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: AppSpacing.s8,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s10),
                      itemBuilder: (context, index) {
                        final notif = filtered[index];
                        return _buildNotificationCard(notif, colors, text);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(
    String label,
    NotificationType? type,
    AppColors colors,
    AppTypography text,
  ) {
    final isSelected = _selectedFilter == type;
    return Pressable(
      onTap: () => setState(() => _selectedFilter = type),
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

  Widget _buildNotificationCard(
    AppNotificationItem notif,
    AppColors colors,
    AppTypography text,
  ) {
    final Color badgeColor;
    final Color badgeBg;
    final AppIconType iconType;

    switch (notif.type) {
      case NotificationType.salary:
        badgeColor = colors.positive;
        badgeBg = colors.positiveTint;
        iconType = AppIconType.wallet;
        break;
      case NotificationType.budget:
        badgeColor = colors.accent;
        badgeBg = colors.accentTint;
        iconType = AppIconType.chart;
        break;
      case NotificationType.ai:
        badgeColor = const Color(0xFF8B5CF6);
        badgeBg = const Color(0xFFEDE9FE);
        iconType = AppIconType.sparkle;
        break;
      case NotificationType.payment:
        badgeColor = colors.primaryInk;
        badgeBg = colors.surfaceVariant;
        iconType = AppIconType.receipt;
        break;
    }

    return Pressable(
      onTap: () {
        setState(() {
          _readIds.add(notif.id);
          notif.isRead = true;
        });
        if (notif.route != null) {
          context.push(notif.route!);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadii.card,
          border: Border.all(
            color: notif.isRead
                ? colors.borderSubtle
                : colors.accent.withValues(alpha: 0.3),
            width: notif.isRead ? 0.5 : 1.2,
          ),
          boxShadow: notif.isRead ? null : AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: badgeBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppIcon(iconType, size: 20, color: badgeColor),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notif.title,
                        style: text.subheadline.copyWith(
                          color: colors.textPrimary,
                          fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            notif.timeAgo,
                            style: text.caption.copyWith(
                              color: colors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                          if (!notif.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: text.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  if (notif.route != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'View Insight Details',
                          style: text.caption.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AppIcon(AppIconType.chevronRight, size: 12, color: colors.accent),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
