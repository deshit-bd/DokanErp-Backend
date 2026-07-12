part of '../settings_screens.dart';

class _SubscriptionFeatureRow extends StatelessWidget {
  const _SubscriptionFeatureRow({
    required this.text,
    required this.accent,
    required this.textColor,
    required this.mutedColor,
  });

  final String text;
  final Color accent;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            color: accent,
            size: 12,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubscriptionHistoryCard extends StatelessWidget {
  const _SubscriptionHistoryCard({
    required this.data,
    required this.textColor,
    required this.mutedColor,
    required this.borderColor,
  });

  final _SubscriptionHistoryData data;
  final Color textColor;
  final Color mutedColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C21413C),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: data.statusColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: data.statusTextColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.planName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.date,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
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
                  data.amount,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: data.statusColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    data.status,
                    style: TextStyle(
                      color: data.statusTextColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionSupportCard extends StatelessWidget {
  const _SubscriptionSupportCard({
    required this.accent,
    required this.accentDeep,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
  });

  final Color accent;
  final Color accentDeep;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C21413C),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        accent.withOpacity(0.16),
                        accentDeep.withOpacity(0.12)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      Icon(Icons.headset_mic_rounded, color: accent, size: 25),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'সহজে সাহায্য নিন',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'প্ল্যান, বিলিং, বা আপগ্রেড সংক্রান্ত যেকোনো প্রশ্নে আমাদের টিম পাশে আছে।',
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12.8,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DokanHelpSupportScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: const Text(
                      'গাইড দেখুন',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(color: borderColor),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DokanHelpSupportScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.support_agent_rounded, size: 18),
                    label: const Text(
                      'সাপোর্ট',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanDetailsSheet extends StatelessWidget {
  const _PlanDetailsSheet({required this.plan});

  final _SubscriptionPlanData plan;

  @override
  Widget build(BuildContext context) {
    final premium = plan.name.contains('প্রিমিয়াম');
    final themeColor =
        premium ? const Color(0xFF4A6CF7) : const Color(0xFF0E8F5F);
    final bgColor = premium ? const Color(0xFFEAF0FF) : const Color(0xFFEAF5F1);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.72,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9E2E0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: premium
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4A6CF7), Color(0xFF2346C7)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0E8F5F), Color(0xFF0A7A52)],
                        ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(plan.icon, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                plan.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.92),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _PlanDetailsChip(
                          label: plan.name.contains('ট্রায়াল')
                              ? 'মূল্য'
                              : 'সার্ভিস ফি',
                          value: plan.name.contains('ট্রায়াল')
                              ? '৳০'
                              : '৳১০ / দিন',
                          dark: true,
                        ),
                        const SizedBox(width: 10),
                        _PlanDetailsChip(
                          label: 'স্ট্যাটাস',
                          value: plan.current ? 'বর্তমান' : 'আপগ্রেড',
                          dark: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionTitle(title: 'ফিচার তুলনা'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE3EBE8)),
                ),
                child: Column(
                  children: plan.features
                      .map(
                        (feature) => Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Icon(Icons.check_rounded,
                                        size: 15, color: themeColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: const TextStyle(
                                        color: Color(0xFF16302E),
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (feature != plan.features.last)
                              const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF1F5F4)),
                          ],
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: 18),
              _SectionTitle(title: 'প্ল্যান সারাংশ'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE3EBE8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _PlanSummaryRow(label: 'প্ল্যান নাম', value: plan.name),
                      const SizedBox(height: 10),
                      _PlanSummaryRow(
                        label: 'মূল্য',
                        value: plan.name.contains('ট্রায়াল')
                            ? '৳০'
                            : '৳১০ / দিন (প্রতি সেলসম্যান)',
                      ),
                      const SizedBox(height: 10),
                      _PlanSummaryRow(
                        label: 'বিবরণ',
                        value: plan.name.contains('ট্রায়াল')
                            ? '১ দিন মেয়াদী ফ্রি ট্রায়াল'
                            : 'সক্রিয় সেলসম্যান অনুযায়ী প্রতিদিনের সার্ভিস ফি',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    plan.current ? 'প্ল্যানটি ব্যবহার হচ্ছে' : 'চেকআউটে যান',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}
