part of '../settings_screens.dart';

class _UnitCategoryStore {
  final categories = <_CategoryData>[
    _CategoryData(bangla: 'মুদি', english: 'Grocery'),
    _CategoryData(bangla: 'পানীয়', english: 'Drinks'),
    _CategoryData(bangla: 'স্ন্যাকস', english: 'Snacks'),
    _CategoryData(bangla: 'ডেইরি', english: 'Dairy'),
    _CategoryData(bangla: 'বেকারি', english: 'Bakery'),
    _CategoryData(bangla: 'পার্সোনাল কেয়ার', english: 'Personal Care'),
    _CategoryData(bangla: 'গৃহস্থালি', english: 'Household'),
  ];

  final units = <_UnitData>[
    _UnitData(bangla: 'পিস', english: 'Piece'),
    _UnitData(bangla: 'কেজি', english: 'KG'),
    _UnitData(bangla: 'গ্রাম', english: 'Gram'),
    _UnitData(bangla: 'লিটার', english: 'Liter'),
    _UnitData(bangla: 'মিলি', english: 'ML'),
    _UnitData(bangla: 'ডজন', english: 'Dozen'),
    _UnitData(bangla: 'বান্ডিল', english: 'Bundle'),
    _UnitData(bangla: 'বাক্স', english: 'Box'),
  ];
}

class _CategoryData {
  String bangla;
  String english;
  _CategoryData({required this.bangla, required this.english});
}

class _UnitData {
  String bangla;
  String english;
  _UnitData({required this.bangla, required this.english});
}

// ─── Main Screen ──────────────────────────────────────────────────────────────

class DokanUnitCategoryScreen extends ConsumerStatefulWidget {
  const DokanUnitCategoryScreen({super.key});

  @override
  ConsumerState<DokanUnitCategoryScreen> createState() =>
      _DokanUnitCategoryScreenState();
}

class _DokanUnitCategoryScreenState
    extends ConsumerState<DokanUnitCategoryScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _text = Color(0xFF16302E);
  static const Color _muted = Color(0xFF6F8280);
  static const Color _accent = Color(0xFF0E8F5F);
  static const Color _border = Color(0xFFE3EBE8);

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: _bg,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _text,
            ),
          ),
        ),
        leadingWidth: 72,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ইউনিট ও ক্যাটেগরি',
              style: TextStyle(
                  color: _text, fontSize: 19, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 3),
            Text(
              'ইউনিট এবং ক্যাটেগরি ম্যানেজ করুন',
              style: TextStyle(
                  color: _muted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.25),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: _muted,
                labelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                padding: const EdgeInsets.all(3),
                tabs: const [
                  Tab(text: 'ক্যাটেগরি'),
                  Tab(text: 'ইউনিট'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryListTab(onRefresh: () => setState(() {})),
          _UnitListTab(onRefresh: () => setState(() {})),
        ],
      ),
    );
  }
}

// ─── Category Tab ─────────────────────────────────────────────────────────────

