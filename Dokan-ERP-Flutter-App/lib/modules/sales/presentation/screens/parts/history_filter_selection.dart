part of '../sales_screens.dart';

class _HistoryFilterSelection {
  const _HistoryFilterSelection({
    required this.timeIndex,
    required this.statusIndex,
    required this.rangeIndex,
  });

  final int timeIndex;
  final int statusIndex;
  final int rangeIndex;
}

class _SalesFilterScreen extends StatefulWidget {
  const _SalesFilterScreen({
    required this.initialTime,
    required this.initialStatus,
    required this.initialRange,
  });

  final int initialTime;
  final int initialStatus;
  final int initialRange;

  @override
  State<_SalesFilterScreen> createState() => _SalesFilterScreenState();
}

class _SalesFilterScreenState extends State<_SalesFilterScreen> {
  late int _selectedTime;
  late int _selectedStatus;
  late int _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime == -1 ? 4 : widget.initialTime;
    _selectedStatus = widget.initialStatus;
    _selectedRange = widget.initialRange;
  }

  static const List<String> _times = <String>[
    'আজ',
    'গতকাল',
    'এই সপ্তাহ',
    'এই মাস',
    'সব',
  ];

  static const List<String> _statuses = <String>[
    'সব অবস্থা',
    'সম্পূর্ণ পরিশোধ',
    'বাকি আছে',
    'আংশিক পরিশোধ',
  ];

  static const List<String> _ranges = <String>[
    'সব পরিমাণ',
    '৳১,০০০ এর নিচে',
    '৳১,০০০ - ৳৫,০০০',
    '৳৫,০০০ এর বেশি',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 30),
              duration: const Duration(milliseconds: 500),
              slideOffset: const Offset(0, -10),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _HistoryIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'ফিল্টার',
                        style: TextStyle(
                          color: Color(0xFF00694C),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _HistoryIconButton(
                      icon: Icons.restart_alt,
                      onTap: () {
                        setState(() {
                          _selectedTime = 0;
                          _selectedStatus = 0;
                          _selectedRange = 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            DokanFadeSlideIn(
              delay: const Duration(milliseconds: 70),
              duration: const Duration(milliseconds: 500),
              slideOffset: const Offset(0, 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D9E75), Color(0xFF00694C)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'বিক্রয় ফিল্টার করুন',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'সময়, অবস্থা, এবং পরিমাণ অনুযায়ী তালিকা সাজান।',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  DokanFadeSlideIn(
                    delay: const Duration(milliseconds: 110),
                    duration: const Duration(milliseconds: 500),
                    slideOffset: const Offset(0, 15),
                    child: _FilterSectionCard(
                      title: 'সময় নির্বাচন',
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(_times.length, (index) {
                          return _FilterChoiceChip(
                            label: _times[index],
                            selected: _selectedTime == index,
                            onTap: () {
                              setState(() {
                                _selectedTime = index;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DokanFadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    duration: const Duration(milliseconds: 500),
                    slideOffset: const Offset(0, 15),
                    child: _FilterSectionCard(
                      title: 'পরিশোধ অবস্থা',
                      child: Column(
                        children: List.generate(_statuses.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _statuses.length - 1 ? 0 : 10,
                            ),
                            child: _FilterListTile(
                              title: _statuses[index],
                              selected: _selectedStatus == index,
                              onTap: () {
                                setState(() {
                                  _selectedStatus = index;
                                });
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DokanFadeSlideIn(
                    delay: const Duration(milliseconds: 190),
                    duration: const Duration(milliseconds: 500),
                    slideOffset: const Offset(0, 15),
                    child: _FilterSectionCard(
                      title: 'পরিমাণ সীমা',
                      child: Column(
                        children: List.generate(_ranges.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _ranges.length - 1 ? 0 : 10,
                            ),
                            child: _FilterListTile(
                              title: _ranges[index],
                              selected: _selectedRange == index,
                              onTap: () {
                                setState(() {
                                  _selectedRange = index;
                                });
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DokanFadeSlideIn(
                    delay: const Duration(milliseconds: 230),
                    duration: const Duration(milliseconds: 500),
                    slideOffset: const Offset(0, 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: _FilterActionButton(
                            label: 'রিসেট',
                            filled: false,
                            onTap: () {
                              setState(() {
                                _selectedTime = 0;
                                _selectedStatus = 0;
                                _selectedRange = 0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FilterActionButton(
                            label: 'ফলাফল দেখুন',
                            filled: true,
                            onTap: () => Navigator.of(context).pop(
                              _HistoryFilterSelection(
                                timeIndex: _selectedTime,
                                statusIndex: _selectedStatus,
                                rangeIndex: _selectedRange,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSectionCard extends StatelessWidget {
  const _FilterSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF141F22),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FilterChoiceChip extends StatelessWidget {
  const _FilterChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF00694C) : const Color(0xFFF0F5F4),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  selected ? const Color(0xFF00694C) : const Color(0xFFD9E6E2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF3D4943),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterListTile extends StatelessWidget {
  const _FilterListTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE6F4EF) : const Color(0xFFF7FAF9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  selected ? const Color(0xFF00694C) : const Color(0xFFD9E6E2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? const Color(0xFF00694C)
                    : const Color(0xFF6F7D78),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF141F22),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
