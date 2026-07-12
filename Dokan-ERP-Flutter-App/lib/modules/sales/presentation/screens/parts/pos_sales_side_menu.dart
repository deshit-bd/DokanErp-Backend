part of '../sales_screens.dart';

class _PosSalesSideMenu extends StatelessWidget {
  const _PosSalesSideMenu({
    required this.onClose,
    required this.onTapHistory,
    required this.onTapClosing,
  });

  final VoidCallback onClose;
  final VoidCallback onTapHistory;
  final VoidCallback onTapClosing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.82,
      height: MediaQuery.sizeOf(context).height,
      decoration: const BoxDecoration(
        color: Color(0xFFF7FBFA),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'বিক্রয় মেনু',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _SideMenuIconButton(
                  icon: Icons.close,
                  onTap: onClose,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'বিক্রয় সম্পর্কিত দ্রুত প্রবেশপথ',
              style: TextStyle(
                color: Color(0xFF5D6D67),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
              children: [
                _PosSideMenuTile(
                  icon: Icons.history,
                  title: 'বিক্রয় ইতিহাস',
                  subtitle: 'পূর্বের বিক্রয় তালিকা দেখুন',
                  onTap: onTapHistory,
                ),
                const SizedBox(height: 12),
                _PosSideMenuTile(
                  icon: Icons.event_available_outlined,
                  title: 'দৈনিক ক্লোজিং',
                  subtitle: 'আজকের বিক্রয় ও বন্ধের সারাংশ',
                  onTap: onTapClosing,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PosSideMenuTile extends StatelessWidget {
  const _PosSideMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD9E6E2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF006B53)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF5D6D67),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Color(0xFF7B8C86)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideMenuIconButton extends StatelessWidget {
  const _SideMenuIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F6F4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: const Color(0xFF006B53)),
        ),
      ),
    );
  }
}

class DokanPosSalesHistoryScreen extends ConsumerWidget {
  const DokanPosSalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _DokanSalesHistoryScreen();
  }
}

class DokanPosSalesDetailsScreen extends StatelessWidget {
  const DokanPosSalesDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DokanSalesHistoryScreen();
  }
}

class DokanPosDailyClosingScreen extends StatelessWidget {
  const DokanPosDailyClosingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DailyClosingScreen();
  }
}

class _DailyClosingScreen extends StatefulWidget {
  const _DailyClosingScreen();

  @override
  State<_DailyClosingScreen> createState() => _DailyClosingScreenState();
}

class _DailyClosingScreenState extends State<_DailyClosingScreen> {
  final TextEditingController _cashController =
      TextEditingController(text: '0.00');

