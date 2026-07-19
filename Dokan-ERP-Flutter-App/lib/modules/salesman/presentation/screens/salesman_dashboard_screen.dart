import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dokan_erp/core/security/dokan_access_control.dart';
import 'package:dokan_erp/data/network/api_providers.dart';
import 'package:dokan_erp/modules/auth/auth.dart';
import 'package:dokan_erp/modules/sales/sales.dart';
import 'package:dokan_erp/modules/products/products.dart';

class DokanSalesmanDashboardScreen extends ConsumerStatefulWidget {
  const DokanSalesmanDashboardScreen({super.key});

  @override
  ConsumerState<DokanSalesmanDashboardScreen> createState() =>
      _DokanSalesmanDashboardScreenState();
}

class _DokanSalesmanDashboardScreenState
    extends ConsumerState<DokanSalesmanDashboardScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPermissions();
    });
  }

  Future<void> _refreshPermissions() async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/app/api/auth/me');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final permissionsMap = data['permissions'] is Map
            ? (data['permissions'] as Map).map((k, v) => MapEntry('$k', v == true))
            : const <String, bool>{};

        final permissions = <String, bool>{
          'canSell': permissionsMap['canSell'] ?? true,
          'canViewStock': permissionsMap['canViewStock'] ?? true,
          'canViewReports': permissionsMap['canViewReports'] ?? true,
          'canChangePrice': permissionsMap['canChangePrice'] ?? true,
          'canCollectDue': permissionsMap['canCollectDue'] ?? true,
        };

        await ref.read(dokanAppFlowProvider.notifier).updatePermissions(permissions);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(dokanAppFlowProvider);
    final isWide = MediaQuery.of(context).size.width >= 720;

    final allowedPages = [
      _SalesmanHomeTab(onTabChange: (i) => setState(() => _tab = i)),
      if (flow.can(DokanPermission.salesCreate)) const SalesmanSalesScreen(),
      if (flow.can(DokanPermission.stockView)) const DokanSalesmanProductViewScreen(),
      if (flow.can(DokanPermission.reportsView)) const _SalesmanReportsTab(),
      const _SalesmanProfileTab(),
    ];

    final safeTab = _tab >= allowedPages.length ? 0 : _tab;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (safeTab != 0) {
          setState(() => _tab = 0);
          return;
        }
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (dialogContext, anim1, anim2) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Logout from salesman?',
                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF16302E))),
              content: const Text(
                'Press Yes to log out and return to the salesman login screen.',
                style: TextStyle(color: Color(0xFF5F6A66)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF6F8280)),
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                    await ref.read(dokanAppFlowProvider.notifier).logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E8F5F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
          transitionBuilder: (dialogContext, anim1, anim2, child) {
            final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
            return ScaleTransition(
              scale: curve,
              child: child,
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: isWide
              ? Row(
                  children: [
                    _buildSidebar(context, flow, safeTab, allowedPages.length),
                    const VerticalDivider(width: 1, color: Color(0xFFD6E4E0)),
                    Expanded(
                      child: IndexedStack(
                        index: safeTab,
                        children: allowedPages,
                      ),
                    ),
                  ],
                )
              : IndexedStack(
                  index: safeTab,
                  children: allowedPages,
                ),
        ),
        bottomNavigationBar: isWide
            ? null
            : BottomNavigationBar(
          currentIndex: safeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF334155),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          onTap: (i) {
            if (safeTab == i) return;
            setState(() => _tab = i);
          },
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'হোম'),
            if (flow.can(DokanPermission.salesCreate))
              const BottomNavigationBarItem(
                  icon: Icon(Icons.point_of_sale_outlined), label: 'বিক্রয়'),
            if (flow.can(DokanPermission.stockView))
              const BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined), label: 'স্টক'),
            if (flow.can(DokanPermission.reportsView))
              const BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined), label: 'রিপোর্ট'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'প্রোফাইল'),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, DokanAppFlowState flow, int selectedIndex, int totalPages) {
    final List<Map<String, dynamic>> items = [
      {'index': 0, 'label': 'হোম', 'icon': Icons.home_outlined, 'selectedIcon': Icons.home_rounded},
      if (flow.can(DokanPermission.salesCreate))
        {'index': 1, 'label': 'বিক্রয়', 'icon': Icons.point_of_sale_outlined, 'selectedIcon': Icons.point_of_sale_rounded},
      if (flow.can(DokanPermission.stockView))
        {'index': flow.can(DokanPermission.salesCreate) ? 2 : 1, 'label': 'স্টক', 'icon': Icons.inventory_2_outlined, 'selectedIcon': Icons.inventory_2_rounded},
      if (flow.can(DokanPermission.reportsView))
        {
          'index': (flow.can(DokanPermission.salesCreate) ? 1 : 0) + (flow.can(DokanPermission.stockView) ? 1 : 0) + 1,
          'label': 'রিপোর্ট',
          'icon': Icons.bar_chart_outlined,
          'selectedIcon': Icons.bar_chart_rounded
        },
      {'index': totalPages - 1, 'label': 'প্রোফাইল', 'icon': Icons.person_outline, 'selectedIcon': Icons.person},
    ];

    return Container(
      width: 260,
      color: const Color(0xFF15803D), // Salesman green
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
                        flow.shopName.isNotEmpty ? flow.shopName : 'Dokan ERP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'সেলসম্যান',
                        style: TextStyle(
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
          for (final item in items)
            _buildSidebarItem(
              icon: item['icon'] as IconData,
              selectedIcon: item['selectedIcon'] as IconData,
              label: item['label'] as String,
              selected: selectedIndex == item['index'],
              onTap: () {
                setState(() => _tab = item['index'] as int);
              },
            ),
          const Spacer(),
          const Divider(color: Colors.white24, height: 1),
          _buildSidebarItem(
            icon: Icons.logout_rounded,
            selectedIcon: Icons.logout_rounded,
            label: 'লগ আউট',
            selected: false,
            onTap: () => _triggerLogout(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
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

  Future<void> _triggerLogout(BuildContext context) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Logout from salesman?',
              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF16302E))),
          content: const Text(
            'Press Yes to log out and return to the salesman login screen.',
            style: TextStyle(color: Color(0xFF5F6A66)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF6F8280)),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
                await ref.read(dokanAppFlowProvider.notifier).logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E8F5F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
      transitionBuilder: (dialogContext, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: child,
        );
      },
    );
  }
}

