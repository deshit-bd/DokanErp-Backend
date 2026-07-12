part of '../product_screens.dart';

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.background,
    required this.leading,
    required this.title,
    required this.trailing,
  });

  final Color background;
  final Widget leading;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12, bottom: 14),
      decoration: BoxDecoration(
        color: background,
        border: const Border(
            bottom: BorderSide(color: Color(0xFFE1EBEF), width: 1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          leading,
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF00694C),
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          trailing,
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.text,
    this.smaller = false,
  });

  final String text;
  final bool smaller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: smaller ? 16 : 18, vertical: smaller ? 8 : 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD6EEE7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF9FD5C4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF00694C),
          fontSize: smaller ? 15 : 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background =
        selected ? const Color(0xFF00694C) : const Color(0xFFDCEAF1);
    final foreground = selected ? Colors.white : const Color(0xFF5C6662);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectableProductRow extends StatelessWidget {
  const _SelectableProductRow({
    required this.item,
    required this.onTap,
  });

  final DokanPopularProductItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = item.selected;

    return Material(
      color: isSelected ? const Color(0xFFDFF4EE) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Center(
                  child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: Color(0xFF1C2C27),
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.quantity,
                      style: const TextStyle(
                        color: Color(0xFF44514C),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF00694C) : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00694C)
                        : const Color(0xFF7D8A86),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockProductCard extends StatelessWidget {
  const _StockProductCard({
    required this.item,
    required this.onToggle,
    required this.onBackToPick,
  });

  final DokanPopularProductItem item;
  final VoidCallback onToggle;
  final VoidCallback onBackToPick;

  @override
  Widget build(BuildContext context) {
    final isSelected = item.selected;
    final background = isSelected ? const Color(0xFFDFF4EE) : Colors.white;
    final borderColor =
        isSelected ? const Color(0xFF0C7A59) : const Color(0xFFE2E8E4);

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Center(
                    child:
                        Text(item.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      color: Color(0xFF1D2723),
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      height: 1.05,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onToggle,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4D5A56),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'এড়িয়ে যান',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F0),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFB7DDD1)),
                ),
                child: const Text(
                  'ব্যাচ ১',
                  style: TextStyle(
                    color: Color(0xFF0C7A59),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _AmountField(
              label: 'বর্তমান স্টক',
              controller: item.stockController,
              borderColor: borderColor,
              fillColor: Colors.white,
              hintText: 'পরিমাণ লিখুন',
              textColor: const Color(0xFF1C2220),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AmountField(
                    label: 'ক্রয় মূল্য ৳',
                    controller: item.purchasePriceController,
                    borderColor: borderColor,
                    fillColor: Colors.white,
                    hintText: 'টাকা লিখুন',
                    textColor: const Color(0xFF1C2220),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _AmountField(
                    label: 'বিক্রয় মূল্য ৳',
                    controller: item.priceController,
                    borderColor: borderColor,
                    fillColor: Colors.white,
                    hintText: 'টাকা লিখুন',
                    textColor: const Color(0xFF1C2220),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AmountField(
              label: 'স্বল্প মজুদ সীমা',
              controller: item.lowStockLimitController,
              borderColor: borderColor,
              fillColor: Colors.white,
              hintText: 'ডিফল্ট ১০',
              textColor: const Color(0xFF1C2220),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onBackToPick,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2F6AF2),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'আরও পণ্য যোগ করুন',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.label,
    required this.controller,
    required this.borderColor,
    required this.fillColor,
    required this.hintText,
    required this.textColor,
  });

  final String label;
  final TextEditingController controller;
  final Color borderColor;
  final Color fillColor;
  final String hintText;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2D6B5A),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            const TrimLeadingZeroInputFormatter(),
            LengthLimitingTextInputFormatter(5),
          ],
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF8A9390),
              fontSize: 19,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Color(0xFF2F6AF2), width: 2.5),
            ),
          ),
        ),
      ],
    );
  }
}
