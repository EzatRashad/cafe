import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

class AppSidebar extends StatelessWidget {
  final bool inDrawer;
  const AppSidebar({super.key, this.inDrawer = false});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.sidebarBg;

    final sidebar = Container(
      width: AppSizes.sidebarWidth,
      color: bgColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo area
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_cafe_rounded, color: AppColors.primaryDark, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('appName'.tr(),
                            style: const TextStyle(
                              color: AppColors.sidebarText,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis),
                        const Text('POS System',
                            style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                children: _getNavItems(context).map((item) {
                  final isSelected = location == item.route;
                  return _SidebarItem(item: item, isSelected: isSelected);
                }).toList(),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            // Logout button
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
              title: Text('logout'.tr(), style: const TextStyle(color: AppColors.sidebarText, fontSize: 14)),
              onTap: () {
                if (inDrawer) Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => const _LogoutDialog(),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (inDrawer) return Drawer(child: sidebar);
    return sidebar;
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavEntry item;
  final bool isSelected;
  const _SidebarItem({required this.item, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? AppColors.primaryDark : AppColors.sidebarText,
          size: 22,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryDark : AppColors.sidebarText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        dense: true,
        onTap: () => context.go(item.route),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('logout'.tr()),
      content: Text('logoutConfirm'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthCubit>().logout();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: Text('logout'.tr(), style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _NavEntry {
  final IconData icon;
  final String label;
  final String route;
  const _NavEntry({required this.icon, required this.label, required this.route});
}

List<_NavEntry> _getNavItems(BuildContext context) {
  return [
    _NavEntry(icon: Icons.dashboard_rounded, label: 'dashboard'.tr(), route: AppRoutes.dashboard),
    _NavEntry(icon: Icons.category_rounded, label: 'categories'.tr(), route: AppRoutes.categories),
    _NavEntry(icon: Icons.inventory_2_rounded, label: 'products'.tr(), route: AppRoutes.products),
    _NavEntry(icon: Icons.point_of_sale_rounded, label: 'billing'.tr(), route: AppRoutes.billing),
    _NavEntry(icon: Icons.receipt_long_rounded, label: 'invoiceHistory'.tr(), route: AppRoutes.invoiceHistory),
    _NavEntry(icon: Icons.money_off_rounded, label: 'expenses'.tr(), route: AppRoutes.expenses),
    _NavEntry(icon: Icons.settings_rounded, label: 'settings'.tr(), route: AppRoutes.settings),
  ];
}
