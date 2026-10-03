import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../design_system/components/components.dart';
import '../design_system/gallery/component_gallery_screen.dart';
import '../design_system/tokens/tokens.dart';

/// App Router configured with GoRouter and custom page builders.
/// Never uses MaterialPageRoute or CupertinoPageRoute.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const Phase0PlaceholderScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/gallery',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ComponentGalleryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
  ],
);

/// Placeholder screen for Phase 0 verification with button to open Component Gallery.
class Phase0PlaceholderScreen extends StatelessWidget {
  const Phase0PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Container(
      color: colors.bg,
      alignment: Alignment.center,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.pill,
                border: Border.all(color: colors.border),
              ),
              child: Text(
                '✦ PHASE 1 FOUNDATION ACTIVE',
                style: text.caption.copyWith(
                  color: colors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Salary Tracker',
              style: text.displayAmount.copyWith(fontSize: 32),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Zero Material • Zero Cupertino • 100% Custom',
              style: text.label,
            ),
            const SizedBox(height: AppSpacing.s24),
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.card,
                border: Border.all(color: colors.border),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('INCOME', style: text.overline),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        r'+$8,429',
                        style: text.rowTitle.copyWith(color: colors.positive),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: colors.border,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('EXPENSES', style: text.overline),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        r'-$3,218',
                        style: text.rowTitle.copyWith(color: colors.negative),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: colors.border,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('SAVED', style: text.overline),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        r'$2,190',
                        style: text.rowTitle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s28),
            AppButton(
              label: 'Open Component Gallery',
              trailingIcon: AppIconType.chevronRight,
              onPressed: () {
                context.push('/gallery');
              },
            ),
          ],
        ),
      ),
    );
  }
}