class _SalesmanHomeTab extends ConsumerWidget {
  const _SalesmanHomeTab({required this.onTabChange});

  final ValueChanged<int> onTabChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(dokanAppFlowProvider);
    final pos = ref.watch(dokanPosProvider);
    final isWide = MediaQuery.of(context).size.width >= 720;
    final myPhone = flow.currentSalesmanPhone;

    final salesHistoryOrders =
        ref.watch(salesHistoryOrdersProvider).valueOrNull ??
            const <DokanPosOrderRecord>[];
    final allOrders = mergeSalesHistoryOrders(
      localOrders: pos.orders,
      remoteOrders: salesHistoryOrders,
    );

    final myOrders = allOrders
        .where((e) =>
            myPhone == null ||
            myPhone.isEmpty ||
            _phoneNumbersMatch(e.salesmanPhone, myPhone))
        .toList();

    final today = DateTime.now();
    final todayOrders = myOrders.where((e) {
      return e.createdAt.year == today.year &&
          e.createdAt.month == today.month &&
          e.createdAt.day == today.day;
    }).toList();

    final todayTotal =
        todayOrders.fold<int>(0, (sum, e) => sum + e.totalAmount);
    final lastSale = todayOrders.isEmpty ? null : todayOrders.first.createdAt;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(salesHistoryOrdersProvider);
        try {
          await ref.read(salesHistoryOrdersProvider.future);
        } catch (_) {}
      },
      color: const Color(0xFF00694C),
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _SalesmanHeader(
            shopName: flow.shopName,
            name: flow.currentSalesmanName ?? 'সেলসম্যান',
          ),
          const SizedBox(height: 14),
          const _SalesmanRoleCard(),
          const SizedBox(height: 16),
          _SummaryCard(
            total: todayTotal,
            count: todayOrders.length,
            lastSale: lastSale,
          ),
          const SizedBox(height: 22),
          const Text(
            'দ্রুত কাজ',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isWide ? 4 : 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isWide ? 1.8 : 1.4,
            children: [
              _ActionCard(
                title: 'নতুন বিক্রয়',
                icon: Icons.add_shopping_cart_rounded,
                iconBg: const Color(0xFFCCFBF1),
                iconColor: const Color(0xFF0F766E),
                onTap: () => onTabChange(1),
              ),
              _ActionCard(
                title: 'পণ্য খুঁজুন',
                icon: Icons.search_rounded,
                iconBg: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF1D4ED8),
                onTap: () => onTabChange(2),
              ),
              _ActionCard(
                title: 'স্টক চেক করুন',
                icon: Icons.inventory_2_rounded,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF7E22CE),
                onTap: () => onTabChange(2),
              ),
              _ActionCard(
                title: 'বাকি দেখুন',
                icon: Icons.receipt_long_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFB45309),
                onTap: () => onTabChange(3),
              ),
              _ActionCard(
                title: 'খদ্দেরের বাকি',
                icon: Icons.people_alt_rounded,
                iconBg: const Color(0xFFFFE4E6),
                iconColor: const Color(0xFFBE123C),
                onTap: () => onTabChange(3),
              ),
              _ActionCard(
                title: 'বিক্রয় ইতিহাস',
                icon: Icons.history_rounded,
                iconBg: const Color(0xFFE0E7FF),
                iconColor: const Color(0xFF4338CA),
                onTap: () => onTabChange(3),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'সাম্প্রতিক বিক্রয়',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => onTabChange(3),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0F766E),
                ),
                child: const Text(
                  'সব দেখুন',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (myOrders.isEmpty)
            const _EmptyCard(text: 'এখনো কোনো বিক্রয় নেই')
          else
            ...myOrders.take(5).map(
                  (e) => _RecentSaleTile(
                    name: e.customerName,
                    amount: e.totalAmount,
                    type: dokanPosPaymentMethodLabel(e.paymentMethod),
                    time: _formatTime(e.createdAt),
                  ),
                ),
        ],
      ),
    );
  }
}

