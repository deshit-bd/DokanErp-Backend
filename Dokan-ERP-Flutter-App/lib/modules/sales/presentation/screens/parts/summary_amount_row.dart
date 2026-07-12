part of '../sales_screens.dart';

class _SummaryAmountRow extends StatelessWidget {
  const _SummaryAmountRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF141F22),
    this.emphasis = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF6F7D78),
            fontSize: emphasis ? 18 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        AnimatedNumberString(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: emphasis ? 28 : 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DetailActionTile extends StatelessWidget {
  const _DetailActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? const Color(0xFF2FD16A) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: filled ? const Color(0xFF2FD16A) : const Color(0xFF0C8C67),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: filled ? Colors.white : const Color(0xFF0C8C67),
                  size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.white : const Color(0xFF0C8C67),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SalesSearchInlinePanel extends StatelessWidget {
  const _SalesSearchInlinePanel({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'বিক্রয় খোঁজ',
            style: TextStyle(
              color: Color(0xFF141F22),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DokanSearchField(
                  controller: controller,
                  hintText: 'নাম, নম্বর, রেফারেন্স লিখুন',
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: const Color(0xFFEAF2F0),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child:
                        Icon(Icons.close, color: Color(0xFF00694C), size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterSummary extends StatelessWidget {
  const _ActiveFilterSummary({
    required this.searchText,
    required this.timeLabel,
    required this.statusLabel,
    required this.amountLabel,
    required this.customDate,
    required this.onClearAll,
  });

  final String searchText;
  final String timeLabel;
  final String statusLabel;
  final String amountLabel;
  final DateTime? customDate;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (searchText.isNotEmpty) {
      chips.add(_SummaryChip(label: 'খোঁজ: $searchText'));
    }
    if (customDate != null) {
      final formattedDate =
          '${customDate!.day}/${customDate!.month}/${customDate!.year}';
      chips.add(_SummaryChip(label: 'তারিখ: $formattedDate'));
    } else if (timeLabel.isNotEmpty && timeLabel != 'আজ') {
      chips.add(_SummaryChip(label: 'সময়: $timeLabel'));
    }
    if (statusLabel != 'সব অবস্থা') {
      chips.add(_SummaryChip(label: 'অবস্থা: $statusLabel'));
    }
    if (amountLabel != 'সব পরিমাণ') {
      chips.add(_SummaryChip(label: 'পরিমাণ: $amountLabel'));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'সক্রিয় ফিল্টার',
                style: TextStyle(
                  color: Color(0xFF141F22),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearAll,
                child: const Text(
                  'সব মুছুন',
                  style: TextStyle(
                    color: Color(0xFFB3261E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: chips.isEmpty
                ? const [
                    _SummaryChip(label: 'কোনো ফিল্টার সক্রিয় নয়'),
                  ]
                : chips,
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2F0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF00694C),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SalesFilterInlinePanel extends StatelessWidget {
  const _SalesFilterInlinePanel({
    required this.selectedStatusIndex,
    required this.selectedAmountIndex,
    required this.statusFilters,
    required this.amountFilters,
    required this.onStatusTap,
    required this.onAmountTap,
    required this.onReset,
  });

  final int selectedStatusIndex;
  final int selectedAmountIndex;
  final List<String> statusFilters;
  final List<String> amountFilters;
  final ValueChanged<int> onStatusTap;
  final ValueChanged<int> onAmountTap;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 360;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD9E6E2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ফিল্টার',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onReset,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'রিসেট',
                      style: TextStyle(
                        color: Color(0xFFB3261E),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'পরিশোধ অবস্থা',
                style: TextStyle(
                  color: Color(0xFF3D4943),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (narrow)
                Column(
                  children: List.generate(statusFilters.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == statusFilters.length - 1 ? 0 : 10,
                      ),
                      child: _FilterListTile(
                        title: statusFilters[index],
                        selected: selectedStatusIndex == index,
                        onTap: () => onStatusTap(index),
                      ),
                    );
                  }),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(statusFilters.length, (index) {
                    return _FilterChoiceChip(
                      label: statusFilters[index],
                      selected: selectedStatusIndex == index,
                      onTap: () => onStatusTap(index),
                    );
                  }),
                ),
              const SizedBox(height: 14),
              const Text(
                'পরিমাণ সীমা',
                style: TextStyle(
                  color: Color(0xFF3D4943),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: List.generate(amountFilters.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == amountFilters.length - 1 ? 0 : 10,
                    ),
                    child: _FilterListTile(
                      title: amountFilters[index],
                      selected: selectedAmountIndex == index,
                      onTap: () => onAmountTap(index),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
