part of '../settings_screens.dart';

class _StoreLayoutHeroCard extends StatelessWidget {
  const _StoreLayoutHeroCard({
    required this.accent,
    required this.textColor,
    required this.mutedColor,
  });

  final Color accent;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E8F5F), Color(0xFF0A6F4A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220B5B40),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.dashboard_customize_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'দোকানের ইনভেন্টরি হায়ারার্কি',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Zone থেকে Bin পর্যন্ত সমস্ত লোকেশন এক নজরে দেখুন এবং drill-down করুন।',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(999),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Advanced Inventory Mode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(999),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded,
                              size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Real-time tracking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreLayoutItemCard extends StatelessWidget {
  const _StoreLayoutItemCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
    required this.onMorePressed,
    this.isSelected = false,
    this.trailing,
  });

  final Widget title;
  final Widget subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;
  final VoidCallback onMorePressed;
  final bool isSelected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    const activeColor = DokanStoreLayoutManagementScreen._accent;
    const cardBorderColor = DokanStoreLayoutManagementScreen._cardBorder;
    final trailingWidget = trailing;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform:
          isSelected ? Matrix4.translationValues(8, 0, 0) : Matrix4.identity(),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFFDFEFE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? activeColor : cardBorderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x1A0E8F5F),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                )
              ]
            : const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withOpacity(0.15)
                        : iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      Icon(icon, color: isSelected ? activeColor : iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 6),
                      subtitle,
                    ],
                  ),
                ),
                if (trailingWidget != null)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: IntrinsicWidth(
                        child: trailingWidget,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.more_vert_rounded,
                          color: DokanStoreLayoutManagementScreen._muted),
                      onPressed: onMorePressed,
                    ),
                  ),
                ),
                if (trailingWidget == null)
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF8A9896)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreLayoutBreadcrumb extends StatelessWidget {
  const _StoreLayoutBreadcrumb({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _StoreLayoutMiniChip(
            label: steps[i],
            icon: i == 0 ? Icons.home_rounded : Icons.chevron_right_rounded,
            color: i == 0
                ? DokanStoreLayoutManagementScreen._accent
                : DokanStoreLayoutManagementScreen._muted,
          ),
        ],
      ],
    );
  }
}

class _StoreLayoutSectionCard extends StatelessWidget {
  const _StoreLayoutSectionCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DokanStoreLayoutManagementScreen._cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C21413C),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: accent, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF142D2A),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF6B7D78),
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