String _bengaliNumber(Object value) {
  final english = value.toString();
  const enToBn = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };
  return english.split('').map((ch) => enToBn[ch] ?? ch).join('');
}

class _SalesmanRoleCard extends StatelessWidget {
  const _SalesmanRoleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFA7F3D0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08059669),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF059669),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'সেলসম্যান এক্সেস',
                  style: TextStyle(
                    color: Color(0xFF047857),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'আপনি সহজে নতুন বিক্রয় তৈরি, পণ্য ক্যাটালগ দেখতে ও স্টক সংক্রান্ত তথ্য পাঠাতে পারবেন। ইনভেন্টরি পরিবর্তনের অধিকার স্বত্বাধিকারীর কাছে সংরক্ষিত।',
                  style: TextStyle(
                    color: Color(0xFF065F46),
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesmanHeader extends StatelessWidget {
  const _SalesmanHeader({
    required this.shopName,
    required this.name,
  });

  final String shopName;
  final String name;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'শুভ সকাল';
    if (hour < 17) return 'শুভ অপরাহ্ন';
    return 'শুভ সন্ধ্যা';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর'
    ];
    final dateStr =
        '${_bengaliNumber(now.day)} ${months[now.month - 1]} ${_bengaliNumber(now.year)}';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF047857),
            Color(0xFF0F766E),
            Color(0xFF0D9488),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260F766E),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        shopName.isEmpty ? 'আমার দোকান' : shopName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_pin_rounded,
                              color: Colors.white, size: 15),
                          SizedBox(width: 5),
                          Text(
                            'সেলসম্যান',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '${_getGreeting()}, $name 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.count,
    required this.lastSale,
  });

  final int total;
  final int count;
  final DateTime? lastSale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'আমার আজকের বিক্রয়',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded,
                        color: Color(0xFF059669), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'আজকের লাইভ',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '৳ ',
                style: TextStyle(
                  color: Color(0xFF0F766E),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                _bengaliNumber(total),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        color: Color(0xFF475569), size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '${_bengaliNumber(count)}টি লেনদেন',
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: Color(0xFF475569), size: 14),
                    const SizedBox(width: 5),
                    Text(
                      lastSale == null
                          ? 'শেষ বিক্রয়: নেই'
                          : 'শেষ বিক্রয়: ${_bengaliNumber(_formatTime(lastSale!))}',
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSaleTile extends StatelessWidget {
  const _RecentSaleTile({
    required this.name,
    required this.amount,
    required this.type,
    required this.time,
  });

  final String name;
  final int amount;
  final String type;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF2563EB),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'সরাসরি ক্রেতা' : name,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳ ${_bengaliNumber(amount)}',
                style: const TextStyle(
                  color: Color(0xFF0F766E),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _bengaliNumber(time),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalesmanReportsTab extends ConsumerWidget {
  const _SalesmanReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(dokanAppFlowProvider);
    final pos = ref.watch(dokanPosProvider);
    final myPhone = flow.currentSalesmanPhone;

    final salesHistoryOrders =
        ref.watch(salesHistoryOrdersProvider).valueOrNull ??
            const <DokanPosOrderRecord>[];
    final allOrders = mergeSalesHistoryOrders(
      localOrders: pos.orders,
      remoteOrders: salesHistoryOrders,
    );

    final myOrders = allOrders
        .where((e) =>
            myPhone == null ||
            myPhone.isEmpty ||
            _phoneNumbersMatch(e.salesmanPhone, myPhone))
        .toList();

    final total = myOrders.fold<int>(0, (sum, e) => sum + e.totalAmount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'আমার রিপোর্ট',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        _ReportCard('মোট বিক্রয়', '৳$total'),
        _ReportCard('মোট লেনদেন', '${myOrders.length}টি'),
        const SizedBox(height: 16),
        const Text(
          'নিজের বিক্রয় ইতিহাস',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (myOrders.isEmpty)
          const _EmptyCard(text: 'কোনো রিপোর্ট নেই')
        else
          ...myOrders.map(
            (e) => _RecentSaleTile(
              name: e.customerName,
              amount: e.totalAmount,
              type: dokanPosPaymentMethodLabel(e.paymentMethod),
              time: _formatTime(e.createdAt),
            ),
          ),
      ],
    );
  }
}

class _SalesmanProfileTab extends ConsumerWidget {
  const _SalesmanProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(dokanAppFlowProvider);
    final salesmanName =
        _profileValue(flow.currentSalesmanName, fallback: 'প্রদান করা হয়নি');
    final salesmanPhone =
        _profileValue(flow.currentSalesmanPhone, fallback: 'প্রদান করা হয়নি');
    const employeeCode = 'উপলব্ধ নয়';
    final accountStatus = flow.roleReady && flow.isSalesman
        ? 'সক্রিয়'
        : flow.roleReady
            ? 'নিষ্ক্রিয়'
            : 'উপলব্ধ নয়';
    const lastLogin = 'উপলব্ধ নয়';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'প্রোফাইল',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        _ProfileSectionCard(
          title: 'পরিচয়পত্র',
          icon: Icons.badge_outlined,
          iconBg: const Color(0xFFECFDF5),
          iconColor: const Color(0xFF0F766E),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x200F766E),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salesmanName,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Text(
                            'সেলসম্যান প্রোফাইল',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _ProfileInfoRow(
                label: 'সেলসম্যান আইডি / কোড',
                value: employeeCode,
              ),
              const SizedBox(height: 10),
              _ProfileInfoRow(
                label: 'ফোন নম্বর',
                value: _bengaliNumber(salesmanPhone),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ProfileSectionCard(
          title: 'একাউন্ট বিবরণ',
          icon: Icons.manage_accounts_outlined,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          child: Column(
            children: [
              const _ProfileInfoRow(
                label: 'পদবী',
                value: 'সেলসম্যান',
              ),
              const SizedBox(height: 10),
              _ProfileInfoRow(
                label: 'দোকানের নাম',
                value: _profileValue(flow.shopName, fallback: 'উপলব্ধ নয়'),
              ),
              const SizedBox(height: 10),
              const _ProfileInfoRow(
                label: 'স্টাফ কোড',
                value: employeeCode,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ProfileSectionCard(
          title: 'সিস্টেম স্ট্যাটাস',
          icon: Icons.shield_outlined,
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF7E22CE),
          child: Column(
            children: [
              _ProfileInfoRow(
                label: 'একাউন্ট অবস্থা',
                value: accountStatus,
                valueColor: accountStatus == 'সক্রিয়'
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
              ),
              const SizedBox(height: 10),
              const _ProfileInfoRow(
                label: 'সর্বশেষ লগইন সময়',
                value: lastLogin,
              ),
              const SizedBox(height: 10),
              _ProfileInfoRow(
                label: 'সেশন প্রস্তুত',
                value: flow.roleReady ? 'হ্যাঁ' : 'না',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ProfileSectionCard(
          title: 'অ্যাকশন',
          icon: Icons.logout_outlined,
          iconBg: const Color(0xFFFFF1F2),
          iconColor: const Color(0xFFE11D48),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text(
                            'লগআউট করতে চান?',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          content: const Text(
                            'লগআউট করলে আপনার বর্তমান সেশন শেষ হবে এবং লগইন পেজে ফিরে যাবে।',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('না'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFE11D48),
                              ),
                              child: const Text('হ্যাঁ, লগআউট'),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmed != true) {
                      return;
                    }
                    await ref.read(dokanAppFlowProvider.notifier).logout();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF1F2),
                    foregroundColor: const Color(0xFFE11D48),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFECDD3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'লগআউট করুন',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _profileValue(String? value, {required String fallback}) {
  final text = value?.trim() ?? '';
  return text.isEmpty ? fallback : text;
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard(this.title, this.value);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFE5E7EB)),
    borderRadius: BorderRadius.circular(16),
  );
}

String _formatTime(DateTime time) {
  final hour = time.hour > 12 ? time.hour - 12 : time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

bool _phoneNumbersMatch(String? p1, String? p2) {
  if (p1 == null || p2 == null) return false;
  final d1 = p1.replaceAll(RegExp(r'\D'), '');
  final d2 = p2.replaceAll(RegExp(r'\D'), '');
  if (d1.isEmpty || d2.isEmpty) return false;
  final s1 = d1.length > 10 ? d1.substring(d1.length - 10) : d1;
  final s2 = d2.length > 10 ? d2.substring(d2.length - 10) : d2;
  return s1 == s2;
}
