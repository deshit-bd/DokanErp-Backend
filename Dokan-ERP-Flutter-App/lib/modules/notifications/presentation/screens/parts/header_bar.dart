part of '../notification_center_screen.dart';

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.onBack,
    required this.onMarkAllRead,
  });

  final VoidCallback onBack;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: Row(
        children: [
          _TopActionIcon(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Center(
              child: Text(
                'নোটিফিকেশন',
                style: TextStyle(
                  color: Color(0xFF00694C),
                  fontSize: 26,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onMarkAllRead,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF00694C),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'সব পড়া হয়েছে',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterStrip extends StatelessWidget {
  const _FilterStrip({
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_FilterChipData> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF1FBFF),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (var i = 0; i < filters.length; i++) ...[
              _FilterChip(
                label: filters[i].label,
                selected: i == selectedIndex,
                onTap: () => onSelected(i),
              ),
              if (i != filters.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationGroupView extends StatelessWidget {
  const _NotificationGroupView({
    required this.group,
    required this.onItemTap,
  });

  final _NotificationGroup group;
  final ValueChanged<_NotificationEntry> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            group.title,
            style: TextStyle(
              color: group.style.headingColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              height: 1,
            ),
          ),
        ),
        if (group.style == _SectionStyle.primary)
          _PrimaryNotificationPanel(
            items: group.items,
            onItemTap: onItemTap,
          )
        else
          _SecondaryNotificationList(
            items: group.items,
            onItemTap: onItemTap,
          ),
      ],
    );
  }
}

class _PrimaryNotificationPanel extends StatelessWidget {
  const _PrimaryNotificationPanel({
    required this.items,
    required this.onItemTap,
  });

  final List<_NotificationEntry> items;
  final ValueChanged<_NotificationEntry> onItemTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4FAF7),
          border: Border(
            left: BorderSide(color: Color(0xFF00694C), width: 3),
          ),
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _NotificationRow(
                item: items[i],
                style: _RowStyle.primary,
                onTap: () => onItemTap(items[i]),
              ),
              if (i != items.length - 1)
                const Divider(
                    height: 1, thickness: 1, color: Color(0xFF131D21)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecondaryNotificationList extends StatelessWidget {
  const _SecondaryNotificationList({
    required this.items,
    required this.onItemTap,
  });

  final List<_NotificationEntry> items;
  final ValueChanged<_NotificationEntry> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _NotificationRow(
            item: items[i],
            style: _RowStyle.secondary,
            onTap: () => onItemTap(items[i]),
          ),
          if (i != items.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFB7C7BF)),
            ),
        ],
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.item,
    required this.style,
    required this.onTap,
  });

  final _NotificationEntry item;
  final _RowStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: style.backgroundColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: style.titleColor,
                          fontSize: 16,
                          fontWeight:
                              item.unread ? FontWeight.w700 : FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          color: style.subtitleColor,
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.timeLabel,
                        style: TextStyle(
                          color: style.timeColor,
                          fontSize: 12,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (item.unread)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.accent,
                      shape: BoxShape.circle,
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

class _UpdatePromoCard extends StatelessWidget {
  const _UpdatePromoCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 246),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B9A74), Color(0xFF0A7E5F)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -4,
                bottom: -6,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 150,
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
              Positioned(
                right: 24,
                top: 22,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                      width: 2,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    const Text(
                      'নতুন আপডেট!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const SizedBox(
                      width: 252,
                      child: Text(
                        'এখন আরও দ্রুত নোটিফিকেশন দেখা, পড়া এবং ফিল্টার করা যাবে।',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF005B44),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'এখন দেখুন',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
