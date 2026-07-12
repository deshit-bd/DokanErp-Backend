part of '../settings_screens.dart';

class DokanInventorySettingsScreen extends ConsumerStatefulWidget {
  const DokanInventorySettingsScreen({super.key});

  @override
  ConsumerState<DokanInventorySettingsScreen> createState() =>
      _DokanInventorySettingsScreenState();
}

class _DokanInventorySettingsScreenState
    extends ConsumerState<DokanInventorySettingsScreen> {
  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _text = Color(0xFF16302E);
  static const Color _muted = Color(0xFF6F8280);
  static const Color _accent = Color(0xFF0E8F5F);
  static const Color _border = Color(0xFFE3EBE8);
  static const Color _warning = Color(0xFFD9822B);

  late final TextEditingController _lowStockLimitCtrl;
  late final TextEditingController _criticalStockLimitCtrl;
  bool _autoLowStockAlert = true;

  bool _autoDeductOnSale = true;
  bool _allowNegativeStock = false;
  bool _binAssignmentRequired = true;
  bool _showBinOnSale = true;
  bool _trackExpiry = false;

  String _costingMethod = 'FIFO';

  @override
  void initState() {
    super.initState();
    _lowStockLimitCtrl = TextEditingController(text: '10');
    _criticalStockLimitCtrl = TextEditingController(text: '5');
    Future.microtask(() async {
      final settings = await ref.read(inventorySettingsProvider.future);
      if (!mounted) return;
      setState(() {
        _lowStockLimitCtrl.text = '${settings.lowStockLimit}';
        _criticalStockLimitCtrl.text = '${settings.criticalStockLimit}';
        _autoLowStockAlert = settings.autoLowStockAlert;
        _autoDeductOnSale = settings.autoDeductOnSale;
        _allowNegativeStock = settings.allowNegativeStock;
        _binAssignmentRequired = settings.binAssignmentRequired;
        _showBinOnSale = settings.showBinOnSale;
        _trackExpiry = settings.trackExpiry;
        _costingMethod = settings.costingMethod;
      });
    });
  }

  @override
  void dispose() {
    _lowStockLimitCtrl.dispose();
    _criticalStockLimitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final costingSummary = _costingMethod == 'FIFO'
        ? 'FIFO: পুরনো স্টক আগে বিক্রি হবে'
        : 'LIFO: নতুন স্টক আগে বিক্রি হবে';
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
              tr('ইনভেন্টরি সেটিংস', 'Inventory Settings'),
              style: const TextStyle(
                color: _text,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr('স্টক রুলস এবং থ্রেশহোল্ড সেট করুন',
                  'Set stock rules and thresholds'),
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
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionCard(
                          title:
                              tr('সতর্কতা ও থ্রেশহোল্ড', 'Alerts & Thresholds'),
                          icon: Icons.notifications_active_rounded,
                          subtitle: tr(
                              'লো-স্টক ও ক্রিটিক্যাল সীমা এক জায়গায় ঠিক করুন।',
                              'Manage low-stock and critical limits in one place.'),
                          children: [
                            _StoreTextField(
                              label: tr('কম স্টক সীমা', 'Low Stock Limit'),
                              controller: _lowStockLimitCtrl,
                              onChanged: (_) => setState(() {}),
                              keyboardType: TextInputType.number,
                              inputFormatters:
                                  NumericInputFormatters.wholeNumber,
                            ),
                            const SizedBox(height: 8),
                            _StoreTextField(
                              label:
                                  tr('জরুরি স্টক সীমা', 'Critical Stock Limit'),
                              controller: _criticalStockLimitCtrl,
                              onChanged: (_) => setState(() {}),
                              keyboardType: TextInputType.number,
                              inputFormatters:
                                  NumericInputFormatters.wholeNumber,
                            ),
                            const SizedBox(height: 8),
                            _buildSwitchTile(
                              label: tr('স্বয়ংক্রিয় কম স্টক সতর্কতা',
                                  'Automatic Low Stock Alert'),
                              description: tr('ড্যাশবোর্ডে সতর্কবার্তা দেখাবে',
                                  'Displays alerts on dashboard'),
                              value: _autoLowStockAlert,
                              onChanged: (v) =>
                                  setState(() => _autoLowStockAlert = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildSectionCard(
                          title: tr('স্টক আচরণ', 'Stock Behavior'),
                          icon: Icons.rule_rounded,
                          subtitle: tr(
                              'স্টক কমানো, নেগেটিভ ব্যালেন্স এবং লোকেশন ট্র্যাকিং নিয়ন্ত্রণ করুন।',
                              'Control stock deduction, negative balance, and location tracking.'),
                          children: [
                            _buildSwitchTile(
                              label: tr('বিক্রয়ে স্বয়ংক্রিয় স্টক কমানো',
                                  'Auto Deduct Stock on Sale'),
                              description: tr('বিক্রির সাথে সাথে স্টক কমবে',
                                  'Deducts stock automatically upon sale'),
                              value: _autoDeductOnSale,
                              onChanged: (v) =>
                                  setState(() => _autoDeductOnSale = v),
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              label: tr('নেগেটিভ স্টক অনুমোদন',
                                  'Allow Negative Stock'),
                              description: tr('স্টক শূন্যের নিচে যেতে দেবে',
                                  'Allows stock count to drop below zero'),
                              value: _allowNegativeStock,
                              onChanged: (v) =>
                                  setState(() => _allowNegativeStock = v),
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              label: tr('বিন অ্যাসাইনমেন্ট আবশ্যক',
                                  'Bin Assignment Required'),
                              description: tr('পণ্য যোগে বিন না দিলে সতর্কতা',
                                  'Warns if no bin is assigned on product creation'),
                              value: _binAssignmentRequired,
                              onChanged: (v) =>
                                  setState(() => _binAssignmentRequired = v),
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              label: tr('বিক্রয়ে বিন লোকেশন দেখান',
                                  'Show Bin Location on Sale'),
                              description: tr('কোথা থেকে নিতে হবে দেখাবে',
                                  'Shows where to retrieve product from'),
                              value: _showBinOnSale,
                              onChanged: (v) =>
                                  setState(() => _showBinOnSale = v),
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              label: tr(
                                  'মেয়াদ ট্র্যাক করুন', 'Track Expiry Date'),
                              description: tr(
                                  'পণ্যের মেয়াদ উত্তীর্ণের তারিখ রাখুন',
                                  'Keep product expiration dates'),
                              value: _trackExpiry,
                              onChanged: (v) =>
                                  setState(() => _trackExpiry = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildSectionCard(
                          title: tr('স্টক গণনা পদ্ধতি', 'Stock Costing Method'),
                          icon: Icons.calculate_rounded,
                          subtitle: tr(
                              'সেলস কস্ট বের করার জন্য FIFO বা LIFO বেছে নিন।',
                              'Select FIFO or LIFO to compute cost of goods sold.'),
                          children: [
                            _buildMethodBadge(),
                            const SizedBox(height: 12),
                            _buildRadioTile(
                              label: 'FIFO',
                              description:
                                  tr('আগে আসলে আগে যাবে', 'First In First Out'),
                              value: 'FIFO',
                            ),
                            _buildDivider(),
                            _buildRadioTile(
                              label: 'LIFO',
                              description:
                                  tr('পরে আসলে আগে যাবে', 'Last In First Out'),
                              value: 'LIFO',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildNoticeCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: _accent, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        costingSummary,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  label: Text(
                    tr('সংরক্ষণ করুন', 'Save Settings'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final lowStock = int.tryParse(_lowStockLimitCtrl.text.trim());
    final criticalStock = int.tryParse(_criticalStockLimitCtrl.text.trim());
    if (lowStock == null ||
        criticalStock == null ||
        lowStock < 0 ||
        criticalStock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(tr('সঠিক স্টক সীমা দিন', 'Please enter valid stock limits')),
          backgroundColor: const Color(0xFFE15241),
        ),
      );
      return;
    }
    await ref.read(businessSettingsRepositoryProvider).saveInventorySettings(
          InventorySettings(
            lowStockLimit: lowStock,
            criticalStockLimit: criticalStock,
            autoLowStockAlert: _autoLowStockAlert,
            autoDeductOnSale: _autoDeductOnSale,
            allowNegativeStock: _allowNegativeStock,
            binAssignmentRequired: _binAssignmentRequired,
            showBinOnSale: _showBinOnSale,
            trackExpiry: _trackExpiry,
            costingMethod: _costingMethod,
          ),
        );
    ref.invalidate(inventorySettingsProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(tr('সেটিংস সংরক্ষিত হয়েছে', 'Settings saved successfully')),
        backgroundColor: _accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.of(context).maybePop();
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0C21413C), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: _text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
              value: value, onChanged: onChanged, activeColor: _accent),
        ],
      ),
    );
  }

  Widget _buildRadioTile({
    required String label,
    required String description,
    required String value,
  }) {
    final selected = _costingMethod == value;
    return InkWell(
      onTap: () => setState(() => _costingMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _accent : const Color(0xFFB0BEC5),
                  width: selected ? 5.5 : 2,
                ),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? _accent : _text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(description,
                      style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String costingSummary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E8F5F), Color(0xFF0C7A52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x250E8F5F),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ব্যবসা-উপযোগী ইনভেন্টরি সেটআপ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'লো-স্টক সতর্কতা, স্টক আচরণ, এবং কস্টিং নিয়ম এক জায়গা থেকে নিয়ন্ত্রণ করুন।',
                      style: TextStyle(
                        color: Color(0xDDEBFFF8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildHeroChip('কম স্টক', _lowStockLimitCtrl.text.trim()),
              _buildHeroChip(
                  'ক্রিটিক্যাল', _criticalStockLimitCtrl.text.trim()),
              _buildHeroChip('মোড', _costingMethod),
              _buildHeroChip(
                'অটো ডিডাক্ট',
                _autoDeductOnSale ? 'চালু' : 'বন্ধ',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.swap_horiz_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    costingSummary,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label, String value) {
    final textValue = value.isEmpty ? '—' : value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xDDEBFFF8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            textValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatRow(List<Widget> children) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i != children.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required String hint,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: const TextStyle(
              color: _muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodBadge() {
    final isFifo = _costingMethod == 'FIFO';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFifo ? const Color(0xFFE9F8F2) : const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFifo ? const Color(0xFFB7E7D3) : const Color(0xFFC7D8F5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFifo ? Icons.schedule_rounded : Icons.history_rounded,
            color: isFifo ? _accent : const Color(0xFF3F6FD8),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isFifo
                  ? 'FIFO নির্বাচিত: পুরনো স্টক আগে কস্ট হিসেবে ধরা হবে।'
                  : 'LIFO নির্বাচিত: সর্বশেষ স্টক আগে কস্ট হিসেবে ধরা হবে।',
              style: const TextStyle(
                color: _text,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _warning.withOpacity(0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: _warning, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'পরিবর্তন সংরক্ষণ করলে বিদ্যমান স্টক ডেটা প্রভাবিত হতে পারে। সেভ করার আগে সেটিংস একবার মিলিয়ে নিন।',
              style: TextStyle(
                color: Color(0xFF7A4500),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFF0F4F3));
}

// ─── Data Store (module-level, shared across tabs) ────────────────────────────

final _unitCategoryData = _UnitCategoryStore();
