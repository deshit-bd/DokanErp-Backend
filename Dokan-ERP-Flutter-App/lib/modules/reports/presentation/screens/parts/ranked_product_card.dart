part of '../reports_screens.dart';

class _RankedProductCard extends StatelessWidget {
  const _RankedProductCard({required this.product});

  final _TopProductStat product;

  @override
  Widget build(BuildContext context) {
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                _bnDigits(product.rank.toString()),
                style: const TextStyle(
                  color: Color(0xFF0C8C67),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: product.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(product.icon, color: product.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: const TextStyle(
                    color: Color(0xFF5F6A66),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_bnDigits(product.salesCount.toString())}${tr('টি', ' items')}',
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currency(product.revenue),
                style: const TextStyle(
                  color: Color(0xFF0C8C67),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});

  final _ActivityEntry entry;

  String _translateActivityTitle(String title) {
    if (AppStrings.activeLanguage == AppLanguage.english) {
      if (title.contains('বিক্রি')) {
        return title.replaceAll('বিক্রি', 'Sale');
      }
      if (title == 'নতুন পণ্য ক্রয়') return 'New Product Purchase';
      if (title == 'বিদ্যুৎ ও ভাড়া') return 'Electricity & Rent';
    }
    return title;
  }

  String _translateActivitySubtitle(String subtitle) {
    String result = subtitle;
    if (AppStrings.activeLanguage == AppLanguage.english) {
      result = result.replaceAll('বিক্রয়', 'Sale');
      result = result.replaceAll('ক্রয়', 'Purchase');
      result = result.replaceAll('খরচ', 'Expense');
      result = result.replaceAll('ইনভয়েস', 'Invoice');
      result = result.replaceAll('পণ্য', 'items');
      const map = <String, String>{
        '০': '0',
        '১': '1',
        '২': '2',
        '৩': '3',
        '৪': '4',
        '৫': '5',
        '৬': '6',
        '৭': '7',
        '৮': '8',
        '৯': '9',
        'টি': '',
      };
      map.forEach((key, value) {
        result = result.replaceAll(key, value);
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: entry.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(entry.icon, color: entry.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _translateActivityTitle(entry.title),
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _translateActivitySubtitle(entry.subtitle),
                  style: const TextStyle(
                    color: Color(0xFF5F6A66),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(entry.timestamp),
                  style: const TextStyle(
                    color: Color(0xFF3D4943),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            entry.trailing,
            style: TextStyle(
              color: entry.color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points});

  final List<_TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(
        child: Text(
          tr('কোনো ট্রেন্ড ডেটা নেই', 'No trend data available'),
          style: const TextStyle(
            color: Color(0xFF3D4943),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight - 26),
                painter: _TrendChartPainter(points),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final point in points)
                  Flexible(
                    child: Text(
                      point.label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5F6A66),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter(this.points);

  final List<_TrendPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final padding = 14.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);
    final maxValue =
        points.fold<int>(0, (max, point) => math.max(max, point.value));
    final safeMax = maxValue <= 0 ? 1 : maxValue.toDouble();
    final stepX =
        points.length <= 1 ? chartWidth : chartWidth / (points.length - 1);

    final axisPaint = Paint()
      ..color = const Color(0xFFD9E6E2)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );

    final gridPaint = Paint()
      ..color = const Color(0xFFF0F5F3)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = padding + chartHeight * (i / 4);
      canvas.drawLine(
          Offset(padding, y), Offset(size.width - padding, y), gridPaint);
    }

    final fillPath = Path();
    final linePath = Path();
    for (var i = 0; i < points.length; i++) {
      final x = padding + (stepX * i);
      final normalized = points[i].value / safeMax;
      final y = padding + chartHeight - (chartHeight * normalized);
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height - padding);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(padding + chartWidth, size.height - padding);
    fillPath.close();

    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x330C8C67),
          Color(0x110C8C67),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, gradientPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF0C8C67)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = const Color(0xFF0C8C67);
    for (var i = 0; i < points.length; i++) {
      final x = padding + (stepX * i);
      final normalized = points[i].value / safeMax;
      final y = padding + chartHeight - (chartHeight * normalized);
      canvas.drawCircle(Offset(x, y), 4.5, dotPaint);
      final valuePainter = TextPainter(
        text: TextSpan(
          text: _currency(points[i].value),
          style: const TextStyle(
            color: Color(0xFF0C8C67),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valuePainter.paint(canvas, Offset(x - valuePainter.width / 2, y - 22));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) =>
      oldDelegate.points != points;
}

class _ReportsExportBar extends StatelessWidget {
  const _ReportsExportBar({
    required this.onPdf,
    required this.onExcel,
    required this.onWhatsApp,
  });

  final VoidCallback onPdf;
  final VoidCallback onExcel;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: const Color(0xFFD7E5E0));
    return SizedBox(
      height: 74,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2F0),
          border: Border(top: border),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            children: [
              Expanded(
                child: _ReportExportActionButton(
                  label: tr('PDF রিপোর্ট', 'PDF Report'),
                  icon: Icons.picture_as_pdf_outlined,
                  onTap: onPdf,
                  filled: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReportExportActionButton(
                  label: 'Excel',
                  icon: Icons.grid_on_outlined,
                  onTap: onExcel,
                  filled: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReportExportActionButton(
                  label: 'WhatsApp',
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: onWhatsApp,
                  filled: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