  static const int _expectedCash = 3450;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  int _parseAmount(String input) {
    final normalized = input
        .replaceAll('৳', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('০', '0')
        .replaceAll('১', '1')
        .replaceAll('২', '2')
        .replaceAll('৩', '3')
        .replaceAll('৪', '4')
        .replaceAll('৫', '5')
        .replaceAll('৬', '6')
        .replaceAll('৭', '7')
        .replaceAll('৮', '8')
        .replaceAll('৯', '9');
    final value = double.tryParse(normalized);
    if (value == null) {
      return 0;
    }
    return value.round();
  }

  Widget _bottomNav() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: const BoxDecoration(
          color: AppColors.bottomNavBg,
          border: Border(
            top: BorderSide(color: AppColors.bottomNavBorder),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SalesBottomNavItem(
              icon: Icons.home_outlined,
              label: AppStrings.tabHome,
              selected: false,
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
            _SalesBottomNavItem(
              icon: Icons.point_of_sale_outlined,
              label: AppStrings.tabSales,
              selected: true,
              onTap: () => Navigator.of(context).pop(),
            ),
            _SalesBottomNavItem(
              icon: Icons.inventory_2_outlined,
              label: AppStrings.tabProducts,
              selected: false,
              onTap: () => Navigator.of(context)
                  .pushReplacementNamed(AppRoutes.products),
            ),
            _SalesBottomNavItem(
              icon: Icons.bar_chart_outlined,
              label: AppStrings.tabReports,
              selected: false,
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.reports),
            ),
            _SalesBottomNavItem(
              icon: Icons.more_horiz,
              label: AppStrings.tabMore,
              selected: false,
              onTap: () => Navigator.of(context)
                  .pushReplacementNamed(AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topSaleRow({
    required String rank,
    required String name,
    required String quantity,
    required String detail,
    required Color badgeColor,
    required Color badgeTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              rank,
              style: TextStyle(
                color: badgeTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF141F22),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Color(0xFF6F7D78),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            quantity,
            style: const TextStyle(
              color: Color(0xFF00694C),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enteredCash = _parseAmount(_cashController.text);
    final isMatched = enteredCash == _expectedCash;
    final diff = (enteredCash - _expectedCash).abs();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Container(
              height: 82,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3FAFB),
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: const Color(0xFFD9E6E2)),
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(Icons.arrow_back, color: Color(0xFF3D4943)),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'দৈনিক ক্লোজিং',
                        style: TextStyle(
                          color: Color(0xFF00694C),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5E7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '২৩ মে ২০২৬',
                      style: TextStyle(
                        color: Color(0xFF0C8C67),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D9E75), Color(0xFF00694C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B5B42).withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'আজকের সারসংক্ষেপ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '৳ ৪,৮৫০',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(height: 1, color: Colors.white.withOpacity(0.18)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: const [
                            Text(
                              'বিক্রয়',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '৩২টি',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 56,
                          color: Colors.white.withOpacity(0.18)),
                      Expanded(
                        child: Column(
                          children: const [
                            Text(
                              'লাভ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '৳১,২৪০',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 56,
                          color: Colors.white.withOpacity(0.18)),
                      Expanded(
                        child: Column(
                          children: const [
                            Text(
                              'বাকি',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '৳৬৭৫',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'নগদ হিসাব মিলান',
                    style: TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'প্রত্যাশিত নগদ:',
                          style: TextStyle(
                            color: Color(0xFF5F6A66),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _formatCurrency(_expectedCash),
                          style: const TextStyle(
                            color: Color(0xFF00694C),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'বাস্তব নগদ গণনা',
                    style: TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cashController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: NumericInputFormatters.decimal,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      color: Color(0xFF141F22),
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: '৳ ০.০০',
                      hintStyle: const TextStyle(color: Color(0xFF7C8A84)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF00694C), width: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isMatched
                          ? const Color(0xFFE5F7ED)
                          : const Color(0xFFFDEEEF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMatched
                            ? const Color(0xFFBDE7C9)
                            : const Color(0xFFF4D2D5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isMatched
                                  ? Icons.check_circle_outline
                                  : Icons.warning_amber_rounded,
                              color: isMatched
                                  ? const Color(0xFF0C8C67)
                                  : const Color(0xFFD43B3B),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isMatched ? 'হিসাব মিলেছে' : 'হিসাব মিলছে না',
                              style: TextStyle(
                                color: isMatched
                                    ? const Color(0xFF0C8C67)
                                    : const Color(0xFFD43B3B),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        if (!isMatched) ...[
                          const SizedBox(height: 8),
                          Text(
                            'পার্থক্য: ${_formatCurrency(diff)}',
                            style: const TextStyle(
                              color: Color(0xFFD43B3B),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'পেমেন্ট ভাঙনি',
                    style: TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PaymentBreakdownRow(
                    icon: Icons.payments_outlined,
                    title: 'নগদ (Cash)',
                    amount: '৳ ৩,৪৫০',
                    accent: const Color(0xFF0C8C67),
                  ),
                  const SizedBox(height: 12),
                  _PaymentBreakdownRow(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'বিকাশ/নগদ',
                    amount: '৳ ৭২৫',
                    accent: const Color(0xFF2D73FF),
                  ),
                  const SizedBox(height: 12),
                  _PaymentBreakdownRow(
                    icon: Icons.receipt_long_outlined,
                    title: 'বাকি (Due)',
                    amount: '৳ ৬৭৫',
                    accent: const Color(0xFFD43B3B),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'আজকের সেরা বিক্রয়',
                    style: TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _topSaleRow(
                    rank: '১',
                    name: 'মিনিকেট চাল',
                    quantity: '৪৮টি',
                    detail: 'প্যাকিং ২ কেজি',
                    badgeColor: const Color(0xFFFFF3C4),
                    badgeTextColor: const Color(0xFFAA7A00),
                  ),
                  const SizedBox(height: 12),
                  _topSaleRow(
                    rank: '২',
                    name: 'সয়াবিন তেল',
                    quantity: '২৪টি',
                    detail: 'পুষ্টি ৫ লিটার',
                    badgeColor: const Color(0xFFEFF2F7),
                    badgeTextColor: const Color(0xFF6F7D78),
                  ),
                  const SizedBox(height: 12),
                  _topSaleRow(
                    rank: '৩',
                    name: 'কোকা কোলা',
                    quantity: '৩৬টি',
                    detail: '৫০০ মি.লি.',
                    badgeColor: const Color(0xFFFFE7CC),
                    badgeTextColor: const Color(0xFFB76400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _DailyClosingSuccessScreen(
                          dateText: '২৩ মে ২০২৬',
                          salesText: '৳ ৪,৮৫০',
                          profitText: '৳ ১,২৪০',
                          dueText: '৳ ৬৭৫',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00694C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'ক্লোজিং সম্পন্ন করুন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _bottomNav(),
        ],
      ),
    );
  }
}
