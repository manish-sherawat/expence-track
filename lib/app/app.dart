import 'package:flutter/widgets.dart';
import '../design_system/tokens/tokens.dart';
import 'router.dart';

/// Root application widget built strictly with WidgetsApp.router.
/// Zero Material and Zero Cupertino dependencies.
class AppApp extends StatelessWidget {
  const AppApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = AppThemeData.light();

    return WidgetsApp.router(
      title: 'Salary Tracker',
      color: themeData.colors.bg,
      textStyle: themeData.typography.body,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? child) {
        return AppTheme(
          data: themeData,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
