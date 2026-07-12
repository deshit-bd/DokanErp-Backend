part of '../reports_screens.dart';

class _ExpenseSummaryKpi {
  const _ExpenseSummaryKpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.trend,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String trend;
}

class _TimeTabRow extends StatelessWidget {
  const _TimeTabRow({
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
  });

  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Padding(
            padding:
                EdgeInsets.only(right: index == labels.length - 1 ? 0 : 10),
            child: _ReportChip(
              label: labels[index],
              selected: selected,
              onTap: () => onChanged(index),
            ),
          );
        }),
      ),
    );
  }
}

class _ExpenseKpiCard extends StatelessWidget {
  const _ExpenseKpiCard({required this.item, this.onTap});

  final _ExpenseSummaryKpi item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD9E6E2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: item.accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.accent, size: 18),
                  ),
                  const Spacer(),
                  Text(
                    item.trend,
                    style: TextStyle(
                      color: item.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF5F6A66),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: item.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    this.onEdit,
    this.onDelete,
  });

  final Object expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final title = expense is DokanExpenseRecord
        ? (expense as DokanExpenseRecord).title
        : (expense as dynamic).title as String;
    final category = expense is DokanExpenseRecord
        ? (expense as DokanExpenseRecord).category
        : (expense as dynamic).category as String;
    final amount = expense is DokanExpenseRecord
        ? (expense as DokanExpenseRecord).amount
        : (expense as dynamic).amount as int;
    final statusText = expense is DokanExpenseRecord
        ? ((expense as DokanExpenseRecord).status == DokanExpenseStatus.paid
            ? 'Paid'
            : 'Pending')
        : (expense as dynamic).status as String;
    final color = expense is DokanExpenseRecord
        ? const Color(0xFF0C8C67)
        : (expense as dynamic).color as Color;
    final dateTimeLabel = expense is DokanExpenseRecord
        ? _expenseDateLabel((expense as DokanExpenseRecord).date)
        : (expense as dynamic).dateTime as String;
    final isPaid = statusText == 'Paid';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showExpenseDetails(context, expense),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD9E6E2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: expense.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPaid
                      ? Icons.check_circle_outline_rounded
                      : Icons.schedule_rounded,
                  color: expense.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            dateTimeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF5F6A66),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currency(amount.toInt()),
                        style: const TextStyle(
                          color: Color(0xFF0C8C67),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      PopupMenuButton<int>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert_rounded,
                            color: Color(0xFF5F6A66)),
                        onSelected: (value) {
                          if (value == 0) {
                            onEdit?.call();
                          } else if (value == 1) {
                            onDelete?.call();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<int>(
                            value: 0,
                            child: Text('সম্পাদনা করুন'),
                          ),
                          PopupMenuItem<int>(
                            value: 1,
                            child: Text('মুছে ফেলুন'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: isPaid
                          ? const Color(0xFF0C8C67)
                          : const Color(0xFFF49B1A),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpenseDetails(BuildContext context, dynamic expenseObj) {
    final title = expenseObj is DokanExpenseRecord
        ? expenseObj.title
        : (expenseObj as dynamic).title as String;
    final category = expenseObj is DokanExpenseRecord
        ? expenseObj.category
        : (expenseObj as dynamic).category as String;
    final amount = expenseObj is DokanExpenseRecord
        ? expenseObj.amount
        : (expenseObj as dynamic).amount as num;
    final statusText = expenseObj is DokanExpenseRecord
        ? (expenseObj.status == DokanExpenseStatus.paid ? ' Paid' : 'Pending')
        : (expenseObj as dynamic).status as String;
    final isPaid = statusText.trim().toLowerCase() == 'paid';
    final dateTimeLabel = expenseObj is DokanExpenseRecord
        ? _expenseDateLabel(expenseObj.date)
        : (expenseObj as dynamic).dateTime as String;

    // Note
    final note = expenseObj is DokanExpenseRecord
        ? expenseObj.note
        : (expenseObj as dynamic).note as String?;

    // Receipt
    final receipt = expenseObj is DokanExpenseRecord
        ? expenseObj.receiptLabel
        : (expenseObj as dynamic).receiptLabel as String?;

    // Payment Method
    String paymentMethodLabel = 'নগদ';
    if (expenseObj is DokanExpenseRecord) {
      paymentMethodLabel = switch (expenseObj.paymentMethod) {
        DokanExpensePaymentMethod.cash => 'নগদ',
        DokanExpensePaymentMethod.bkash => 'bKash',
        DokanExpensePaymentMethod.nagad => 'Nagad',
        DokanExpensePaymentMethod.bank => 'ব্যাংক',
      };
    } else {
      paymentMethodLabel =
          (expenseObj as dynamic).paymentMethodLabel as String? ?? 'নগদ';
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'খরচের বিবরণ',
                        style: TextStyle(
                          color: Color(0xFF5F6A66),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '৳${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}',
                        style: const TextStyle(
                          color: Color(0xFF0C8C67),
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _detailRow('খরচের শিরোনাম', title),
                _detailRow('ক্যাটাগরি', category),
                _detailRow('পেমেন্ট মাধ্যম', paymentMethodLabel),
                _detailRow(
                  'অবস্থা',
                  isPaid ? 'পরিশোধিত (Paid)' : 'বাকি (Pending)',
                  valueColor: isPaid
                      ? const Color(0xFF0C8C67)
                      : const Color(0xFFF49B1A),
                ),
                _detailRow('তারিখ ও সময়', dateTimeLabel),
                if (note != null && note.trim().isNotEmpty)
                  _detailRow('নোট / বিবরণ', note),
                if (receipt != null &&
                    receipt.trim().isNotEmpty &&
                    receipt != 'ছবি যোগ করা হয়নি')
                  _detailRow('সংযুক্ত রসিদ', receipt),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5F6A66),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF111111),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Divider(color: Color(0xFFE5ECE9), height: 16),
        ],
      ),
    );
  }
}

class _ExpenseFilterBar extends StatefulWidget {
  const _ExpenseFilterBar({
    this.initialQuery = '',
    this.initialCategory,
    this.categories = const <String>[],
    this.onQueryChanged,
    this.onCategoryChanged,
  });

  final String initialQuery;
  final String? initialCategory;
  final List<String> categories;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<String?>? onCategoryChanged;

  @override
  State<_ExpenseFilterBar> createState() => _ExpenseFilterBarState();
}

class _ExpenseFilterBarState extends State<_ExpenseFilterBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryItems = <String?>[null, ...widget.categories];
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DokanSearchField(
                controller: _controller,
                hintText: 'খরচ খুঁজুন',
                height: 48,
                onChanged: widget.onQueryChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String?>(
          value: widget.initialCategory,
          onChanged: widget.onCategoryChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFF0C8C67), width: 1.4),
            ),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child:
                  Text('সব ক্যাটাগরি', style: TextStyle(color: Colors.black)),
            ),
            ...categoryItems.whereType<String>().map(
                  (item) => DropdownMenuItem<String?>(
                    value: item,
                    child:
                        Text(item, style: const TextStyle(color: Colors.black)),
                  ),
                ),
          ],
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF0C8C67)),
          dropdownColor: Colors.white,
          style: const TextStyle(
              color: Color(0xFF111111), fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
