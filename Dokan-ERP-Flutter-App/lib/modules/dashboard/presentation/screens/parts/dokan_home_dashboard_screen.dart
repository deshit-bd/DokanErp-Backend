part of '../dashboard_screen.dart';

class DokanHomeDashboardScreen extends ConsumerStatefulWidget {
  const DokanHomeDashboardScreen({super.key});

  @override
  ConsumerState<DokanHomeDashboardScreen> createState() =>
      _DokanHomeDashboardScreenState();
}

class _DokanHomeDashboardScreenState
    extends ConsumerState<DokanHomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(dokanPosProvider.notifier).fetchCustomers().catchError((_) {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final flow = ref.watch(dokanAppFlowProvider);
    final dashboardSummary = ref.watch(dashboardSummaryProvider).valueOrNull;
    final selectedCount =
        ref.read(dokanPopularProductsProvider.notifier).selectedCount;
    final catalogProducts = ref.watch(dokanInventoryCatalogProvider);
    final recentProducts = catalogProducts.take(10).toList(growable: false);
    final threshold = ref.watch(stockThresholdProvider);
    final lowStockCount = catalogProducts
        .where((product) => product.stock > 0 && product.stock < threshold)
        .length;
    final todayLabel = _todayLabel();

    final purchasesAsync = ref.watch(purchaseOrderProvider);
    final supplierState = ref.watch(dokanPosProvider);
    final salesHistoryOrders =
        ref.watch(salesHistoryOrdersProvider).valueOrNull ??
            const <DokanPosOrderRecord>[];
    final mergedSalesHistoryOrders = mergeSalesHistoryOrders(
      localOrders: supplierState.orders,
      remoteOrders: salesHistoryOrders,
    );
    final today = DateTime.now();
    final todaySalesOrders = mergedSalesHistoryOrders
        .where((order) =>
            order.createdAt.year == today.year &&
            order.createdAt.month == today.month &&
            order.createdAt.day == today.day &&
            order.status != DokanPosOrderStatus.cancelled)
        .toList(growable: false);

    // Admin (owner) sales today
    final todayAdminOrders = todaySalesOrders
        .where((order) =>
            order.salesmanPhone == null ||
            order.salesmanPhone!.isEmpty ||
            order.salesmanPhone == flow.ownerPhone)
        .toList(growable: false);
    final todayAdminSalesTotal = todayAdminOrders.fold<int>(
      0,
      (sum, order) => sum + order.lines.fold<int>(0, (lineSum, line) => lineSum + line.lineTotal),
    );
    final todayAdminProfit = todayAdminOrders.fold<int>(
      0,
      (sum, order) => sum + math.max(0, order.grossProfit),
    );
    final todayProfitTotal = todaySalesOrders.fold<int>(
      0,
      (sum, order) => sum + math.max(0, order.grossProfit),
    );

    // Salesman (employee) sales today
    final todaySalesmanSalesTotal = todaySalesOrders
        .where((order) =>
            order.salesmanPhone != null &&
            order.salesmanPhone!.isNotEmpty &&
            order.salesmanPhone != flow.ownerPhone)
        .fold<int>(0, (sum, order) => sum + order.lines.fold<int>(0, (lineSum, line) => lineSum + line.lineTotal));

    final todayPurchasesSum = purchasesAsync.maybeWhen(
      data: (orders) {
        return orders
            .where((order) =>
                order.createdAt.year == today.year &&
                order.createdAt.month == today.month &&
                order.createdAt.day == today.day &&
                order.status != PurchaseOrderStatus.cancelled)
            .fold<int>(0, (sum, order) => sum + order.totalAmount);
      },
      orElse: () => 0,
    );
    final supplierPurchaseTotal = supplierState.supplierLedger
        .where((record) => record.kind == DokanSupplierLedgerKind.purchase)
        .fold<int>(0, (sum, record) => sum + record.amount);
    final supplierPaymentTotal = supplierState.supplierLedger
        .where((record) => record.kind == DokanSupplierLedgerKind.payment)
        .fold<int>(0, (sum, record) => sum + record.amount);
    final supplierDueTotal =
        math.max<int>(0, supplierPurchaseTotal - supplierPaymentTotal);

    final computedSalesTotal = todaySalesOrders.fold<int>(
      0,
      (sum, order) => sum + order.lines.fold<int>(0, (lineSum, line) => lineSum + line.lineTotal),
    );

    // Filtered today totals for admin (Today's Sales card)
    final totalSales = todaySalesOrders.isNotEmpty || salesHistoryOrders.isNotEmpty
        ? computedSalesTotal
        : (dashboardSummary?.todaySales ?? 0);
    final totalOrders = todaySalesOrders.isNotEmpty || salesHistoryOrders.isNotEmpty
        ? todaySalesOrders.length
        : (dashboardSummary?.todayOrders ?? 0);
    final todayProfit = todaySalesOrders.isNotEmpty || salesHistoryOrders.isNotEmpty
        ? todayProfitTotal
        : (dashboardSummary?.todayProfit ?? 0);
    final dashboardLowStockCount =
        dashboardSummary?.lowStockCount ?? lowStockCount;
    final computedCustomerDueTotal = _calculateTotalCustomerDue(supplierState, mergedSalesHistoryOrders);
    final customerDueTotal = computedCustomerDueTotal;
    final dashboardPurchases = math.max(
      dashboardSummary?.todayPurchases ?? 0,
      todayPurchasesSum,
    );
    final dashboardProductCount = math.max(
      dashboardSummary?.totalProducts ?? 0,
      math.max(catalogProducts.length, selectedCount),
    );
    final dashboardSupplierDue = dashboardSummary?.payable ?? supplierDueTotal;
    final dashboardExpenses = dashboardSummary?.todayExpenses ?? 0;
    final salesComparisonLabel = dashboardSummary?.salesComparisonLabel ??
        'গত ৭ দিনের তুলনায় ১৫% বৃদ্ধি';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldLogout = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(tr('লগ আউট করবেন?', 'Log out?')),
              content: Text(
                tr('আপনি কি এই অ্যাকাউন্ট থেকে লগ আউট করতে চান?',
                    'Are you sure you want to log out from this account?'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(tr('না', 'No')),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(tr('হ্যাঁ', 'Yes')),
                ),
              ],
            );
          },
        );
        if (shouldLogout == true && context.mounted) {
          await ref.read(dokanAppFlowProvider.notifier).logout();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF5FB),
        floatingActionButton: const DokanVoiceAssistantButton(),
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const footerHeight = 52.0;
              return Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
                          child: Row(
                            children: [
                              _HeaderIconButton(
                                icon: Icons.menu_rounded,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const DokanAroOptionScreen()),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        flow.shopName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF0D6B55),
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.circle,
                                            size: 10, color: Color(0xFF17A572)),
                                        const SizedBox(width: 8),
                                        Text(
                                          tr('অনলাইন', 'Online'),
                                          style: const TextStyle(
                                            color: Color(0xFF17A572),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _HeaderIconButton(
                                icon: Icons.search_rounded,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const DokanGlobalSearchScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              AnimatedBuilder(
                                animation: dokanNotificationListenable,
                                builder: (context, _) {
                                  return _HeaderIconButton(
                                    icon: Icons.notifications_none_rounded,
                                    onTap: () {
                                      if (!flow.can(
                                        DokanPermission.notificationsView,
                                      )) {
                                        return;
                                      }
                                      showDokanNotificationPreviewSheet(
                                          context);
                                    },
                                    badge: dokanNotificationUnreadCount > 0,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(dashboardSummaryProvider);
                              ref.invalidate(dokanInventoryCatalogProvider);
                              ref.invalidate(salesHistoryOrdersProvider);
                              try {
                                await ref.read(dokanPosProvider.notifier).fetchCustomers();
                                await ref.read(dashboardSummaryProvider.future);
                                await ref.read(salesHistoryOrdersProvider.future);
                              } catch (_) {}
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(
                                  parent: ClampingScrollPhysics()),
                              padding: const EdgeInsets.fromLTRB(
                                  20, 16, 20, footerHeight + 44),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight - 126),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DokanHabitCard(
                                      todaySales: totalSales,
                                      todayProfit: todayProfit,
                                      growthPercent:
                                          dashboardSummary?.salesGrowthPercent ??
                                              0,
                                    ),
                                    _SalesSummaryCard(
                                      dateLabel: todayLabel,
                                      totalSales:
                                          '৳ ${_bengaliNumber(totalSales)}',
                                      totalOrders:
                                          '${_bengaliNumber(totalOrders)}${tr('টি', ' sales')}',
                                      profit:
                                          '৳ ${_bengaliNumber(todayProfit)}',
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const DokanDailySalesReportScreen(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    GridView.count(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      childAspectRatio:
                                          constraints.maxWidth < 380
                                              ? 1.5
                                              : 1.62,
                                      children: [
                                        _StatCard(
                                          background: const Color(0xFFFFE7CC),
                                          tint: const Color(0xFFF49B1A),
                                          icon: Icons.warning_amber_rounded,
                                          label: tr('স্বল্প মজুদ', 'Low Stock'),
                                          value:
                                              '${_bengaliNumber(dashboardLowStockCount)} ${tr('টি', 'items')}',
                                          onTap: () {
                                            if (!flow.can(
                                              DokanPermission.stockAdjust,
                                            )) {
                                              return;
                                            }
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const DokanLowStockAlertListScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                        _StatCard(
                                          background: const Color(0xFFFCE7E8),
                                          tint: const Color(0xFFB11E24),
                                          icon: Icons.menu_book_rounded,
                                          label: tr(
                                              'গ্রাহকের বকেয়া', 'Customer Due'),
                                          value:
                                              '৳ ${_bengaliNumber(customerDueTotal)}',
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DokanProfitLossReportScreen(),
                                            ),
                                          ),
                                        ),
                                        _StatCard(
                                          background: const Color(0xFFE7F0FF),
                                          tint: const Color(0xFF1F63E0),
                                          icon: Icons.shopping_cart_outlined,
                                          label: tr(
                                              'আজকের ক্রয়', "Today's Purchase"),
                                          value:
                                              '৳ ${_bengaliNumber(dashboardPurchases)}',
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DokanPurchaseListScreen(),
                                            ),
                                          ),
                                        ),
                                        _StatCard(
                                          background: const Color(0xFFE2F3E8),
                                          tint: const Color(0xFF0E7B58),
                                          icon: Icons.inventory_2_outlined,
                                          label:
                                              tr('মোট পণ্য', 'Total Products'),
                                          value:
                                              '${_bengaliNumber(dashboardProductCount)} ${tr('টি', 'items')}',
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DokanProductListScreen(),
                                            ),
                                          ),
                                        ),
                                        _StatCard(
                                          background: const Color(0xFFEDE9FF),
                                          tint: const Color(0xFF6B46C1),
                                          icon: Icons.local_shipping_outlined,
                                          label: tr('সরবরাহকারীর বকেয়া',
                                              'Supplier Due'),
                                          value:
                                              '৳ ${_bengaliNumber(dashboardSupplierDue)}',
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DokanNewSupplierAddScreen(),
                                            ),
                                          ),
                                        ),
                                        _StatCard(
                                          background: const Color(0xFFFFF1F2),
                                          tint: const Color(0xFFE11D48),
                                          icon: Icons.receipt_long_rounded,
                                          label: tr(
                                              'আজকের খরচ', "Today's Expense"),
                                          value:
                                              '৳ ${_bengaliNumber(dashboardExpenses)}',
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DokanExpenseEntryScreen(),
                                            ),
                                          ),
                                        ),
                                        _StatCard(
                                          background: const Color(0xFFE6FFFA),
                                          tint: const Color(0xFF0D9488),
                                          icon: Icons.badge_outlined,
                                          label: tr(
                                              'কর্মচারী বিক্রয়', "Employee Sales"),
                                          value:
                                              '৳ ${_bengaliNumber(todaySalesmanSalesTotal)}',
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DokanSalesmanTransactionsScreen(),
                                            ),
                                          ),
                                        ),
                                        _StatCard(
                                          background: const Color(0xFFF0FDF4),
                                          tint: const Color(0xFF15803D),
                                          icon: Icons.group_outlined,
                                          label: tr(
                                              'মোট কাস্টমার', 'Total Customers'),
                                          value:
                                              '${_bengaliNumber(supplierState.customerProfiles.length)} ${tr('জন', 'people')}',
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DokanCustomerListScreen(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          tr('সাম্প্রতিক পণ্য',
                                              'Recent Products'),
                                          style: const TextStyle(
                                            color: Color(0xFF1D2624),
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context)
                                              .pushNamed(AppRoutes.sales),
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFF0E7B58),
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            tr('সব দেখুন', 'View All'),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 116,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: recentProducts.length,
                                        separatorBuilder: (context, _) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (context, index) {
                                          final product = recentProducts[index];
                                          return _ProductCard(
                                            title: product.name,
                                            price:
                                                '৳${_bengaliNumber(product.salePrice)}',
                                            imageUrl: product.imageLabel,
                                            emoji: product.emoji,
                                            icon: product.emoji == '📦'
                                                ? Icons.inventory_2_rounded
                                                : Icons.shopping_bag_outlined,
                                            colors: const [
                                              Color(0xFFF4F1E7),
                                              Color(0xFFE7DDD0),
                                            ],
                                            onTap: () => Navigator.of(context)
                                                .pushNamed(AppRoutes.sales),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _AnalysisCard(
                                      title: tr(
                                          'বিক্রয় বিশ্লেষণ', 'Sales Analysis'),
                                      subtitle: _translateComparisonLabel(
                                          salesComparisonLabel),
                                      onTap: () => Navigator.of(context)
                                          .pushNamed(AppRoutes.sales),
                                    ),
                                    const SizedBox(height: 6),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: _MicFab(
                                        onTap: () {
                                          final flow =
                                              ref.read(dokanAppFlowProvider);
                                          if (!FeatureAccessControl.can(
                                            flow.currentRole,
                                            DokanFeature.voiceAssist,
                                          )) {
                                            ScaffoldMessenger.of(context)
                                              ..clearSnackBars()
                                              ..showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                    16,
                                                    0,
                                                    16,
                                                    16,
                                                  ),
                                                  duration: const Duration(
                                                      seconds: 2),
                                                  backgroundColor:
                                                      const Color(0xFF0C8C67),
                                                  content: Text(
                                                    tr('ফিচার শিগগিরই আসছে',
                                                        'Feature coming soon'),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            return;
                                          }
                                          ScaffoldMessenger.of(context)
                                            ..clearSnackBars()
                                            ..showSnackBar(
                                              SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                  16,
                                                  0,
                                                  16,
                                                  16,
                                                ),
                                                duration:
                                                    const Duration(seconds: 2),
                                                backgroundColor:
                                                    const Color(0xFF0C8C67),
                                                content: Text(
                                                  tr('ফিচার শিগগিরই আসছে',
                                                      'Feature coming soon'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height:
                          footerHeight + MediaQuery.of(context).padding.bottom,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                            top: BorderSide(color: AppColors.bottomNavBorder)),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        12,
                        0,
                        12,
                        MediaQuery.of(context).padding.bottom,
                      ),
                      child: Row(
                        children: [
                          _BottomNavItem(
                            icon: Icons.home_rounded,
                            label: AppStrings.tabHome,
                            selected: true,
                            onTap: () {},
                          ),
                          _BottomNavItem(
                            icon: Icons.calculate_rounded,
                            label: AppStrings.tabSales,
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.sales),
                          ),
                          _BottomNavItem(
                            icon: Icons.inventory_2_rounded,
                            label: AppStrings.tabProducts,
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.products),
                          ),
                          _BottomNavItem(
                            icon: Icons.bar_chart_rounded,
                            label: AppStrings.tabReports,
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.reports),
                          ),
                          _BottomNavItem(
                            icon: Icons.more_horiz_rounded,
                            label: AppStrings.tabMore,
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.settings),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  int _calculateTotalCustomerDue(DokanPosState state, List<DokanPosOrderRecord> orders) {
    final grouped = <String, List<DokanPosOrderRecord>>{};
    for (final order in orders) {
      final phone = order.customerNumber.trim();
      String key;
      if (phone.isNotEmpty) {
        key = phone;
      } else {
        final nameLower = order.customerName.trim().toLowerCase();
        if (nameLower == 'guest customer' ||
            nameLower == 'হাঁটা বিক্রয়' ||
            nameLower == 'অতিথি গ্রাহক' ||
            nameLower.isEmpty) {
          key = 'guest_customer_unified_key';
        } else {
          key = nameLower;
        }
      }
      if (state.hiddenCustomerKeys.contains(key)) {
        continue;
      }
      grouped.putIfAbsent(key, () => <DokanPosOrderRecord>[]).add(order);
    }

    final profilesByKey = <String, DokanCustomerProfileRecord>{
      for (final profile in state.customerProfiles) profile.key: profile,
    };

    final allKeys = <String>{...grouped.keys, ...profilesByKey.keys}
        .where((key) => !state.hiddenCustomerKeys.contains(key))
        .toList(growable: false);

    int total = 0;
    for (final key in allKeys) {
      final profile = profilesByKey[key];
      final purchaseOrders = grouped[key] ?? const <DokanPosOrderRecord>[];
      final openingDue = profile?.openingDue ?? 0;
      final localOrderDue = purchaseOrders.fold<int>(0, (sum, order) => sum + order.dueAmount);
      final hasProfileFinance = profile != null &&
          (profile.totalSales > 0 ||
              profile.totalPaid > 0 ||
              profile.currentDue > 0 ||
              profile.openingDue > 0);
      final totalDue = hasProfileFinance ? profile.currentDue : (localOrderDue + openingDue);
      total += totalDue;
    }
    return total;
  }
}

String _translateComparisonLabel(String label) {
  if (AppStrings.activeLanguage == AppLanguage.english) {
    if (label == 'গত ৭ দিনের তুলনায় ১৫% বৃদ্ধি') {
      return '15% increase compared to last 7 days';
    }
    String result = label;
    const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(banglaDigits[i], englishDigits[i]);
    }
    final regExp = RegExp(r'(\d+(?:\.\d+)?\s*%)');
    final match = regExp.firstMatch(result);
    if (match != null) {
      final percentage = match.group(0)!;
      final isIncrease = result.contains('বৃদ্ধি');
      final isDecrease = result.contains('হ্রাস');
      final trend = isIncrease ? 'increase' : (isDecrease ? 'decrease' : '');
      final daysMatch = RegExp(r'(\d+)\s*দিন').firstMatch(result);
      final days = daysMatch != null ? '${daysMatch.group(1)} days' : '7 days';
      return '$percentage $trend compared to last $days';
    }
    return result
        .replaceAll('গত ৭ দিনের তুলনায়', 'Compared to last 7 days')
        .replaceAll('বৃদ্ধি', 'increase')
        .replaceAll('হ্রাস', 'decrease');
  }
  return label;
}
