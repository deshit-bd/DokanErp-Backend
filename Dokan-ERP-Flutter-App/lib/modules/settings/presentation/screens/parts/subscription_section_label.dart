part of '../settings_screens.dart';

class _SubscriptionSectionLabel extends StatelessWidget {
  const _SubscriptionSectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF5A6B69),
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _CurrentPlanSummaryCard extends StatelessWidget {
  const _CurrentPlanSummaryCard({
    required this.info,
    required this.accent,
    required this.accentDeep,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
    required this.onPrimaryAction,
    required this.onUpgrade,
  });

  final SubscriptionInfo info;
  final Color accent;
  final Color accentDeep;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onPrimaryAction;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final isTrial = info.tier == 'TRIAL';
    final planName = isTrial ? 'ফ্রি ট্রায়াল' : 'পে-অ্যাজ-ইউ-গো';
    final planSubtitle = isTrial
        ? 'নতুন দোকানের জন্য ফ্রি ট্রায়াল'
        : 'সক্রিয় সেলসম্যান অনুযায়ী প্রতিদিনের সার্ভিস ফি';

    final trialEndsStr = () {
      try {
        if (info.trialEndsAt.isEmpty) return 'চলমান';
        final dt = DateTime.parse(info.trialEndsAt);
        final remaining = dt.difference(DateTime.now());
        if (remaining.isNegative) {
          return 'মেয়াদ উত্তীর্ণ';
        }
        if (remaining.inHours > 24) {
          return '${trNum(remaining.inDays)} দিন বাকি';
        }
        return '${trNum(remaining.inHours)} ঘণ্টা বাকি';
      } catch (_) {
        return 'চলমান';
      }
    }();

    final rateStr =
        isTrial ? '৳০' : '৳${trNum(info.ratePerAccount.toInt())} / দিন';
    final durationStr = isTrial ? trialEndsStr : 'চলমান';
    final productLimitStr = isTrial ? '৫০' : 'অসীম';
    final userLimitStr =
        isTrial ? '১ জন' : '${trNum(info.billableAccounts)} জন';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[accent, accentDeep],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220B5B40),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'বর্তমান প্ল্যান',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        planName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        planSubtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
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
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SubscriptionMetricPill(label: 'মূল্য', value: rateStr),
                _SubscriptionMetricPill(label: 'মেয়াদ', value: durationStr),
                _SubscriptionMetricPill(
                    label: 'পণ্য সীমা', value: productLimitStr),
                _SubscriptionMetricPill(
                    label: 'ইউজার সীমা', value: userLimitStr),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPrimaryAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.36)),
                      backgroundColor: Colors.white.withOpacity(0.08),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'প্ল্যান দেখুন',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onUpgrade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: accentDeep,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      info.amountDue > 0 ? 'বকেয়া পরিশোধ' : 'আপগ্রেড করুন',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                    info.amountDue > 0
                        ? Icons.warning_amber_rounded
                        : Icons.verified_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(0.9)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    info.amountDue > 0
                        ? 'আপনার ৳${trNum(info.amountDue.toInt())} বকেয়া রয়েছে। সেবা সচল রাখতে পরিশোধ করুন।'
                        : (isTrial
                            ? 'ফ্রি ট্রায়াল সক্রিয় রয়েছে। ফিচারের সীমা বাড়াতে আপগ্রেড করুন।'
                            : 'আপনার সাবস্ক্রিপশন সচল এবং সক্রিয় রয়েছে।'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
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

class _SubscriptionMetricPill extends StatelessWidget {
  const _SubscriptionMetricPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionPlanCard extends StatelessWidget {
  const _SubscriptionPlanCard({
    required this.data,
    required this.accent,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
    required this.onViewPlan,
    required this.onUpgrade,
  });

  final _SubscriptionPlanData data;
  final Color accent;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onViewPlan;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final isCurrent = data.current;
    final isPopular = data.popular;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onViewPlan,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCurrent ? accent.withOpacity(0.28) : borderColor,
              width: isCurrent ? 1.4 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0E21413C),
                blurRadius: 18,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: data.iconBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(data.icon, color: data.iconColor, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data.name,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (isCurrent || isPopular)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? data.badgeColor
                                        : data.badgeColor,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    data.badge,
                                    style: TextStyle(
                                      color: data.badgeTextColor,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.subtitle,
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 12.5,
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data.price,
                      style: TextStyle(
                        color: isCurrent ? accent : textColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        data.priceSuffix,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...data.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _SubscriptionFeatureRow(
                      text: feature,
                      accent: accent,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: isCurrent
                      ? OutlinedButton(
                          onPressed: onViewPlan,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accent,
                            side: BorderSide(color: accent.withOpacity(0.28)),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'বর্তমান প্ল্যান',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: onUpgrade,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isPopular ? accent : const Color(0xFF1A8F63),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: Text(
                            data.upgradeLabel,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
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
