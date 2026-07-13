import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routing/app_routes.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';
import '../../modules/auth/presentation/providers/app_flow_provider.dart';

class DokanResponsivePage extends ConsumerWidget {
  const DokanResponsivePage({
    super.key,
    required this.selectedIndex,
    required this.child,
  });

  final int selectedIndex;
  final Widget child;

  void _navigate(BuildContext context, String routeName) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == routeName) return;

    if (routeName == '/' || routeName == AppRoutes.dashboard) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      if (ModalRoute.of(context)?.isFirst ?? true) {
        Navigator.of(context).pushNamed(routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    if (!isWide) {
      return child;
    }

    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context, ref),
          const VerticalDivider(width: 1, color: Color(0xFFD6E4E0)),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(dokanAppFlowProvider);
    ref.watch(languageProvider);

    return Container(
      width: 260,
      color: const Color(0xFF006B53), // Standard Dokan Green
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.storefront_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flow.shopName.isNotEmpty ? flow.shopName : tr('দোকান ইআরপি', 'Dokan ERP'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          flow.isSalesman ? tr('সেলসম্যান', 'Salesman') : tr('মালিক', 'Owner'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),
            _buildSidebarItem(
              context,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: tr('হোম', 'Home'),
              selected: selectedIndex == 0,
              onTap: () => _navigate(context, '/'),
            ),
            _buildSidebarItem(
              context,
              icon: Icons.point_of_sale_outlined,
              selectedIcon: Icons.point_of_sale_rounded,
              label: tr('বিক্রয়', 'Sales'),
              selected: selectedIndex == 1,
              onTap: () => _navigate(context, AppRoutes.sales),
            ),
            _buildSidebarItem(
              context,
              icon: Icons.inventory_2_outlined,
              selectedIcon: Icons.inventory_2_rounded,
              label: tr('পণ্য', 'Products'),
              selected: selectedIndex == 2,
              onTap: () => _navigate(context, AppRoutes.products),
            ),
            _buildSidebarItem(
              context,
              icon: Icons.bar_chart_outlined,
              selectedIcon: Icons.bar_chart_rounded,
              label: tr('রিপোর্ট', 'Reports'),
              selected: selectedIndex == 3,
              onTap: () => _navigate(context, AppRoutes.reports),
            ),
            _buildSidebarItem(
              context,
              icon: Icons.more_horiz_outlined,
              selectedIcon: Icons.more_horiz_rounded,
              label: tr('আরও অপশন', 'More Options'),
              selected: selectedIndex == 4,
              onTap: () => _navigate(context, AppRoutes.settings),
            ),
            const Spacer(),
            const Divider(color: Colors.white24, height: 1),
            _buildSidebarItem(
              context,
              icon: Icons.logout_rounded,
              selectedIcon: Icons.logout_rounded,
              label: tr('লগ আউট', 'Log Out'),
              selected: false,
              onTap: () => _showLogoutDialog(context, ref),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color: selected ? Colors.white : Colors.white70,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(tr('লগ আউট', 'Log Out')),
        content: Text(tr('আপনি কি সত্যিই এই অ্যাকাউন্ট থেকে লগ আউট করতে চান?',
            'Are you sure you want to log out from this account?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(tr('বাতিল', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(dokanAppFlowProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              tr('লগ আউট', 'Log Out'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
