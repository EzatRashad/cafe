import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import 'app_sidebar.dart';
import 'app_top_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: Column(
                children: [
                  const AppTopBar(),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile/tablet: bottom nav + drawer
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppSizes.appBarHeight),
        child: const AppTopBar(showMenuButton: true),
      ),
      drawer: const AppSidebar(inDrawer: true),
      body: child,
      bottomNavigationBar: const _MobileBottomNav(),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final items = _navItems;
    int selectedIndex = items.indexWhere((i) => i.route == location);
    if (selectedIndex < 0) selectedIndex = 0;

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) => context.go(items[i].route),
      backgroundColor: Theme.of(context).colorScheme.surface,
      destinations: items
          .map((i) => NavigationDestination(icon: Icon(i.icon), label: i.labelKey.tr()))
          .toList(),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String labelKey;
  final String route;
  const _NavItem({required this.icon, required this.labelKey, required this.route});
}

final _navItems = <_NavItem>[
  const _NavItem(icon: Icons.dashboard_rounded, labelKey: 'dashboard', route: AppRoutes.dashboard),
  const _NavItem(icon: Icons.point_of_sale_rounded, labelKey: 'billing', route: AppRoutes.billing),
  const _NavItem(icon: Icons.receipt_long_rounded, labelKey: 'invoiceHistory', route: AppRoutes.invoiceHistory),
  const _NavItem(icon: Icons.bar_chart_rounded, labelKey: 'expenses', route: AppRoutes.expenses),
  const _NavItem(icon: Icons.settings_rounded, labelKey: 'settings', route: AppRoutes.settings),
];
