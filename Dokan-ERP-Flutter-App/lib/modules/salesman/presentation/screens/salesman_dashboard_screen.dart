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
      ref.invalidate(salesHistoryOrdersProvider);
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
        final shouldLogout = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Logout from salesman?'),
              content: const Text(
                'Press Yes to log out and return to the salesman login screen.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('No'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
        if (shouldLogout != true) {
          return;
        }
        await ref.read(dokanAppFlowProvider.notifier).logout();
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
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
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout from salesman?'),
          content: const Text(
            'Press Yes to log out and return to the salesman login screen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    if (shouldLogout != true) {
      return;
    }
    await ref.read(dokanAppFlowProvider.notifier).logout();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
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
          const SizedBox(height: 12),
          const _SalesmanRoleCard(),
          const SizedBox(height: 16),
          _SummaryCard(
            total: todayTotal,
            count: todayOrders.length,
            lastSale: lastSale,
          ),
        const SizedBox(height: 20),
        const Text(
          'দ্রুত কাজ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 4 : 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isWide ? 1.8 : 1.45,
          children: [
            _ActionCard('নতুন বিক্রয়', Icons.add_shopping_cart_outlined,
                () => onTabChange(1)),
            _ActionCard(
                'পণ্য খুঁজুন', Icons.search_outlined, () => onTabChange(2)),
            _ActionCard('স্টক চেক করুন', Icons.inventory_outlined,
                () => onTabChange(2)),
            _ActionCard('বাকি দেখুন', Icons.receipt_long_outlined,
                () => onTabChange(3)),
            _ActionCard(
                'খদ্দেরের বাকি', Icons.people_outline, () => onTabChange(3)),
            _ActionCard('ইতিহাস', Icons.history_outlined, () => onTabChange(3)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'সাম্প্রতিক বিক্রয়',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () => onTabChange(3),
              child: const Text('সব দেখুন'),
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

class _SalesmanRoleCard extends StatelessWidget {
  const _SalesmanRoleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFF0F7FF),
        border: Border.all(color: const Color(0xFFBED7FF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salesman access',
            style: TextStyle(
              color: Color(0xFF1F63E0),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'You can create sales, view products, and send stock alerts. Inventory edits stay with the owner.',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF15803D),
            Color(0xFF22C55E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3316A34A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  shopName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'সেলসম্যান',
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'শুভ সকাল, $name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${now.day}/${now.month}/${now.year}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
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
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'আমার আজকের বিক্রয়',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '৳$total',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$countটি লেনদেন',
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            lastSale == null
                ? 'শেষ বিক্রয়: নেই'
                : 'শেষ বিক্রয়: ${_formatTime(lastSale!)}',
            style: const TextStyle(color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(this.title, this.icon, this.onTap);

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black, size: 28),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
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
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'সরাসরি ক্রেতা' : name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(type, style: const TextStyle(color: Color(0xFF334155))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳$amount',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(color: Color(0xFF334155))),
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
        _profileValue(flow.currentSalesmanName, fallback: 'Not provided');
    final salesmanPhone =
        _profileValue(flow.currentSalesmanPhone, fallback: 'Not provided');
    const employeeCode = 'Not available';
    final accountStatus = flow.roleReady && flow.isSalesman
        ? 'Active'
        : flow.roleReady
            ? 'Inactive'
            : 'Not available';
    const lastLogin = 'Not available';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'প্রোফাইল',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        _ProfileSectionCard(
          title: 'Identity Card',
          icon: Icons.badge_outlined,
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
                      color: const Color(0xFFE8F5EE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF16A34A),
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salesmanName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Salesman profile',
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _ProfileInfoRow(
                label: 'Salesman ID / Employee Code',
                value: employeeCode,
              ),
              const SizedBox(height: 10),
              _ProfileInfoRow(
                label: 'Phone Number',
                value: salesmanPhone,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ProfileSectionCard(
          title: 'Account Details',
          icon: Icons.manage_accounts_outlined,
          child: Column(
            children: [
              const _ProfileInfoRow(
                label: 'Role',
                value: 'Salesman',
              ),
              const SizedBox(height: 10),
              _ProfileInfoRow(
                label: 'Shop Name',
                value: _profileValue(flow.shopName, fallback: 'Not available'),
              ),
              const SizedBox(height: 10),
              const _ProfileInfoRow(
                label: 'Employee Code',
                value: employeeCode,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ProfileSectionCard(
          title: 'System Status',
          icon: Icons.shield_outlined,
          child: Column(
            children: [
              _ProfileInfoRow(
                label: 'Account Status',
                value: accountStatus,
              ),
              const SizedBox(height: 10),
              const _ProfileInfoRow(
                label: 'Last Login Time',
                value: lastLogin,
              ),
              const SizedBox(height: 10),
              _ProfileInfoRow(
                label: 'Session Ready',
                value: flow.roleReady ? 'Yes' : 'No',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ProfileSectionCard(
          title: 'Actions',
          icon: Icons.logout_outlined,
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
                          title: const Text('Are you sure you want to logout?'),
                          content: const Text(
                            'Yes will end the current auth session and return to login. No will cancel.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('No'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text('Yes'),
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
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w800),
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
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF16A34A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w800,
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
