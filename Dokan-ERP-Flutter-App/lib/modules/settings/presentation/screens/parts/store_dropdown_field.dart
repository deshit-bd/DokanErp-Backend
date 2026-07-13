part of '../settings_screens.dart';

class _StoreDropdownField extends StatelessWidget {
  const _StoreDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

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
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Color(0xFF16302E),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class DokanAroOptionScreen extends ConsumerWidget {
  const DokanAroOptionScreen({super.key});

  static const Color _accent = Color(0xFF0E8F5F);
  static const Color _primaryText = Color(0xFF16302E);
  static const Color _secondaryText = Color(0xFF71827F);
  static const Color _cardBorder = Color(0xFFE2EBE8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final storeDetailsAsync = ref.watch(storeDetailsProvider);
    final subscriptionInfoAsync = ref.watch(subscriptionInfoProvider);

    final storeDetails = storeDetailsAsync.valueOrNull;
    final subscriptionInfo = subscriptionInfoAsync.valueOrNull;

    final shopName = storeDetails?.storeName.trim().isNotEmpty == true
        ? storeDetails!.storeName.trim()
        : tr('দোকান', 'Shop');
    final ownerName = storeDetails?.ownerName.trim().isNotEmpty == true
        ? storeDetails!.ownerName.trim()
        : tr('মালিক', 'Owner');

    final String badgeText;
    if (subscriptionInfoAsync.isLoading || storeDetailsAsync.isLoading) {
      badgeText = tr('লোডিং...', 'Loading...');
    } else if (subscriptionInfo == null) {
      badgeText = tr('ফ্রি প্ল্যান', 'Free Plan');
    } else if (subscriptionInfo.tier == 'TRIAL') {
      badgeText = tr('ফ্রি ট্রায়াল', 'Free Trial');
    } else if (subscriptionInfo.tier == 'BLOCKED') {
      badgeText = tr('মেয়াদ শেষ', 'Expired');
    } else {
      badgeText = tr('পে-অ্যাজ-ইউ-গো', 'Pay-as-you-go');
    }

    final sections = <_MoreSection>[
      _MoreSection(
        title: tr('ব্যবসা পরিচালনা', 'Business Management'),
        items: [
          _MoreItem(
            icon: Icons.person_outline_rounded,
            iconBackground: const Color(0xFFE5F4EF),
            iconColor: _accent,
            title: tr('গ্রাহক', 'Customers'),
            subtitle: tr('গ্রাহকের তথ্য ও বাকি', 'Customer info & dues'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const DokanCustomerListScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.local_shipping_outlined,
            iconBackground: const Color(0xFFFFF4E5),
            iconColor: const Color(0xFFDF8B1D),
            title: tr('সরবরাহকারী', 'Suppliers'),
            subtitle: tr('সরবরাহকারীর তথ্য', 'Supplier info'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const DokanSupplierListScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.shopping_bag_outlined,
            iconBackground: const Color(0xFFF2EDFF),
            iconColor: const Color(0xFF7B4DF2),
            title: tr('ক্রয়', 'Purchases'),
            subtitle: tr('ক্রয় পরিচালনা ও রিসিভ', 'Purchase orders & receipts'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const DokanPurchaseListScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.badge_outlined,
            iconBackground: const Color(0xFFEAF0FF),
            iconColor: const Color(0xFF4A6CF7),
            title: tr('কর্মচারী', 'Staff'),
            subtitle: tr('স্টাফ পরিচালনা', 'Staff management'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DokanStaffListScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.payments_outlined,
            iconBackground: const Color(0xFFFDECEC),
            iconColor: const Color(0xFFE15241),
            title: tr('খরচ', 'Expenses'),
            subtitle: tr('দৈনিক খরচ', 'Daily expenses'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const DokanExpenseReportScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.account_balance_wallet_outlined,
            iconBackground: const Color(0xFFEAF5F1),
            iconColor: _accent,
            title: tr('হিসাব', 'Accounts'),
            subtitle: tr('আয়-ব্যয়ের হিসাব', 'Income & expense reports'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DokanReportsHomeScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.bar_chart_outlined,
            iconBackground: const Color(0xFFF2EDFF),
            iconColor: const Color(0xFF7B4DF2),
            title: tr('রিপোর্ট', 'Reports'),
            subtitle: tr('লাভ-ক্ষতির রিপোর্ট', 'Profit & loss reports'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const DokanStockValueReportScreen()),
            ),
          ),
        ],
      ),
      _MoreSection(
        title: tr('বিক্রয়', 'Sales'),
        items: [
          _MoreItem(
            icon: Icons.history_rounded,
            iconBackground: const Color(0xFFEAF0FF),
            iconColor: const Color(0xFF4A6CF7),
            title: tr('বিক্রয় ইতিহাস', 'Sales History'),
            subtitle: tr('পুরোনো বিক্রয় তালিকা ও স্ট্যাটাস দেখুন',
                'View past sales and status'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DokanPosSalesHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      _MoreSection(
        title: tr('সাবস্ক্রিপশন', 'Subscription'),
        items: [
          _MoreItem(
            icon: Icons.workspace_premium_outlined,
            iconBackground: const Color(0xFFEAF5F1),
            iconColor: _accent,
            title: tr('প্ল্যান ও পেমেন্ট', 'Plan & Payment'),
            subtitle:
                tr('সাবস্ক্রিপশন প্ল্যান দেখুন', 'View subscription plan'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const DokanNotificationSubscriptionSettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      _MoreSection(
        title: tr('দোকান', 'Shop'),
        items: [
          _MoreItem(
            icon: Icons.storefront_outlined,
            iconBackground: const Color(0xFFEAF5F1),
            iconColor: _accent,
            title: tr('দোকানের তথ্য', 'Shop Information'),
            subtitle: tr('দোকানের প্রোফাইল দেখুন', 'View shop profile'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const DokanShopSettingsScreen()),
            ),
          ),
        ],
      ),
      _MoreSection(
        title: tr('নোটিফিকেশন', 'Notifications'),
        items: [
          _MoreItem(
            icon: Icons.notifications_none_rounded,
            iconBackground: const Color(0xFFFFF4E5),
            iconColor: const Color(0xFFDF8B1D),
            title: tr('নোটিফিকেশন সেটিংস', 'Notification Settings'),
            subtitle:
                tr('সতর্কবার্তা নিয়ন্ত্রণ করুন', 'Control alert messages'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DokanNotificationCenterScreen(),
              ),
            ),
          ),
        ],
      ),
      _MoreSection(
        title: tr('অ্যাপ সেটিংস', 'App Settings'),
        items: [
          _MoreItem(
            icon: Icons.tune_rounded,
            iconBackground: const Color(0xFFEAF5F1),
            iconColor: _accent,
            title: tr('অ্যাপ কনফিগারেশন', 'App Configuration'),
            subtitle: tr(
                'অ্যাপের সেটআপ কাস্টমাইজ করুন', 'Customize app configuration'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const DokanAppConfigurationScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.mic_none_rounded,
            iconBackground: const Color(0xFFF2EDFF),
            iconColor: const Color(0xFF7B4DF2),
            title: tr('ভয়েস প্রতিশব্দ (Synonyms)', 'Voice Synonyms'),
            subtitle: tr('ভয়েস কমান্ডের জন্য কাস্টম প্রতিশব্দ সেট করুন',
                'Set custom voice command synonyms'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DokanVoiceSynonymsScreen(),
              ),
            ),
          ),
          _MoreItem(
            icon: Icons.warning_amber_rounded,
            iconBackground: const Color(0xFFFFF4E5),
            iconColor: const Color(0xFFDF8B1D),
            title: tr('স্বল্প মজুদ সীমা', 'Low Stock Limit'),
            subtitle: tr('কম স্টক সতর্কতার সীমা নির্ধারণ করুন',
                'Set low stock warning thresholds'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DokanThresholdSettingScreen(),
              ),
            ),
          ),
        ],
      ),
      _MoreSection(
        title: tr('সাহায্য', 'Help & Support'),
        items: [
          _MoreItem(
            icon: Icons.help_outline_rounded,
            iconBackground: const Color(0xFFEAF0FF),
            iconColor: const Color(0xFF4A6CF7),
            title: tr('গাইড ও সাপোর্ট', 'Guide & Support'),
            subtitle: tr('সহায়তা ও ব্যবহার নির্দেশনা', 'Help and usage guide'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DokanHelpSupportScreen()),
            ),
          ),
        ],
      ),
      _MoreSection(
        title: tr('অ্যাকাউন্ট', 'Account'),
        items: [
          _MoreItem(
            icon: Icons.logout_rounded,
            iconBackground: const Color(0xFFFDECEC),
            iconColor: const Color(0xFFE15241),
            title: tr('লগ আউট', 'Log Out'),
            subtitle:
                tr('অ্যাকাউন্ট থেকে বের হয়ে যান', 'Log out of your account'),
            titleColor: const Color(0xFFE15241),
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    ];

    final isWide = MediaQuery.of(context).size.width >= 720;

    return DokanResponsivePage(
      selectedIndex: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('আরও অপশন', 'More Options'),
                          style: const TextStyle(
                            color: _primaryText,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr('দোকান, হিসাব, কর্মচারী ও সেটিংস এক জায়গায়',
                              'Shop, accounts, staff & settings in one place'),
                          style: const TextStyle(
                            color: _secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                children: [
                  _ProfileCard(
                    shopName: shopName,
                    ownerName: ownerName,
                    badgeText: badgeText,
                    accent: _accent,
                    onRefresh: () {
                      ref.invalidate(storeDetailsProvider);
                      ref.invalidate(subscriptionInfoProvider);
                    },
                  ),
                  const SizedBox(height: 18),
                  ...sections.map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _MoreSectionView(
                        title: section.title,
                        items: section.items,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : _MoreBottomNav(
              selectedIndex: 4,
              onHomeTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              onSalesTap: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.sales),
              onProductsTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DokanProductListScreen()),
              ),
              onReportsTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DokanReportsHomeScreen()),
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
              if (!context.mounted) {
                return;
              }
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
