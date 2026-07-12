part of '../product_screens.dart';

class _ProductBottomNav extends ConsumerWidget {
  const _ProductBottomNav({
    required this.selectedIndex,
    // ignore: unused_element
    VoidCallback? onHomeTap,
    VoidCallback? onSalesTap,
    VoidCallback? onProductsTap,
    VoidCallback? onReportsTap,
    VoidCallback? onMoreTap,
  });
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
            _ProductNavItem(
              icon: Icons.home_outlined,
              label: AppStrings.tabHome,
              selected: selectedIndex == 0,
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
            _ProductNavItem(
              icon: Icons.point_of_sale_outlined,
              label: AppStrings.tabSales,
              selected: selectedIndex == 1,
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.sales),
            ),
            _ProductNavItem(
              icon: Icons.inventory_2_outlined,
              label: AppStrings.tabProducts,
              selected: selectedIndex == 2,
              onTap: () {},
            ),
            _ProductNavItem(
              icon: Icons.bar_chart_outlined,
              label: AppStrings.tabReports,
              selected: selectedIndex == 3,
              onTap: () => Navigator.of(context).pushReplacementNamed(
                AppRoutes.reports,
              ),
            ),
            _ProductNavItem(
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

class _ProductNavItem extends StatelessWidget {
  const _ProductNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AppColors.bottomNavSelected : AppColors.bottomNavUnselected;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: context.sizeBodySmall,
                    fontWeight: FontWeight.w800,
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

class _DetailMiniInfo extends StatelessWidget {
  const _DetailMiniInfo({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF5F6A66),
              fontSize: context.sizeBodySmall,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF141F22),
              fontSize: context.sizeSubHeader,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF141F22),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF5F6A66),
            fontSize: context.sizeBodyMedium,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: context.sizeBodyLarge,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SalesMetricCard extends StatelessWidget {
  const _SalesMetricCard({
    required this.title,
    required this.value,
    this.emphasis = false,
  });

  final String title;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: emphasis ? const Color(0xFFEAF7F0) : const Color(0xFFF4F8F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF5F6A66),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color:
                  emphasis ? const Color(0xFF0C8C67) : const Color(0xFF141F22),
              fontSize: emphasis ? 22 : 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockHistoryTile extends StatelessWidget {
  const _StockHistoryTile({required this.entry});

  final _ProductHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final icon = entry.amount.startsWith('+')
        ? Icons.add
        : entry.amount.startsWith('-')
            ? Icons.remove
            : Icons.sync;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: entry.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: entry.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.label} ${entry.amount}',
                  style: const TextStyle(
                    color: Color(0xFF141F22),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.timeLabel,
                  style: const TextStyle(
                    color: Color(0xFF6F7D78),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6F7D78), size: 24),
        ],
      ),
    );
  }
}

class DokanProductEditScreen extends StatelessWidget {
  const DokanProductEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DokanProductListScreen();
  }
}

class DokanCustomProductAddScreen extends ConsumerWidget {
  const DokanCustomProductAddScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DokanNewProductAddScreen(
      existingBarcodes: ref
          .watch(dokanInventoryCatalogProvider)
          .map((product) => product.barcode)
          .toSet(),
    );
  }
}
