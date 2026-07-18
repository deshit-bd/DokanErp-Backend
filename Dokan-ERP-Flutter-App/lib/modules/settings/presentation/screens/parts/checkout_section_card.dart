part of '../settings_screens.dart';

class _CheckoutSectionCard extends StatelessWidget {
  const _CheckoutSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3EBE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B21413C),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF16302E),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _CheckoutPlanCard extends StatelessWidget {
  const _CheckoutPlanCard({required this.plan});

  final _SubscriptionPlanData plan;

  @override
  Widget build(BuildContext context) {
    final premium = plan.name.contains('প্রিমিয়াম');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: premium
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A6CF7), Color(0xFF2346C7)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0E8F5F), Color(0xFF0A7A52)],
              ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(plan.icon, color: Colors.white, size: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.price,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 13,
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

class _PaymentMethodChoice extends StatelessWidget {
  const _PaymentMethodChoice({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? const Color(0xFF0E8F5F) : const Color(0xFFE3EBE8);
    final backgroundColor = selected ? const Color(0xFFEAF5F1) : Colors.white;
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: selected ? 1.4 : 1),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: selected
                      ? const Color(0xFF0E8F5F)
                      : const Color(0xFF6F8280)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF16302E),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? const Color(0xFF0E8F5F)
                    : const Color(0xFFB3BFBC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({
    required this.label,
    required this.controller,
    required this.errorText,
    required this.hintText,
    required this.onChanged,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final String? errorText;
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF16302E),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF99A8A5)),
            filled: true,
            fillColor: Colors.white,
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE3EBE8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE3EBE8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF0E8F5F), width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE15241)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFE15241), width: 1.4),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          ),
          style: const TextStyle(
            color: Color(0xFF16302E),
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SubscriptionPlanData {
  const _SubscriptionPlanData({
    required this.name,
    required this.price,
    required this.priceSuffix,
    required this.monthlyPrice,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.current,
    required this.popular,
    required this.upgradeLabel,
    required this.features,
  });

  final String name;
  final String price;
  final String priceSuffix;
  final int monthlyPrice;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final bool current;
  final bool popular;
  final String upgradeLabel;
  final List<String> features;
}

class _SubscriptionHistoryData {
  const _SubscriptionHistoryData({
    required this.planName,
    required this.amount,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.icon,
  });

  final String planName;
  final String amount;
  final String date;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final IconData icon;
}

class DokanShopSettingsScreen extends ConsumerStatefulWidget {
  const DokanShopSettingsScreen({super.key});

  @override
  ConsumerState<DokanShopSettingsScreen> createState() =>
      _DokanShopSettingsScreenState();
}

class _DokanShopSettingsScreenState
    extends ConsumerState<DokanShopSettingsScreen> {
  bool _receiptShopName = true;
  bool _receiptMobile = true;
  bool _receiptAddress = true;
  bool _receiptLogo = false;
  String _language = 'বাংলা';
  String _theme = 'লাইট মোড';
  String _currency = '৳ বাংলাদেশি টাকা';

  bool _initialized = false;

  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _text = Color(0xFF16302E);
  static const Color _muted = Color(0xFF6F8280);
  static const Color _border = Color(0xFFE3EBE8);
  static const Color _accent = Color(0xFF0E8F5F);

  Future<void> _updateSetting({
    bool? receiptShopName,
    bool? receiptMobile,
    bool? receiptAddress,
    bool? receiptLogo,
  }) async {
    setState(() {
      if (receiptShopName != null) _receiptShopName = receiptShopName;
      if (receiptMobile != null) _receiptMobile = receiptMobile;
      if (receiptAddress != null) _receiptAddress = receiptAddress;
      if (receiptLogo != null) _receiptLogo = receiptLogo;
    });

    final currentDetails = ref.read(storeDetailsProvider).valueOrNull;
    if (currentDetails != null) {
      final updatedDetails = currentDetails.copyWith(
        receiptShowName: receiptShopName ?? _receiptShopName,
        receiptShowPhone: receiptMobile ?? _receiptMobile,
        receiptShowAddress: receiptAddress ?? _receiptAddress,
        receiptShowLogo: receiptLogo ?? _receiptLogo,
      );
      try {
        await ref
            .read(businessSettingsRepositoryProvider)
            .saveStoreDetails(updatedDetails);
        ref.invalidate(storeDetailsProvider);
      } catch (e) {
        _showInfoSnack(context, 'সেটিংস সেভ করতে সমস্যা হয়েছে: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeDetailsAsync = ref.watch(storeDetailsProvider);

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
        title: const Text(
          'দোকানের তথ্য',
          style: TextStyle(
            color: _text,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: storeDetailsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: _accent),
          ),
          error: (err, stack) => Center(
            child: Text('লোডিং ব্যর্থ হয়েছে: $err'),
          ),
          data: (details) {
            if (!_initialized) {
              _receiptShopName = details.receiptShowName;
              _receiptMobile = details.receiptShowPhone;
              _receiptAddress = details.receiptShowAddress;
              _receiptLogo = details.receiptShowLogo;
              _initialized = true;
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth =
                    constraints.maxWidth > 760 ? 760.0 : constraints.maxWidth;
                final bottomPadding =
                    MediaQuery.viewInsetsOf(context).bottom + 24;
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                                  child: _StoreInfoSummaryCard(
                                    borderColor: _border,
                                    accent: _accent,
                                    textColor: _text,
                                    mutedColor: _muted,
                                    storeName: details.storeName,
                                    storeType: details.storeType,
                                    logoUrl: details.logoUrl,
                                    onViewDetails: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              const DokanStoreDetailsScreen(),
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
                                ),
                                const SizedBox(height: 14),
                                DokanFadeSlideIn(
                                  delay: const Duration(milliseconds: 70),
                                  duration: const Duration(milliseconds: 500),
                                  slideOffset: const Offset(0, 15),
                                  child: _StoreSettingsCard(
                                    title: 'রিসিট সেটিংস',
                                    child: Column(
                                      children: [
                                        _StoreToggleTile(
                                          label: 'রিসিটে দোকানের নাম',
                                          value: _receiptShopName,
                                          onChanged: (value) => _updateSetting(
                                              receiptShopName: value),
                                        ),
                                        _StoreToggleTile(
                                          label: 'রিসিটে মোবাইল নম্বর',
                                          value: _receiptMobile,
                                          onChanged: (value) => _updateSetting(
                                              receiptMobile: value),
                                        ),
                                        _StoreToggleTile(
                                          label: 'রিসিটে ঠিকানা',
                                          value: _receiptAddress,
                                          onChanged: (value) => _updateSetting(
                                              receiptAddress: value),
                                        ),
                                        _StoreToggleTile(
                                          label: 'রিসিটে লোগো',
                                          value: _receiptLogo,
                                          onChanged: (value) =>
                                              _updateSetting(receiptLogo: value),
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
                                    title: 'অ্যাপ সেটিংস',
                                    child: Column(
                                      children: [
                                        _SelectableStoreInfoRow(
                                          label: 'ভাষা',
                                          value: _language,
                                          icon: Icons.language_rounded,
                                          onTap: () => _showOptionSheet(
                                            context: context,
                                            title: 'ভাষা নির্বাচন করুন',
                                            options: const ['বাংলা', 'English'],
                                            selected: _language,
                                            onSelected: (value) =>
                                                setState(() => _language = value),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        _SelectableStoreInfoRow(
                                          label: 'থিম',
                                          value: _theme,
                                          icon: Icons.light_mode_rounded,
                                          onTap: () => _showOptionSheet(
                                            context: context,
                                            title: 'থিম নির্বাচন করুন',
                                            options: const [
                                              'লাইট মোড',
                                              'ডার্ক মোড'
                                            ],
                                            selected: _theme,
                                            onSelected: (value) =>
                                                setState(() => _theme = value),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        _SelectableStoreInfoRow(
                                          label: 'কারেন্সি',
                                          value: _currency,
                                          icon: Icons.payments_rounded,
                                          onTap: () => _showOptionSheet(
                                            context: context,
                                            title: 'কারেন্সি নির্বাচন করুন',
                                            options: const [
                                              '৳ বাংলাদেশি টাকা',
                                              '\$ মার্কিন ডলার'
                                            ],
                                            selected: _currency,
                                            onSelected: (value) =>
                                                setState(() => _currency = value),
                                          ),
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
                                  child: _StoreSettingsCard(
                                    title: 'ডেটা ম্যানেজমেন্ট',
                                    child: Column(
                                      children: [
                                        _StoreActionButton(
                                          label: 'ডেটা ব্যাকআপ করুন',
                                          icon: Icons.cloud_upload_outlined,
                                          onPressed: () => _showInfoSnack(context,
                                              'ডেটা ব্যাকআপ শুরু করা হয়েছে'),
                                        ),
                                        const SizedBox(height: 12),
                                        _StoreActionButton(
                                          label: 'ডেটা রিস্টোর করুন',
                                          icon: Icons.cloud_download_outlined,
                                          onPressed: () => _showInfoSnack(
                                              context, 'ডেটা রিস্টোর প্রস্তুত'),
                                          outlined: true,
                                        ),
                                      ],
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
            );
          },
        ),
      ),
    );
  }

  void _showInfoSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showOptionSheet({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
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
                        color: Color(0xFF16302E),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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
}