class _CategoryListTab extends ConsumerStatefulWidget {
  const _CategoryListTab({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  ConsumerState<_CategoryListTab> createState() => _CategoryListTabState();
}

class _CategoryListTabState extends ConsumerState<_CategoryListTab> {
  void _refresh() {
    ref.invalidate(dokanCategoryListProvider);
    widget.onRefresh();
  }

  void _showAddEdit([DokanCategory? existing]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AddEditCategorySheet(existing: existing, onSaved: _refresh),
    );
  }

  Future<void> _confirmDelete(DokanCategory item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text('মুছে ফেলবেন?',
            style: TextStyle(
                color: Color(0xFF16302E), fontWeight: FontWeight.w800)),
        content: Text('"${item.name}" ক্যাটেগরিটি মুছে দেওয়া হবে।',
            style: const TextStyle(color: Color(0xFF6F8280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                const Text('বাতিল', style: TextStyle(color: Color(0xFF6F8280))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('মুছুন',
                style: TextStyle(
                    color: Color(0xFFE15241), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await ref
            .read(dokanCategoryListProvider.notifier)
            .deleteCategory(item.id);
        _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(dokanCategoryListProvider);

    return categoriesAsync.when(
      data: (cats) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverSafeArea(
              sliver: SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DokanFadeSlideIn(
                        delay: const Duration(milliseconds: 30),
                        duration: const Duration(milliseconds: 400),
                        slideOffset: const Offset(0, 15),
                        child: _UCHeaderCard(
                          count: cats.length,
                          countSuffix: 'টি ক্যাটেগরি',
                          icon: Icons.category_rounded,
                          onAdd: () => _showAddEdit(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (cats.isEmpty)
                        DokanFadeSlideIn(
                          delay: const Duration(milliseconds: 70),
                          duration: const Duration(milliseconds: 400),
                          slideOffset: const Offset(0, 15),
                          child: const _UCEmptyState(
                            icon: Icons.category_outlined,
                            message: 'কোনো ক্যাটেগরি নেই। নতুন যোগ করুন।',
                          ),
                        )
                      else
                        DokanFadeSlideIn(
                          delay: const Duration(milliseconds: 70),
                          duration: const Duration(milliseconds: 400),
                          slideOffset: const Offset(0, 15),
                          child: _UCList(
                            items: cats,
                            iconColor: const Color(0xFF0E8F5F),
                            icon: Icons.label_rounded,
                            onEdit: _showAddEdit,
                            onDelete: _confirmDelete,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('ত্রুটি ঘটেছে: $err')),
    );
  }
}

// ─── Unit Tab ─────────────────────────────────────────────────────────────────

class _UnitListTab extends ConsumerStatefulWidget {
  const _UnitListTab({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  ConsumerState<_UnitListTab> createState() => _UnitListTabState();
}

class _UnitListTabState extends ConsumerState<_UnitListTab> {
  void _refresh() {
    ref.invalidate(dokanUnitListProvider);
    widget.onRefresh();
  }

  void _showAddEdit([DokanUnit? existing]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEditUnitSheet(existing: existing, onSaved: _refresh),
    );
  }

  Future<void> _confirmDelete(DokanUnit item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text('মুছে ফেলবেন?',
            style: TextStyle(
                color: Color(0xFF16302E), fontWeight: FontWeight.w800)),
        content: Text('"${item.name}" ইউনিটটি মুছে দেওয়া হবে।',
            style: const TextStyle(color: Color(0xFF6F8280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                const Text('বাতিল', style: TextStyle(color: Color(0xFF6F8280))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('মুছুন',
                style: TextStyle(
                    color: Color(0xFFE15241), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await ref.read(dokanUnitListProvider.notifier).deleteUnit(item.id);
        _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(dokanUnitListProvider);

    return unitsAsync.when(
      data: (units) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverSafeArea(
              sliver: SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DokanFadeSlideIn(
                        delay: const Duration(milliseconds: 30),
                        duration: const Duration(milliseconds: 400),
                        slideOffset: const Offset(0, 15),
                        child: _UCHeaderCard(
                          count: units.length,
                          countSuffix: 'টি ইউনিট',
                          icon: Icons.straighten_rounded,
                          onAdd: () => _showAddEdit(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (units.isEmpty)
                        DokanFadeSlideIn(
                          delay: const Duration(milliseconds: 70),
                          duration: const Duration(milliseconds: 400),
                          slideOffset: const Offset(0, 15),
                          child: const _UCEmptyState(
                            icon: Icons.straighten_outlined,
                            message: 'কোনো ইউনিট নেই। নতুন যোগ করুন।',
                          ),
                        )
                      else
                        DokanFadeSlideIn(
                          delay: const Duration(milliseconds: 70),
                          duration: const Duration(milliseconds: 400),
                          slideOffset: const Offset(0, 15),
                          child: _UCList(
                            items: units,
                            iconColor: Colors.blue,
                            icon: Icons.scale_rounded,
                            onEdit: _showAddEdit,
                            onDelete: _confirmDelete,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('ত্রুটি ঘটেছে: $err')),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────
