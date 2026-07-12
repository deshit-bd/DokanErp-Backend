part of '../product_screens.dart';

class _InventoryPageCard extends StatelessWidget {
  const _InventoryPageCard({
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
              color: Color(0xFF111111),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DrawerActionTile extends StatelessWidget {
  const _DrawerActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD9E6E2)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF00694C)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF3D4943),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF00694C)),
            ],
          ),
        ),
      ),
    );
  }
}

class DokanPopularProductsScreen extends ConsumerWidget {
  const DokanPopularProductsScreen({
    super.key,
    required this.shopName,
    required this.ownerName,
    this.onBack,
    this.onContinue,
  });

  final String shopName;
  final String ownerName;
  final VoidCallback? onBack;
  final Future<void> Function()? onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dokanPopularProductsProvider);
    final notifier = ref.read(dokanPopularProductsProvider.notifier);
    final items = notifier.items;

    if (state.isLoading && items.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _TopHeader(
                background: const Color(0xFFEAF5FB),
                leading: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back,
                      color: Color(0xFF20312D), size: 34),
                ),
                title: 'ক্যাটালগ থেকে পণ্য বেছে নিন',
                trailing: const SizedBox.shrink(),
              ),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00694C),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.errorMessage != null && items.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _TopHeader(
                background: const Color(0xFFEAF5FB),
                leading: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back,
                      color: Color(0xFF20312D), size: 34),
                ),
                title: 'ক্যাটালগ থেকে পণ্য বেছে নিন',
                trailing: const SizedBox.shrink(),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 52,
                          color: Color(0xFF7A8883),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'পণ্য লোড করা যায়নি\n${state.errorMessage}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF42504C),
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: notifier.reload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00694C),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('আবার চেষ্টা করুন'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return switch (state.stage) {
      DokanPopularFlowStage.pick =>
        _buildPickStage(context, notifier, state, items),
      DokanPopularFlowStage.stock =>
        _buildStockStage(context, notifier, state, items),
      DokanPopularFlowStage.complete =>
        _buildCompleteStage(context, notifier, state),
    };
  }

  Widget _buildPickStage(
    BuildContext context,
    DokanPopularProductsNotifier notifier,
    DokanPopularProductsState state,
    List<DokanPopularProductItem> items,
  ) {
    final visibleItems = state.selectedFilter == 'সব'
        ? items
        : items
            .where((item) =>
                item.category == state.selectedFilter || item.category == 'সব')
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _TopHeader(
              background: const Color(0xFFEAF5FB),
              leading: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back,
                    color: Color(0xFF20312D), size: 34),
              ),
              title: 'ক্যাটালগ থেকে পণ্য বেছে নিন',
              trailing: _CountPill(
                  text: '${_bengaliNumber(notifier.selectedCount)} টি বাছাই'),
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'মাস্টার ডেটা ক্যাটালগ থেকে আপনার দোকানের পণ্যগুলো বেছে নিন',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4D5A56),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 22),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: notifier.filters
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _FilterChip(
                          label: filter,
                          selected: filter == state.selectedFilter,
                          onTap: () => notifier.setFilter(filter),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  state.selectedFilter == 'সব'
                      ? 'সব বাছাই করুন'
                      : 'ফিল্টার: ${state.selectedFilter}',
                  style: const TextStyle(
                    color: Color(0xFF00694C),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFC2410C),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFC2410C),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                itemCount: visibleItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = visibleItems[index];
                  return _SelectableProductRow(
                    item: item,
                    onTap: () => notifier.toggleItem(item),
                  );
                },
              ),
            ),
            _BottomActionBar(
              icon: Icons.shopping_cart_outlined,
              text:
                  '${_bengaliNumber(notifier.selectedCount)}টি পণ্য বাছাই হয়েছে',
              buttonLabel: 'পরবর্তী ধাপ',
              onPressed: () => notifier.goToStock(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStage(
    BuildContext context,
    DokanPopularProductsNotifier notifier,
    DokanPopularProductsState state,
    List<DokanPopularProductItem> items,
  ) {
    final selectedItems = notifier.stockItems;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _TopHeader(
              background: const Color(0xFFEAF5FB),
              leading: IconButton(
                onPressed: notifier.goToPick,
                icon: const Icon(Icons.arrow_back,
                    color: Color(0xFF20312D), size: 34),
              ),
              title: 'স্টক ও দাম দিন',
              trailing: _CountPill(
                text:
                    '${_bengaliNumber(items.length)} টির মধ্যে ${_bengaliNumber(notifier.completedCount)} টি সম্পন্ন',
                smaller: true,
              ),
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'প্রতিটি পণ্যের বর্তমান স্টক, ক্রয় মূল্য ও বিক্রয় মূল্য দিন। সব তথ্য ব্যাচ ১-এ সংরক্ষণ হবে।',
                style: TextStyle(
                  color: Color(0xFF4D5A56),
                  fontSize: 17,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: notifier.goToPick,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2F6AF2),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'আরও পণ্য যোগ করুন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                itemCount: selectedItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = selectedItems[index];
                  return _StockProductCard(
                    item: item,
                    onToggle: () => notifier.toggleItem(item),
                    onBackToPick: notifier.goToPick,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  18, 0, 18, 18 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: state.isSaving
                      ? null
                      : () => notifier.goToComplete(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A59),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'সেটআপ সম্পন্ন করুন',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFC2410C),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteStage(
    BuildContext context,
    DokanPopularProductsNotifier notifier,
    DokanPopularProductsState state,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FAF6),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 12,
                  right: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: notifier.goToStockPage,
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF20312D), size: 34),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F0E3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ..._buildConfetti(),
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D865F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 72,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'দোকান সম্পূর্ণ তৈরি!',
                          style: TextStyle(
                            color: Color(0xFF0E7C57),
                            fontSize: 29,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const TextSpan(
                          text: ' 🎉',
                          style: TextStyle(fontSize: 29),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'আপনার ${_bengaliNumber(notifier.selectedCount)}টি পণ্য যোগ হয়েছে। প্রথম বিক্রয় শুরু করুন!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF55635F),
                        fontSize: 17,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE1E8E3)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'মোট পণ্য',
                      value: '${_bengaliNumber(notifier.selectedCount)}টি',
                    ),
                    const Divider(
                        height: 1, thickness: 1, color: Color(0xFFE9EEEA)),
                    _SummaryRow(
                      icon: Icons.storefront_outlined,
                      label: 'দোকানের নাম',
                      value: shopName,
                    ),
                    const Divider(
                        height: 1, thickness: 1, color: Color(0xFFE9EEEA)),
                    _SummaryRow(
                      icon: Icons.person_outline_rounded,
                      label: 'মালিকের নাম',
                      value: ownerName,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  18, 0, 18, 18 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed:
                      onContinue == null ? null : () => onContinue!.call(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E865D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'বিক্রয় শুরু করুন',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.arrow_forward_rounded, size: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConfetti() {
    const colors = [
      Color(0xFF2AA57D),
      Color(0xFF8CE2B7),
      Colors.white,
      Color(0xFF0E7C57),
    ];
    final positions = <Offset>[
      const Offset(-48, -50),
      const Offset(-28, -30),
      const Offset(10, -44),
      const Offset(38, -20),
      const Offset(-60, 8),
      const Offset(-26, 34),
      const Offset(18, 32),
      const Offset(56, 12),
      const Offset(-44, 58),
      const Offset(30, 54),
      const Offset(66, -42),
    ];

    return List.generate(positions.length, (index) {
      return Positioned(
        left: 74 + positions[index].dx,
        top: 74 + positions[index].dy,
        child: Transform.rotate(
          angle: (index % 3) * 0.22,
          child: Container(
            width: index.isEven ? 12 : 8,
            height: index.isEven ? 12 : 8,
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              borderRadius: BorderRadius.circular(index.isEven ? 4 : 999),
            ),
          ),
        ),
      );
    });
  }

  String _bengaliNumber(int value) {
    if (AppStrings.activeLanguage == AppLanguage.english) {
      return value.toString();
    }
    const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return value.toString().split('').map((char) {
      final index = int.tryParse(char);
      return index == null ? char : digits[index];
    }).join();
  }
}
