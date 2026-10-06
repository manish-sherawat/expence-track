import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeAreaBottom: false,
      floatingBottomBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FrostedNavBar(
          selectedIndex: navigationShell.currentIndex,
          onItemSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          onCenterAction: () {
            // Center '+' quick action - opens Add Transaction flow
            context.push('/add-transaction');
          },
        ),
      ),
      body: navigationShell,
    );
  }
}
