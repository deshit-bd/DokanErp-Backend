part of '../sales_screens.dart';

class _SalesEmptyState extends StatelessWidget {
  const _SalesEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD9E6E2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.warning_amber_rounded,
                size: 44, color: Color(0xFF0C8C67)),
            SizedBox(height: 10),
            Text(
              'এখনো কোনো বিক্রয় রেকর্ড নেই',
              style: TextStyle(
                color: Color(0xFF141F22),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesBottomNavItem extends StatelessWidget {
  const _SalesBottomNavItem({
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
        selected ? AppColors.bottomNavSelected : AppColors.bottomNavUnselected;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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

class _DokanSaleDetailScreen extends ConsumerWidget {
  const _DokanSaleDetailScreen({required this.order});

  final DokanPosOrderRecord order;

  bool _hasDueCollectionReceipt(DokanPosOrderRecord order) {
    return order.paymentHistory.length > 1;
  }

  DokanOrderPayment? _latestPayment(DokanPosOrderRecord order) {
    if (order.paymentHistory.isEmpty) {
      return null;
    }
    final payments = order.paymentHistory.toList(growable: false)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return payments.last;
  }

  int _previousPaidAmount(DokanPosOrderRecord order) {
    if (order.paymentHistory.length < 2) {
      return 0;
    }
    final payments = order.paymentHistory.toList(growable: false)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return payments
        .take(payments.length - 1)
        .fold<int>(0, (sum, item) => sum + item.amount);
  }

  DateTime _receiptDate(DokanPosOrderRecord order) {
    final latestPayment = _latestPayment(order);
    if (_hasDueCollectionReceipt(order) && latestPayment != null) {
      return latestPayment.createdAt;
    }
    return order.createdAt;
  }

  String _receiptTitle(DokanPosOrderRecord order) {
    return _hasDueCollectionReceipt(order)
        ? 'বাকি পরিশোধ রসিদ'
        : 'ইনভয়েস / রশিদ';
  }

  String _receiptNumber(DokanPosOrderRecord order) {
    final baseNumber = order.paymentReference.isNotEmpty
        ? order.paymentReference
        : order.id.substring(0, math.min(order.id.length, 8));
    if (!_hasDueCollectionReceipt(order)) {
      return baseNumber;
    }
    return '$baseNumber-DUE-${order.paymentHistory.length}';
  }

  int _currentReceiptAmount(DokanPosOrderRecord order) {
    final latestPayment = _latestPayment(order);
    if (_hasDueCollectionReceipt(order) && latestPayment != null) {
      return latestPayment.amount;
    }
    return order.paidAmount;
  }

  DokanPosPaymentMethod _receiptPaymentMethod(DokanPosOrderRecord order) {
    final latestPayment = _latestPayment(order);
    if (_hasDueCollectionReceipt(order) && latestPayment != null) {
      return latestPayment.method;
    }
    return order.paymentMethod;
  }

  String _receiptReference(DokanPosOrderRecord order) {
    final latestPayment = _latestPayment(order);
    if (_hasDueCollectionReceipt(order) && latestPayment != null) {
      return latestPayment.reference;
    }
    return order.paymentReference;
  }

  String _paymentMethodLabel(DokanPosPaymentMethod method) {
    return switch (method) {
      DokanPosPaymentMethod.cash => 'নগদ',
      DokanPosPaymentMethod.bkash => 'বিকাশ',
      DokanPosPaymentMethod.nagad => 'নগদ',
      DokanPosPaymentMethod.rocket => 'রকেট',
      DokanPosPaymentMethod.card => 'কার্ড',
      DokanPosPaymentMethod.bank => 'ব্যাংক',
      DokanPosPaymentMethod.due => 'বাকি',
    };
  }

  String _formatBanglaDateTime(DateTime date) {
    final localDate = date.toLocal();
    final banglaMonths = [
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
    final day = _banglaDigits(localDate.day.toString());
    final month = banglaMonths[localDate.month - 1];
    final year = _banglaDigits(localDate.year.toString());
    final hourNum = localDate.hour % 12 == 0 ? 12 : localDate.hour % 12;
    final hour = _banglaDigits(hourNum.toString());
    final minute = _banglaDigits(localDate.minute.toString().padLeft(2, '0'));
    final period = localDate.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year, $hour:$minute $period';
  }

  void _showMessage(BuildContext context, String message,
      {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            success ? const Color(0xFF0C8C67) : const Color(0xFFD43B3B),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(dokanInventoryCatalogProvider);
    final products = order.lines.map((line) {
      final catalogProduct =
          catalog.firstWhereOrNull((p) => p.barcode == line.productId);
      return _SaleDetailProduct(
        icon: catalogProduct?.emoji ?? '📦',
        name: line.productName,
        quantity: line.quantity,
        price: line.unitPrice,
        total: line.lineTotal,
      );
    }).toList();

    final isCancelled = order.status == DokanPosOrderStatus.cancelled;
    final isPaid = order.status == DokanPosOrderStatus.paid;
    final isPartiallyPaid = order.status == DokanPosOrderStatus.partiallyPaid;
    final isGuest = order.customerNumber.trim().isEmpty ||
        order.customerName == 'হাঁটা বিক্রয়' ||
        order.customerName == 'Guest Customer';

    final statusText = isCancelled
        ? 'বাতিল'
        : isPaid
            ? 'সম্পন্ন'
            : isPartiallyPaid
                ? 'আংশিক সম্পন্ন'
                : 'বাকি';

    final statusColor = isCancelled
        ? const Color(0xFFD43B3B)
        : isPaid
            ? const Color(0xFF0C8C67)
            : isPartiallyPaid
                ? const Color(0xFFE15298)
                : const Color(0xFFD43B3B);

    final staffList =
        ref.watch(dokanPosProvider.select((state) => state.staffProfiles));
    final salesmanProfile = staffList
        .firstWhereOrNull((staff) => staff.phone == order.salesmanPhone);
    final salesmanName = salesmanProfile != null
        ? (salesmanProfile.role.toLowerCase() == 'owner'
            ? '${salesmanProfile.name} (মালিক)'
            : '${salesmanProfile.name} (${salesmanProfile.role})')
        : (order.salesmanName != null && order.salesmanName!.isNotEmpty
            ? order.salesmanName!
            : 'রহিম উদ্দিন (মালিক)');

    final subtotal =
        order.lines.fold<int>(0, (sum, line) => sum + line.lineTotal);
    final discount = subtotal - order.totalAmount;
    final discountPercent =
        subtotal > 0 ? (discount * 100 / subtotal).round() : 0;

    final profitText = order.grossProfit >= 0
        ? '৳${_banglaDigits(order.grossProfit.toString())}'
        : '−৳${_banglaDigits((-order.grossProfit).toString())}';

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3FAFB),
                borderRadius: BorderRadius.circular(24),
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
                        'বিক্রয় বিস্তারিত',
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
                      color: isCancelled
                          ? const Color(0xFFFDEEEF)
                          : const Color(0xFFE1F5E7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isCancelled
                    ? const Color(0xFFFDEEEF)
                    : const Color(0xFFE8F4EF),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCancelled ? Icons.cancel : Icons.check_circle,
                        color: statusColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Invoice #${_banglaDigits(order.id.substring(math.max(0, order.id.length - 4)))}',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _DetailSectionCard(
              child: Column(
                children: [
                  _InvoiceInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'তারিখ',
                      value: _formatBanglaDateTime(order.createdAt)),
                  const SizedBox(height: 18),
                  _InvoiceInfoRow(
                      icon: Icons.payments_outlined,
                      label: 'পেমেন্ট',
                      value: _paymentMethodLabel(order.paymentMethod)),
                  const SizedBox(height: 18),
                  _InvoiceInfoRow(
                      icon: Icons.person_outline,
                      label: 'খদ্দের',
                      value: order.customerName.trim().isEmpty
                          ? 'অতিথি গ্রাহক'
                          : order.customerName),
                  const SizedBox(height: 18),
                  _InvoiceInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'বিক্রেতা',
                      value: salesmanName),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'পণ্য তালিকা',
              style: TextStyle(
                color: Color(0xFF141F22),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            ...products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DetailProductCard(product: product),
              ),
            ),
            const SizedBox(height: 6),
            _DetailSectionCard(
              child: Column(
                children: [
                  _SummaryAmountRow(
                      label: 'উপমোট',
                      value: '৳${_banglaDigits(subtotal.toString())}'),
                  const SizedBox(height: 14),
                  if (discount > 0) ...[
                    _SummaryAmountRow(
                        label:
                            'ডিসকাউন্ট (${_banglaDigits(discountPercent.toString())}%)',
                        value: '−৳${_banglaDigits(discount.toString())}',
                        valueColor: const Color(0xFFD43B3B)),
                    const SizedBox(height: 14),
                  ],
                  const Divider(color: Color(0xFFD9E6E2), height: 1),
                  const SizedBox(height: 14),
                  _SummaryAmountRow(
                      label: 'সর্বমোট',
                      value: '৳${_banglaDigits(order.totalAmount.toString())}',
                      emphasis: true),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ক্রয়মূল্য',
                        style: TextStyle(
                          color: Color(0xFF6F7D78),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '৳${_banglaDigits(order.costAmount.toString())}',
                        style: const TextStyle(
                          color: Color(0xFF141F22),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'মুনাফা',
                        style: TextStyle(
                          color: Color(0xFF0C8C67),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        profitText,
                        style: const TextStyle(
                          color: Color(0xFF0C8C67),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _DetailActionTile(
                    label: 'প্রিন্ট',
                    icon: Icons.print_outlined,
                    onTap: () async {
                      try {
                        _showMessage(context, 'প্রিন্ট লোড হচ্ছে...');
                        final pdfData = await _generatePdf(order);
                        await Printing.layoutPdf(
                          onLayout: (PdfPageFormat format) async => pdfData,
                          name: 'Invoice-${order.paymentReference}',
                        );
                      } catch (e) {
                        _showMessage(context, 'প্রিন্ট করতে ত্রুটি হয়েছে: $e',
                            success: false);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DetailActionTile(
                    label: 'PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    onTap: () async {
                      try {
                        _showMessage(context, 'PDF তৈরি হচ্ছে...');
                        final pdfData = await _generatePdf(order);
                        await Printing.sharePdf(
                          bytes: pdfData,
                          filename:
                              'Invoice-${order.paymentReference.isNotEmpty ? order.paymentReference : order.id}.pdf',
                        );
                      } catch (e) {
                        _showMessage(context, 'PDF তৈরি করতে ত্রুটি হয়েছে: $e',
                            success: false);
                      }
                    },
                  ),
                ),
                if (!isGuest) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailActionTile(
                      label: 'WhatsApp',
                      icon: Icons.chat_bubble_outline,
                      filled: true,
                      onTap: () async {
                        try {
                          final itemsSummary = order.lines
                              .map((line) =>
                                  '${line.productName} (${line.quantity}টি) - ৳${line.lineTotal}')
                              .join('\n');
                          final receiptNo = _receiptNumber(order);
                          final currentPayment = _currentReceiptAmount(order);
                          final previousPaid = _previousPaidAmount(order);
                          final isDueReceipt = _hasDueCollectionReceipt(order);
                          final paymentMethod =
                              _paymentMethodLabel(_receiptPaymentMethod(order));
                          final reference = _receiptReference(order);
                          final text = <String>[
                            'প্রিয় গ্রাহক,',
                            'আপনার Dokan ERP ${_receiptTitle(order)} #$receiptNo প্রস্তুত হয়েছে।',
                            '',
                            'পণ্য তালিকা:',
                            itemsSummary,
                            '',
                            'মোট বিক্রয়: ৳${order.totalAmount}',
                            if (isDueReceipt) 'আগে পরিশোধিত: ৳$previousPaid',
                            '${isDueReceipt ? 'এইবার পরিশোধ' : 'পরিশোধিত'}: ৳$currentPayment',
                            'বকেয়া: ৳${order.dueAmount}',
                            'পেমেন্ট মাধ্যম: $paymentMethod',
                            if (reference.isNotEmpty) 'রেফারেন্স: $reference',
                            '',
                            'আমাদের দোকানে কেনাকাটার জন্য ধন্যবাদ!',
                          ].join('\n');

                          final encodedText = Uri.encodeComponent(text);
                          final cleanPhone = order.customerNumber
                              .replaceAll(RegExp(r'\D'), '');

                          String phoneWithCode = cleanPhone;
                          if (cleanPhone.length == 11 &&
                              cleanPhone.startsWith('01')) {
                            phoneWithCode = '88$cleanPhone';
                          }

                          final urlString = phoneWithCode.isNotEmpty
                              ? 'https://wa.me/$phoneWithCode?text=$encodedText'
                              : 'https://wa.me/?text=$encodedText';

                          final uri = Uri.parse(urlString);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } else {
                            _showMessage(context, 'WhatsApp চালু করা যায়নি',
                                success: false);
                          }
                        } catch (e) {
                          _showMessage(context,
                              'WhatsApp বার্তা পাঠাতে সমস্যা হয়েছে: $e',
                              success: false);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
            if (!isCancelled) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            _SalesCancellationScreen(orderId: order.id),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF2C7C7), width: 2),
                    foregroundColor: const Color(0xFFD43B3B),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text(
                    'বিক্রয় বাতিল করুন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
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
                  MaterialPageRoute(
                      builder: (_) => const DokanAroOptionScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fixText(String text) {
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) {
      return text.fix;
    }
    return text;
  }

  Future<Uint8List> _generatePdf(DokanPosOrderRecord order) async {
    await BanglaFontManager().initialize();
    final pdf = pw.Document();

    const fontType = BanglaFontType.kalpurush;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // POS Printer format 80mm
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'ডোকান ইআরপি'.fix + ' (Dokan ERP)',
                  style:
                      fontType.ts(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  _receiptTitle(order).fix,
                  style: fontType.ts(fontSize: 9),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 3),
              pw.Text(
                'Receipt No: ${_receiptNumber(order)}',
                style: fontType.ts(fontSize: 8),
              ),
              pw.Text(
                'তারিখ: ${_formatBanglaDateTime(_receiptDate(order))}'.fix,
                style: fontType.ts(fontSize: 8),
              ),
              pw.Text(
                'ক্রেতা: '.fix + _fixText(order.customerName),
                style: fontType.ts(fontSize: 8),
              ),
              if (order.customerNumber.isNotEmpty)
                pw.Text(
                  'মোবাইল: '.fix + order.customerNumber,
                  style: fontType.ts(fontSize: 8),
                ),
              if (order.salesmanName != null)
                pw.Text(
                  'বিক্রেতা: '.fix + _fixText(order.salesmanName!),
                  style: fontType.ts(fontSize: 8),
                ),
              pw.SizedBox(height: 3),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 3),

              // Table of items
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('বিবরণ'.fix,
                          style: fontType.ts(
                              fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('পরিমাণ'.fix,
                          style: fontType.ts(
                              fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('মোট'.fix,
                          style: fontType.ts(
                              fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  for (final item in order.lines)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 1),
                          child: pw.Text(_fixText(item.productName),
                              style: fontType.ts(fontSize: 7)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 1),
                          child: pw.Text('${item.quantity}'.fix,
                              style: fontType.ts(fontSize: 7)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 1),
                          child: pw.Text('${item.lineTotal} টাকা'.fix,
                              style: fontType.ts(fontSize: 7)),
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 3),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('মোট বিক্রয়:'.fix,
                      style: fontType.ts(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${order.totalAmount} টাকা'.fix,
                      style: fontType.ts(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              if (_hasDueCollectionReceipt(order))
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('আগের পরিশোধ:'.fix,
                        style: fontType.ts(fontSize: 7)),
                    pw.Text('${_previousPaidAmount(order)} টাকা'.fix,
                        style: fontType.ts(fontSize: 7)),
                  ],
                ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      (_hasDueCollectionReceipt(order)
                              ? 'এইবার পরিশোধ:'
                              : 'পরিশোধ:')
                          .fix,
                      style: fontType.ts(fontSize: 7)),
                  pw.Text('${_currentReceiptAmount(order)} টাকা'.fix,
                      style: fontType.ts(fontSize: 7)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('বাকি / বকেয়া:'.fix, style: fontType.ts(fontSize: 7)),
                  pw.Text('${order.dueAmount} টাকা'.fix,
                      style: fontType.ts(fontSize: 7)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('পেমেন্ট মাধ্যম:'.fix,
                      style: fontType.ts(fontSize: 7)),
                  pw.Text(_paymentMethodLabel(_receiptPaymentMethod(order)).fix,
                      style: fontType.ts(fontSize: 7)),
                ],
              ),
              if (_receiptReference(order).isNotEmpty)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('রেফারেন্স:'.fix, style: fontType.ts(fontSize: 7)),
                    pw.Text(_fixText(_receiptReference(order)),
                        style: fontType.ts(fontSize: 7)),
                  ],
                ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'ধন্যবাদ! আবার আসবেন।'.fix,
                  style: fontType.ts(fontSize: 8),
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }
}
