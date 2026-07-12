part of '../reports_screens.dart';

class _ValueLineItem extends StatelessWidget {
  const _ValueLineItem({
    required this.label,
    required this.value,
    required this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF111111),
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: emphasize ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: const Color(0xFFE6ECEA),
    );
  }
}

class _StockRatioChart extends StatelessWidget {
  const _StockRatioChart({
    required this.slices,
    required this.centerLabel,
    required this.centerValue,
  });

  final List<_StockRatioSlice> slices;
  final String centerLabel;
  final String centerValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SizedBox(
            width: math.min(constraints.maxWidth, 220),
            height: math.min(constraints.maxHeight, 220),
            child: CustomPaint(
              painter: _StockRatioPainter(slices),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerLabel,
                      style: const TextStyle(
                        color: Color(0xFF3D4943),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      centerValue,
                      style: const TextStyle(
                        color: Color(0xFF0C8C67),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
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

class _StockRatioPainter extends CustomPainter {
  _StockRatioPainter(this.slices);

  final List<_StockRatioSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.value);
    if (total <= 0) return;
    final rect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    final strokeWidth = 20.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweepAngle = (slice.value / total) * math.pi * 2;
      paint.color = slice.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _StockRatioPainter oldDelegate) =>
      oldDelegate.slices != slices;
}

class _RatioLegendItem extends StatelessWidget {
  const _RatioLegendItem({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF3D4943),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ReportExportActionButton extends StatefulWidget {
  const _ReportExportActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  State<_ReportExportActionButton> createState() =>
      _ReportExportActionButtonState();
}

class _ReportExportActionButtonState extends State<_ReportExportActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor = Colors.white;
    final labelColor =
        widget.label.contains('PDF') ? Colors.black : foregroundColor;
    final backgroundColor = widget.filled
        ? (_pressed ? const Color(0xFF0A6A4F) : const Color(0xFF0C8C67))
        : (_pressed ? const Color(0xFFDFF5EE) : Colors.white);

    final child = SizedBox(
      width: double.infinity,
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            widget.icon,
            color:
                widget.label.contains('PDF') ? Colors.black : foregroundColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.filled) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            transform: Matrix4.translationValues(0, _pressed ? -1 : 0, 0),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _pressed
                      ? const Color(0x400C8C67)
                      : const Color(0x220C8C67),
                  blurRadius: _pressed ? 16 : 8,
                  offset: Offset(0, _pressed ? 8 : 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          transform: Matrix4.translationValues(0, _pressed ? -1 : 0, 0),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  _pressed ? const Color(0xFF0C8C67) : const Color(0xFF0C8C67),
              width: _pressed ? 1.8 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: _pressed ? const Color(0x240C8C67) : Colors.transparent,
                blurRadius: _pressed ? 12 : 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ReportsBottomNav extends ConsumerWidget {
  const _ReportsBottomNav({required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: const BoxDecoration(
          color: AppColors.bottomNavBg,
          border: Border(top: BorderSide(color: AppColors.bottomNavBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ReportsNavItem(
              icon: Icons.home_outlined,
              label: AppStrings.tabHome,
              selected: selectedIndex == 0,
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
            _ReportsNavItem(
              icon: Icons.point_of_sale_outlined,
              label: AppStrings.tabSales,
              selected: selectedIndex == 1,
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.sales),
            ),
            _ReportsNavItem(
              icon: Icons.inventory_2_outlined,
              label: AppStrings.tabProducts,
              selected: selectedIndex == 2,
              onTap: () => Navigator.of(context).pushReplacementNamed(
                AppRoutes.products,
              ),
            ),
            _ReportsNavItem(
              icon: Icons.bar_chart_outlined,
              label: AppStrings.tabReports,
              selected: selectedIndex == 3,
              onTap: () {},
            ),
            _ReportsNavItem(
              icon: Icons.more_horiz,
              label: AppStrings.tabMore,
              selected: selectedIndex == 4,
              onTap: () => Navigator.of(context).pushReplacementNamed(
                AppRoutes.settings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
