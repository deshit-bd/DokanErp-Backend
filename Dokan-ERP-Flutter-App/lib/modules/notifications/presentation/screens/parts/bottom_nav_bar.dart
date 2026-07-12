part of '../notification_center_screen.dart';

class _BottomNavBar extends ConsumerWidget {
  const _BottomNavBar({
    required this.onHomeTap,
    required this.onSalesTap,
    required this.onProductsTap,
    required this.onReportsTap,
    required this.onMoreTap,
    required this.bottomPadding,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onSalesTap;
  final VoidCallback onProductsTap;
  final VoidCallback onReportsTap;
  final VoidCallback onMoreTap;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bottomNavBg,
        border: Border(top: BorderSide(color: AppColors.bottomNavBorder)),
      ),
      padding: EdgeInsets.fromLTRB(12, 10, 12, 8 + bottomPadding),
      child: Row(
        children: [
          _BottomNavItem(
            icon: Icons.home_outlined,
            label: AppStrings.tabHome,
            onTap: onHomeTap,
            selected: false,
          ),
          _BottomNavItem(
            icon: Icons.point_of_sale_outlined,
            label: AppStrings.tabSales,
            onTap: onSalesTap,
          ),
          _BottomNavItem(
            icon: Icons.inventory_2_outlined,
            label: AppStrings.tabProducts,
            onTap: onProductsTap,
          ),
          _BottomNavItem(
            icon: Icons.insert_chart_outlined,
            label: AppStrings.tabReports,
            onTap: onReportsTap,
          ),
          _BottomNavItem(
            icon: Icons.more_horiz_rounded,
            label: AppStrings.tabMore,
            onTap: onMoreTap,
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AppColors.bottomNavSelected : AppColors.bottomNavUnselected;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onTap,
          radius: 28,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
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

class _TopActionIcon extends StatelessWidget {
  const _TopActionIcon({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: const Color(0xFF1D2624), size: 31),
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
        selected ? const Color(0xFF00694C) : const Color(0xFFDAE1E3);
    final foreground = selected ? Colors.white : const Color(0xFF5D6466);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          constraints: const BoxConstraints(minWidth: 55, minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              height: 1.33,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationPreviewSheet extends StatelessWidget {
  const _NotificationPreviewSheet({
    required this.onSeeAll,
  });

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.34,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7FBFA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6E3E4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'সাম্প্রতিক নোটিফিকেশন',
                        style: TextStyle(
                          color: Color(0xFF17312B),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onSeeAll,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0E7B58),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'সব দেখুন',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _dokanNotificationStore,
                  builder: (context, _) {
                    final notifications =
                        _dokanNotificationStore.previewEntries(limit: 8);
                    if (notifications.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 26),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE3EAEA)),
                        ),
                        child: const Text(
                          'এখনো কোনো নোটিফিকেশন নেই',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6B7D78),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final item in notifications) ...[
                          _NotificationPreviewTile(
                            entry: item,
                            onTap: () {
                              Navigator.of(context).pop();
                              _openDokanNotification(context, item);
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationPreviewTile extends StatelessWidget {
  const _NotificationPreviewTile({
    required this.entry,
    required this.onTap,
  });

  final _NotificationEntry entry;
  final VoidCallback onTap;

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3EAEA)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: entry.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(entry.icon, color: entry.iconColor, size: 22),
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
                            entry.title,
                            style: TextStyle(
                              color: const Color(0xFF17312B),
                              fontSize: 15,
                              fontWeight: entry.unread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (entry.unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0E7B58),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5C6C68),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.timeLabel,
                      style: const TextStyle(
                        color: Color(0xFF8A9A96),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
