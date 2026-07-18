part of '../settings_screens.dart';

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.shopName,
    required this.ownerName,
    required this.badgeText,
    required this.accent,
    required this.onRefresh,
  });

  final String shopName;
  final String ownerName;
  final String badgeText;
  final Color accent;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent,
            const Color(0xFF0E7E57),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220B5B40),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Color(0xFF0E7E57),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shopName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('মালিক: $ownerName', 'Owner: $ownerName'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.86),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MiniActionButton(
                        icon: Icons.refresh_rounded,
                        onTap: onRefresh,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DokanAppConfigurationScreen extends ConsumerStatefulWidget {
  const DokanAppConfigurationScreen({super.key});

  @override
  ConsumerState<DokanAppConfigurationScreen> createState() =>
      _DokanAppConfigurationScreenState();
}

class _DokanAppConfigurationScreenState
    extends ConsumerState<DokanAppConfigurationScreen> {
  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _text = Color(0xFF16302E);
  static const Color _muted = Color(0xFF6F8280);
  static const Color _accent = Color(0xFF0E8F5F);

  static const _barcodeRequiredKey = 'dokan_barcode_required';
  static const _offlineCacheKey = 'dokan_offline_cache';
  static const _soundKey = 'dokan_sound';
  static const _vibrationKey = 'dokan_vibration';

  String _taxCharge = 'ভ্যাট ১৫%';
  String _generalSetting = 'বাংলা, কমপ্যাক্ট ভিউ';
  bool _lowStockAlert = true;
  bool _barcodeRequired = true;
  bool _offlineCache = true;
  bool _sound = true;
  bool _vibration = false;

  @override
  void initState() {
    super.initState();
    final lang = ref.read(languageProvider);
    _generalSetting = lang == AppLanguage.english
        ? 'English, Standard View'
        : 'বাংলা, কমপ্যাক্ট ভিউ';

    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      InventorySettings? settings;
      try {
        settings = await ref.read(inventorySettingsProvider.future);
      } catch (_) {}

      // Fetch active tax percent
      try {
        final client = ref.read(apiClientProvider);
        final response = await client.get('/app/api/shops/me/taxes-charges');
        final data = response.data;
        if (data is Map) {
          final taxesRaw = data['taxes'] as List? ?? [];
          double activeTaxPercent = 0.0;
          for (final t in taxesRaw) {
            final taxMap = Map<String, dynamic>.from(t);
            final isActive = taxMap['isActive'] as bool? ?? true;
            if (isActive) {
              final rawRate = taxMap['rate'];
              double rate = 0.0;
              if (rawRate != null) {
                if (rawRate is num) {
                  rate = rawRate.toDouble();
                } else if (rawRate is String) {
                  rate = double.tryParse(rawRate) ?? 0.0;
                }
              }
              activeTaxPercent += rate;
            }
          }
          if (mounted) {
            setState(() {
              _taxCharge = 'ভ্যাট ${activeTaxPercent.round()}%';
            });
          }
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        if (settings != null) {
          _lowStockAlert = settings.autoLowStockAlert;
        }
        _barcodeRequired = prefs.getBool(_barcodeRequiredKey) ?? true;
        _offlineCache = prefs.getBool(_offlineCacheKey) ?? true;
        _sound = prefs.getBool(_soundKey) ?? true;
        _vibration = prefs.getBool(_vibrationKey) ?? false;
      });
    });
  }

  Future<void> _updateLowStockAlert(bool value) async {
    setState(() => _lowStockAlert = value);
    try {
      final current = ref.read(inventorySettingsProvider).value ??
          const InventorySettings();
      final updated = InventorySettings(
        lowStockLimit: current.lowStockLimit,
        criticalStockLimit: current.criticalStockLimit,
        autoLowStockAlert: value,
        autoDeductOnSale: current.autoDeductOnSale,
        allowNegativeStock: current.allowNegativeStock,
        binAssignmentRequired: current.binAssignmentRequired,
        showBinOnSale: current.showBinOnSale,
        trackExpiry: current.trackExpiry,
        costingMethod: current.costingMethod,
      );
      await ref
          .read(businessSettingsRepositoryProvider)
          .saveInventorySettings(updated);
      ref.invalidate(inventorySettingsProvider);
    } catch (_) {}
  }

  Future<void> _updateBarcodeRequired(bool value) async {
    setState(() => _barcodeRequired = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_barcodeRequiredKey, value);
  }

  Future<void> _updateOfflineCache(bool value) async {
    setState(() => _offlineCache = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineCacheKey, value);
  }

  Future<void> _updateSound(bool value) async {
    setState(() => _sound = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  Future<void> _updateVibration(bool value) async {
    setState(() => _vibration = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: _bg,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _text,
            ),
          ),
        ),
        leadingWidth: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('অ্যাপ কনফিগারেশন', 'App Configuration'),
              style: const TextStyle(
                color: _text,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr('আপনার দোকান ও ইনভেন্টরি সম্পর্কিত সেটিংস পরিচালনা করুন',
                  'Manage your store and inventory settings'),
              style: const TextStyle(
                color: _muted,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth =
                constraints.maxWidth > 760 ? 760.0 : constraints.maxWidth;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DokanFadeSlideIn(
                              delay: const Duration(milliseconds: 30),
                              duration: const Duration(milliseconds: 500),
                              slideOffset: const Offset(0, 15),
                              child: _StoreSettingsCard(
                                title:
                                    tr('স্টোর ম্যানেজমেন্ট', 'Store Management'),
                                child: _StoreActionButton(
                                  label: tr(
                                      'স্টোর ম্যানেজমেন্ট', 'Store Management'),
                                  icon: Icons.warehouse_rounded,
                                  onPressed: () =>
                                      _showStoreManagementSheet(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            DokanFadeSlideIn(
                              delay: const Duration(milliseconds: 70),
                              duration: const Duration(milliseconds: 500),
                              slideOffset: const Offset(0, 15),
                              child: _StoreSettingsCard(
                                title: tr('ইনভেন্টরি ম্যানেজমেন্ট',
                                    'Inventory Management'),
                                child: Column(
                                  children: [
                                    _SelectableStoreInfoRow(
                                      label: tr('ইনভেন্টরি সেটিংস',
                                          'Inventory Settings'),
                                      value: tr('স্টক রুলস ও থ্রেশহোল্ড',
                                          'Stock Rules & Thresholds'),
                                      icon: Icons.inventory_2_rounded,
                                      onTap: () => Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              const DokanInventorySettingsScreen(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            const begin = Offset(0.0, 1.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _SelectableStoreInfoRow(
                                      label: tr('ইনভেন্টরি ব্যবস্থাপনা',
                                          'Inventory Management'),
                                      value: tr('ইউনিট ও ক্যাটাগরি',
                                          'Units & Categories'),
                                      icon: Icons.category_outlined,
                                      onTap: () => Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              const DokanUnitCategoryScreen(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            const begin = Offset(0.0, 1.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _SelectableStoreInfoRow(
                                      label:
                                          tr('ট্যাক্স ও চার্জ', 'Tax & Charges'),
                                      value: tr(_taxCharge, 'VAT 15%'),
                                      icon: Icons.receipt_long_rounded,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                const DokanTaxChargesManagementScreen(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              const begin = Offset(0.0, 1.0);
                                              const end = Offset.zero;
                                              const curve = Curves.easeInOut;
                                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                              return SlideTransition(
                                                position: animation.drive(tween),
                                                child: child,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            DokanFadeSlideIn(
                              delay: const Duration(milliseconds: 110),
                              duration: const Duration(milliseconds: 500),
                              slideOffset: const Offset(0, 15),
                              child: _StoreSettingsCard(
                                title: tr('অ্যাপ পছন্দসমূহ', 'App Preferences'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SelectableStoreInfoRow(
                                      label:
                                          tr('সাধারণ সেটিংস', 'General Settings'),
                                      value: _generalSetting,
                                      icon: Icons.settings_suggest_rounded,
                                      onTap: () => _showChoiceSheet(
                                        context: context,
                                        title: tr(
                                            'সাধারণ সেটিংস', 'General Settings'),
                                        description: tr(
                                            'অ্যাপের সাধারণ আচরণ ও উপস্থাপন নির্বাচন করুন।',
                                            'Select general app behavior and presentation.'),
                                        selected: _generalSetting,
                                        options: const [
                                          'বাংলা, কমপ্যাক্ট ভিউ',
                                          'বাংলা, স্ট্যান্ডার্ড ভিউ',
                                          'English, Standard View'
                                        ],
                                        onSelected: (value) {
                                          setState(() => _generalSetting = value);
                                          if (value.contains('English')) {
                                            ref
                                                .read(languageProvider.notifier)
                                                .setLanguage(AppLanguage.english);
                                          } else {
                                            ref
                                                .read(languageProvider.notifier)
                                                .setLanguage(AppLanguage.bangla);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      tr('ব্যবহারিক আচরণ', 'App Behavior'),
                                      style: const TextStyle(
                                        color: _muted,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _StoreToggleTile(
                                      label: tr(
                                          'লো-স্টক সতর্কতা', 'Low-Stock Alert'),
                                      value: _lowStockAlert,
                                      onChanged: _updateLowStockAlert,
                                    ),
                                    _StoreToggleTile(
                                      label: tr('বারকোড বাধ্যতামুলক',
                                          'Barcode Required'),
                                      value: ref
                                          .watch(appPreferencesProvider)
                                          .barcodeRequired,
                                      onChanged: (val) {
                                        ref
                                            .read(appPreferencesProvider.notifier)
                                            .setBarcodeRequired(val);
                                        ref
                                            .read(appPreferencesProvider.notifier)
                                            .triggerFeedback();
                                      },
                                    ),
                                    _StoreToggleTile(
                                      label: tr('অফলাইন ক্যাশ', 'Offline Cache'),
                                      value: ref
                                          .watch(appPreferencesProvider)
                                          .offlineCache,
                                      onChanged: (val) {
                                        ref
                                            .read(appPreferencesProvider.notifier)
                                            .setOfflineCache(val);
                                        ref
                                            .read(appPreferencesProvider.notifier)
                                            .triggerFeedback();
                                      },
                                    ),
                                    _StoreToggleTile(
                                      label: tr('সাউন্ড নোটিফিকেশন',
                                          'Sound Notification'),
                                      value: ref
                                          .watch(appPreferencesProvider)
                                          .soundEnabled,
                                      onChanged: (val) {
                                        ref
                                            .read(appPreferencesProvider.notifier)
                                            .setSoundEnabled(val);
                                        ref
                                            .read(appPreferencesProvider.notifier)
                                            .triggerFeedback();
                                      },
                                    ),
                                    _StoreToggleTile(
                                      label: tr('ভাইব্রেশন', 'Vibration'),
                                      value: ref
                                          .watch(appPreferencesProvider)
                                          .vibrationEnabled,
                                      onChanged: (val) {
                                        ref
                                            .read(appPreferencesProvider.notifier)
                                            .setVibrationEnabled(val);
                                        ref
                                            .read(appPreferencesProvider.notifier)
                                            .triggerFeedback();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            DokanFadeSlideIn(
                              delay: const Duration(milliseconds: 150),
                              duration: const Duration(milliseconds: 500),
                              slideOffset: const Offset(0, 15),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: const Color(0xFFE3EBE8)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0C21413C),
                                      blurRadius: 18,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAF5F1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.storefront_rounded,
                                        color: _accent,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'DokanERP',
                                            style: TextStyle(
                                              color: _text,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            tr('দোকান ব্যবসা ERP সিস্টেম',
                                                'Shop Business ERP System'),
                                            style: const TextStyle(
                                              color: _muted,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _AppConfigFooterChip(
                                                label: tr('ভার্সন 1.0.0',
                                                    'Version 1.0.0'),
                                                icon: Icons.verified_rounded,
                                              ),
                                              _AppConfigFooterChip(
                                                label: '© 2026 DokanERP',
                                                icon: Icons.copyright_rounded,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showChoiceSheet({
    required BuildContext context,
    required String title,
    required String description,
    required String selected,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SelectableOptionBox(
                          label: option,
                          selected: option == selected,
                          onTap: () {
                            onSelected(option);
                            Navigator.of(sheetContext).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStoreManagementSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DokanStoreLayoutManagementScreen(),
      ),
    );
  }
}
