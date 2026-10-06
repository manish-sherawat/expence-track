import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design_system/tokens/tokens.dart';
import 'router.dart';

/// App theme mode options.
enum AppThemeMode { system, light, dark }

/// Global theme mode provider.
final themeModeProvider = StateProvider<AppThemeMode>((ref) => AppThemeMode.system);

/// Root application widget built strictly with WidgetsApp.router.
/// Zero Material and Zero Cupertino dependencies.
/// Supports dynamic light/dark theme, reduced motion/transparency accessibility,
/// and responsive web container formatting.
class AppApp extends ConsumerWidget {
  const AppApp({super.key, this.router});

  final GoRouter? router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.maybePlatformBrightnessOf(context) ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    final isDark = mode == AppThemeMode.dark ||
        (mode == AppThemeMode.system && platformBrightness == Brightness.dark);

    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion = mediaQuery?.disableAnimations ?? false;
    final reduceTransparency = mediaQuery?.accessibleNavigation ?? false;

    final themeData = isDark
        ? AppThemeData.dark(
            reduceMotion: reduceMotion,
            reduceTransparency: reduceTransparency,
          )
        : AppThemeData.light(
            reduceMotion: reduceMotion,
            reduceTransparency: reduceTransparency,
          );

    return WidgetsApp.router(
      title: 'Expense Tracker',
      color: themeData.colors.bg,
      textStyle: themeData.typography.body,
      routerConfig: router ?? appRouter,
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? child) {
        return AppTheme(
          data: themeData,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout: for wide browser viewports (desktop/web > 900px),
                // center content in a phone container with subtle framing
                if (constraints.maxWidth > 900) {
                  return ColoredBox(
                    color: isDark ? const Color(0xFF09090A) : const Color(0xFFE4E5E9),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 440,
                          maxHeight: double.infinity,
                        ),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: themeData.colors.bg,
                            boxShadow: AppShadows.card,
                          ),
                          child: child ?? const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  );
                }
                return child ?? const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}

