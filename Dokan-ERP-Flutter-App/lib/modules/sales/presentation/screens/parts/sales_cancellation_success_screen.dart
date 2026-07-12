part of '../sales_screens.dart';

class _SalesCancellationSuccessScreen extends StatelessWidget {
  const _SalesCancellationSuccessScreen({
    required this.refundMethod,
    required this.orderId,
    required this.refundAmount,
  });

  final String refundMethod;
  final String orderId;
  final int refundAmount;

  Widget _bottomNav(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: const BoxDecoration(
          color: Color(0xFFEAF2F0),
          border: Border(
            top: BorderSide(color: Color(0xFFD7E5E0)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SalesBottomNavItem(
              icon: Icons.home_outlined,
              label: 'হোম',
              selected: false,
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
            _SalesBottomNavItem(
              icon: Icons.point_of_sale_outlined,
              label: 'বিক্রয়',
              selected: true,
              onTap: () => Navigator.of(context).pop(),
            ),
            _SalesBottomNavItem(
              icon: Icons.inventory_2_outlined,
              label: 'পণ্য',
              selected: false,
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) => const DokanProductListScreen()),
              ),
            ),
            _SalesBottomNavItem(
              icon: Icons.bar_chart_outlined,
              label: 'রিপোর্ট',
              selected: false,
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) => const DokanReportsHomeScreen()),
              ),
            ),
            _SalesBottomNavItem(
              icon: Icons.more_horiz,
              label: 'আরও',
              selected: false,
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DokanAroOptionScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                        'বিক্রয় বাতিল',
                        style: TextStyle(
                          color: Color(0xFF00694C),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFD9E6E2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB9C8C3).withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5F7ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle,
                        color: Color(0xFF0C8C67), size: 56),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'বিক্রয় সফলভাবে বাতিল হয়েছে',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Invoice #${_banglaDigits(orderId.substring(math.max(0, orderId.length - 4)))}',
                    style: const TextStyle(
                      color: Color(0xFF00694C),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'বাতিল সম্পন্ন',
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
            _DetailSectionCard(
              child: Column(
                children: [
                  _InvoiceInfoRow(
                      icon: Icons.payments_outlined,
                      label: 'রিফান্ড পদ্ধতি',
                      value: refundMethod),
                  const SizedBox(height: 14),
                  _InvoiceInfoRow(
                      icon: Icons.receipt_long_outlined,
                      label: 'Invoice',
                      value: _banglaDigits(
                          orderId.substring(math.max(0, orderId.length - 4)))),
                  const SizedBox(height: 14),
                  _InvoiceInfoRow(
                      icon: Icons.currency_bitcoin_outlined,
                      label: 'Total Refund',
                      value: '৳${_banglaDigits(refundAmount.toString())}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7F0),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFD7E5E0)),
              ),
              child: const Text(
                'পণ্যগুলো স্টকে ফেরত যোগ করা হয়েছে',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0C8C67),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 58,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const _DokanSalesHistoryScreen()),
                    (route) => false,
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
                  'বিক্রয় ইতিহাসে ফিরুন',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }
}

class _DetailSectionCard extends StatelessWidget {
  const _DetailSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E6E2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB9C8C3).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InvoiceInfoRow extends StatelessWidget {
  const _InvoiceInfoRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6F7D78), size: 26),
        const SizedBox(width: 14),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6F7D78),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF141F22),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SaleDetailProduct {
  const _SaleDetailProduct({
    required this.icon,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  final String icon;
  final String name;
  final int quantity;
  final int price;
  final int total;
}

class _DetailProductCard extends StatelessWidget {
  const _DetailProductCard({required this.product});

  final _SaleDetailProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E6E2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB9C8C3).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF2F0),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              product.icon,
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Color(0xFF141F22),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'পরিমাণ: ${_banglaDigits(product.quantity.toString())} × ${_formatCurrency(product.price)}',
                  style: const TextStyle(
                    color: Color(0xFF3D4943),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatCurrency(product.total),
            style: const TextStyle(
              color: Color(0xFF141F22),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
