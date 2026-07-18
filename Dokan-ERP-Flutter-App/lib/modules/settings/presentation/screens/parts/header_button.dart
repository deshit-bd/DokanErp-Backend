part of '../settings_screens.dart';

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: DokanAroOptionScreen._primaryText,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.18),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            icon,
            color: Colors.white,
            size: 17,
          ),
        ),
      ),
    );
  }
}

class _MoreBottomNav extends ConsumerWidget {
  const _MoreBottomNav({
    required this.selectedIndex,
    required this.onHomeTap,
    required this.onSalesTap,
    required this.onProductsTap,
    required this.onReportsTap,
  });

  final int selectedIndex;
  final VoidCallback onHomeTap;
  final VoidCallback onSalesTap;
  final VoidCallback onProductsTap;
  final VoidCallback onReportsTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          border: const Border(top: BorderSide(color: Color(0xFFE4ECEE))),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MoreNavItem(
              icon: Icons.home_rounded,
              label: AppStrings.tabHome,
              selected: selectedIndex == 0,
              onTap: onHomeTap,
            ),
            _MoreNavItem(
              icon: Icons.shopping_bag_rounded,
              label: AppStrings.tabSales,
              selected: selectedIndex == 1,
              onTap: onSalesTap,
            ),
            _MoreNavItem(
              icon: Icons.inventory_2_rounded,
              label: AppStrings.tabProducts,
              selected: selectedIndex == 2,
              onTap: onProductsTap,
            ),
            _MoreNavItem(
              icon: Icons.bar_chart_rounded,
              label: AppStrings.tabReports,
              selected: selectedIndex == 3,
              onTap: onReportsTap,
            ),
            _MoreNavItem(
              icon: Icons.more_horiz_rounded,
              label: AppStrings.tabMore,
              selected: selectedIndex == 4,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreNavItem extends StatelessWidget {
  const _MoreNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? DokanAroOptionScreen._accent : const Color(0xFF83929A);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreSection {
  const _MoreSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_MoreItem> items;
}

class _MoreItem {
  const _MoreItem({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
}

enum _TaxChargeValueType {
  percent,
  fixed;

  String get label {
    switch (this) {
      case _TaxChargeValueType.percent:
        return 'শতাংশ (%)';
      case _TaxChargeValueType.fixed:
        return 'নির্দিষ্ট (৳)';
    }
  }

  String format(double value) {
    final clean =
        value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
    switch (this) {
      case _TaxChargeValueType.percent:
        return '$clean%';
      case _TaxChargeValueType.fixed:
        return '৳$clean';
    }
  }
}

class _TaxChargeItem {
  const _TaxChargeItem({
    this.id,
    required this.name,
    required this.value,
    required this.type,
  });

  final String? id;
  final String name;
  final double value;
  final _TaxChargeValueType type;

  Map<String, dynamic> toJson(bool isTax) {
    return {
      'id': id,
      'name': name,
      if (isTax) 'rate': value else 'amount': value,
      'type': type == _TaxChargeValueType.percent ? 'PERCENTAGE' : 'FIXED',
    };
  }

  factory _TaxChargeItem.fromJson(Map<String, dynamic> json, bool isTax) {
    final name = json['name'] as String? ?? '';
    final rawVal = isTax ? json['rate'] : json['amount'];
    double val = 0.0;
    if (rawVal != null) {
      if (rawVal is num) {
        val = rawVal.toDouble();
      } else if (rawVal is String) {
        val = double.tryParse(rawVal) ?? 0.0;
      }
    }
    final typeStr = json['type'] as String? ?? '';
    final type = (typeStr == 'PERCENTAGE' || typeStr == 'PERCENT')
        ? _TaxChargeValueType.percent
        : _TaxChargeValueType.fixed;
    return _TaxChargeItem(
      id: json['id'] as String?,
      name: name,
      value: val,
      type: type,
    );
  }
}

class DokanTaxChargesManagementScreen extends ConsumerStatefulWidget {
  const DokanTaxChargesManagementScreen({super.key});

  @override
  ConsumerState<DokanTaxChargesManagementScreen> createState() =>
      _DokanTaxChargesManagementScreenState();
}

class _DokanTaxChargesManagementScreenState
    extends ConsumerState<DokanTaxChargesManagementScreen> {
  final List<_TaxChargeItem> _taxes = [];
  final List<_TaxChargeItem> _charges = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedAndFetch();
  }

  Future<void> _loadCachedAndFetch() async {
    final cached = await TaxesChargesLocalCache.get();
    if (cached != null && mounted) {
      final taxesRaw = cached['taxes'] as List? ?? [];
      final chargesRaw = cached['charges'] as List? ?? [];
      setState(() {
        _taxes.clear();
        _taxes.addAll(taxesRaw.map((e) =>
            _TaxChargeItem.fromJson(Map<String, dynamic>.from(e), true)));
        _charges.clear();
        _charges.addAll(chargesRaw.map((e) =>
            _TaxChargeItem.fromJson(Map<String, dynamic>.from(e), false)));
        _loading = false;
      });
    }
    await _fetchTaxesAndCharges(showSpinner: cached == null);
  }

  Future<void> _updateCache() async {
    try {
      final cacheData = {
        'taxes': _taxes.map((e) => e.toJson(true)).toList(),
        'charges': _charges.map((e) => e.toJson(false)).toList(),
      };
      await TaxesChargesLocalCache.save(cacheData);
    } catch (_) {}
  }

  Future<void> _fetchTaxesAndCharges({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() => _loading = true);
    }
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/app/api/shops/me/taxes-charges');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        await TaxesChargesLocalCache.save(data);
        final taxesRaw = data['taxes'] as List? ?? [];
        final chargesRaw = data['charges'] as List? ?? [];

        if (mounted) {
          setState(() {
            _taxes.clear();
            _taxes.addAll(taxesRaw.map((e) =>
                _TaxChargeItem.fromJson(Map<String, dynamic>.from(e), true)));
            _charges.clear();
            _charges.addAll(chargesRaw.map((e) =>
                _TaxChargeItem.fromJson(Map<String, dynamic>.from(e), false)));
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        if (showSpinner) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('লোড করতে ব্যর্থ হয়েছে: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        ),
        title: const Text(
          'Tax & Charges Management',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0E8F5F)))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _section('কর (Tax)', _taxes, true),
                  const SizedBox(height: 28),
                  _section('অতিরিক্ত চার্জ', _charges, false),
                ],
              ),
      ),
    );
  }

  Widget _section(String title, List<_TaxChargeItem> items, bool isTax) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DokanFadeSlideIn(
          delay: const Duration(milliseconds: 30),
          duration: const Duration(milliseconds: 400),
          slideOffset: const Offset(0, 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
              ),
              FilledButton(
                onPressed: () => _openSheet(isTax: isTax),
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.black, foregroundColor: Colors.white),
                child: const Text('যোগ করুন'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(items.length, (index) {
          final item = items[index];
          return DokanFadeSlideIn(
            delay: Duration(milliseconds: 70 + index * 30),
            duration: const Duration(milliseconds: 450),
            slideOffset: const Offset(0, 12),
            child: Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(item.name,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.type.format(item.value),
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w800)),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.black,
                      ),
                      color: Colors.white,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openSheet(isTax: isTax, index: index);
                        }
                        if (value == 'delete') {
                          _deleteItem(isTax: isTax, index: index);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'Edit',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _deleteItem({required bool isTax, required int index}) async {
    final list = isTax ? _taxes : _charges;
    final item = list[index];
    if (item.id == null) return;

    try {
      final client = ref.read(apiClientProvider);
      final url = isTax
          ? '/app/api/shops/me/taxes/${item.id}'
          : '/app/api/shops/me/charges/${item.id}';
      await client.delete(url);
      if (mounted) {
        setState(() {
          list.removeAt(index);
        });
        await _updateCache();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সফলভাবে মুছে ফেলা হয়েছে')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('মুছে ফেলতে সমস্যা হয়েছে: $e')),
        );
      }
    }
  }

  Future<void> _openSheet({required bool isTax, int? index}) async {
    final list = isTax ? _taxes : _charges;
    final old = index == null ? null : list[index];

    final result = await showModalBottomSheet<_TaxChargeItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => _TaxChargeSheet(
        isTax: isTax,
        oldItem: old,
        existingNames: list
            .asMap()
            .entries
            .where((e) => e.key != index)
            .map((e) => e.value.name.trim().toLowerCase())
            .toSet(),
      ),
    );

    if (result == null) return;

    try {
      final client = ref.read(apiClientProvider);
      if (index == null) {
        // Create new
        if (isTax) {
          final response = await client.post('/app/api/shops/me/taxes', body: {
            'name': result.name,
            'rate': result.value,
            'type': result.type == _TaxChargeValueType.percent
                ? 'PERCENTAGE'
                : 'FIXED',
          });
          if (mounted) {
            setState(() {
              _taxes.add(_TaxChargeItem.fromJson(response.data, true));
            });
            await _updateCache();
          }
        } else {
          final response =
              await client.post('/app/api/shops/me/charges', body: {
            'name': result.name,
            'amount': result.value,
            'type': result.type == _TaxChargeValueType.percent
                ? 'PERCENTAGE'
                : 'FIXED',
          });
          if (mounted) {
            setState(() {
              _charges.add(_TaxChargeItem.fromJson(response.data, false));
            });
            await _updateCache();
          }
        }
      } else {
        // Update existing
        final oldId = old?.id;
        if (oldId == null) return;

        if (isTax) {
          await client.patch('/app/api/shops/me/taxes/$oldId', body: {
            'name': result.name,
            'rate': result.value,
            'type': result.type == _TaxChargeValueType.percent
                ? 'PERCENTAGE'
                : 'FIXED',
          });
          if (mounted) {
            setState(() {
              _taxes[index] = _TaxChargeItem(
                id: oldId,
                name: result.name,
                value: result.value,
                type: result.type,
              );
            });
            await _updateCache();
          }
        } else {
          await client.patch('/app/api/shops/me/charges/$oldId', body: {
            'name': result.name,
            'amount': result.value,
            'type': result.type == _TaxChargeValueType.percent
                ? 'PERCENTAGE'
                : 'FIXED',
          });
          if (mounted) {
            setState(() {
              _charges[index] = _TaxChargeItem(
                id: oldId,
                name: result.name,
                value: result.value,
                type: result.type,
              );
            });
            await _updateCache();
          }
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সফলভাবে সংরক্ষণ করা হয়েছে')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('সংরক্ষণ করতে সমস্যা হয়েছে: $e')),
        );
      }
    }
  }
}


class TaxesChargesLocalCache {
  static const _key = 'dokan_taxes_charges_cache';

  static Future<void> save(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(json));
  }

  static Future<Map<String, dynamic>?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str != null) {
      try {
        return jsonDecode(str) as Map<String, dynamic>?;
      } catch (_) {}
    }
    return null;
  }
}
