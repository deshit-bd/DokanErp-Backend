part of '../settings_screens.dart';

class _InventoryModeOptionCard extends StatelessWidget {
  const _InventoryModeOptionCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final _InventoryModeType mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? const Color(0xFF0E8F5F) : const Color(0xFFE3EBE8);
    final background = selected ? const Color(0xFFF1FBF6) : Colors.white;
    final shadowColor =
        selected ? const Color(0x200B5B40) : const Color(0x0C21413C);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent, width: selected ? 1.8 : 1),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: selected ? 22 : 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF0E8F5F)
                          : const Color(0xFFEAF5F1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      mode.icon,
                      color: selected ? Colors.white : const Color(0xFF0E8F5F),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                mode.title,
                                style: const TextStyle(
                                  color: Color(0xFF16302E),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF0E8F5F)
                                    : const Color(0xFFEAF5F1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                selected ? 'নির্বাচিত' : 'নির্বাচন করুন',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF0E8F5F),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mode.description,
                          style: const TextStyle(
                            color: Color(0xFF516462),
                            fontSize: 13.5,
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
              Text(
                mode.summary,
                style: const TextStyle(
                  color: Color(0xFF16302E),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ...mode.benefits.map(
                (benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 18, color: Color(0xFF0E8F5F)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: const TextStyle(
                            color: Color(0xFF516462),
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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

class DokanStoreLayoutManagementScreen extends ConsumerStatefulWidget {
  const DokanStoreLayoutManagementScreen({super.key});

  static const Color _bg = Color(0xFFF3F7FA);
  static const Color _text = Color(0xFF142D2A);
  static const Color _muted = Color(0xFF6B7D78);
  static const Color _accent = Color(0xFF0E8F5F);
  static const Color _danger = Color(0xFFC2410C);
  static const Color _warning = Color(0xFFB45309);
  static const Color _cardBorder = Color(0xFFE1E9E7);

  @override
  ConsumerState<DokanStoreLayoutManagementScreen> createState() =>
      _DokanStoreLayoutManagementScreenState();
}

class _DokanStoreLayoutManagementScreenState
    extends ConsumerState<DokanStoreLayoutManagementScreen> {
  _StoreZoneData? _selectedZone;
  bool _isLoading = false;
  bool _isUsingOfflineSnapshot = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLayoutTree();
    });
  }

  Future<void> _loadLayoutTree() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(inventoryLayoutRepositoryProvider);
      final data = await repo.getLayoutTree();
      final usingOfflineSnapshot = data['_isOfflineCache'] == true;
      final List<dynamic> zonesJson = data['zones'] ?? [];

      final List<_StoreZoneData> loadedZones = [];
      for (final z in zonesJson) {
        final List<_StoreRackData> racks = [];
        for (final r in z['racks'] ?? []) {
          final List<_StoreShelfData> shelves = [];
          for (final s in r['shelves'] ?? []) {
            final List<_StoreBinData> bins = [];
            for (final b in s['bins'] ?? []) {
              bins.add(_StoreBinData(
                id: b['id'],
                code: b['code'],
                quantity: b['quantity'] ?? 0,
                rackName: b['rackName'] ?? '',
                shelfName: b['shelfName'] ?? '',
              ));
            }
            shelves.add(_StoreShelfData(
              id: s['id'],
              name: s['name'],
              direction: s['direction'] ?? 'উপরের সারি',
              bins: bins,
            ));
          }
          racks.add(_StoreRackData(
            id: r['id'],
            name: r['name'],
            shelves: shelves,
          ));
        }
        loadedZones.add(_StoreZoneData(
          id: z['id'],
          name: z['name'],
          racks: racks,
        ));
      }

      if (!mounted) return;
      setState(() {
        _storeZones = loadedZones;
        _isUsingOfflineSnapshot = usingOfflineSnapshot;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isUsingOfflineSnapshot = false;
        _errorMessage = 'লেআউট ডাটা লোড করতে ব্যর্থ হয়েছে';
      });
    }
  }

  void _refresh() => _loadLayoutTree();

  void _guardWriteAction(VoidCallback action) {
    if (_isUsingOfflineSnapshot) {
      _showInventoryWriteUnavailableMessage(context);
      return;
    }
    action();
  }

  @override
  Widget build(BuildContext context) {
    final zones = _storeZones;
    final lowStockBins = _lowStockBins;
    final contentWidth = MediaQuery.of(context).size.width > 980
        ? 980.0
        : MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: DokanStoreLayoutManagementScreen._bg,
      appBar: AppBar(
        backgroundColor: DokanStoreLayoutManagementScreen._bg,
        surfaceTintColor: DokanStoreLayoutManagementScreen._bg,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: DokanStoreLayoutManagementScreen._text,
            ),
          ),
        ),
        leadingWidth: 72,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'স্টোর লেআউট',
              style: TextStyle(
                color: DokanStoreLayoutManagementScreen._text,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'জোন, র‍্যাক, শেলফ এবং বিন ম্যানেজ করুন',
              style: TextStyle(
                color: DokanStoreLayoutManagementScreen._muted,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: DokanStoreLayoutManagementScreen._accent))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                DokanStoreLayoutManagementScreen._accent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _loadLayoutTree,
                          child: const Text('পুনরায় চেষ্টা করুন'),
                        ),
                      ],
                    ),
                  )
                : CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: contentWidth),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _StoreLayoutHeroCard(
                                    accent: DokanStoreLayoutManagementScreen
                                        ._accent,
                                    textColor:
                                        DokanStoreLayoutManagementScreen._text,
                                    mutedColor:
                                        DokanStoreLayoutManagementScreen._muted,
                                  ),
                                  const SizedBox(height: 14),
                                  if (_isUsingOfflineSnapshot) ...[
                                    const _InventoryOfflineNotice(),
                                    const SizedBox(height: 14),
                                  ],
                                  const _StoreLayoutBreadcrumb(
                                    steps: ['হোম', 'স্টোর লেআউট', 'জোন'],
                                  ),
                                  const SizedBox(height: 14),
                                  if (lowStockBins.isNotEmpty) ...[
                                    _StoreLayoutSectionCard(
                                      title: 'কম স্টক সতর্কতা',
                                      subtitle:
                                          '${lowStockBins.length}টি বিনে স্টক কম (১০ এর নিচে)',
                                      accent: DokanStoreLayoutManagementScreen
                                          ._danger,
                                      child: Column(
                                        children: [
                                          for (final bin in lowStockBins) ...[
                                            _StoreLayoutAlertRow(
                                              binCode: bin.code,
                                              location: bin.locationPath,
                                              quantity: bin.quantity,
                                              onTap: () => _showContextMenu(
                                                context,
                                                ref,
                                                type: 'Bin',
                                                item: bin,
                                                onChanged: _refresh,
                                                readOnly:
                                                    _isUsingOfflineSnapshot,
                                              ),
                                            ),
                                            if (bin != lowStockBins.last)
                                              const SizedBox(height: 10),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                  _StoreLayoutSectionCard(
                                    title: 'জোন লিস্ট',
                                    subtitle: 'দোকানের প্রধান জোনসমূহ',
                                    accent: DokanStoreLayoutManagementScreen
                                        ._accent,
                                    child: Column(
                                      children: [
                                        if (zones.isEmpty)
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 24),
                                            child: Text(
                                                'কোনো জোন পাওয়া যায়নি। একটি নতুন জোন যোগ করুন।'),
                                          )
                                        else
                                          for (final zone in zones) ...[
                                            _buildZoneCard(context, zone),
                                            if (zone != zones.last)
                                              const SizedBox(height: 12),
                                          ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _StoreLayoutSectionCard(
                                    title: 'কুইক অ্যাকশন',
                                    subtitle: 'দ্রুত CRUD এন্ট্রি পয়েন্ট',
                                    accent: DokanStoreLayoutManagementScreen
                                        ._accent,
                                    child: Column(
                                      children: [
                                        _StoreLayoutActionCard(
                                          icon: Icons.add_location_alt_rounded,
                                          title: 'জোন ম্যানেজ করুন',
                                          subtitle:
                                              'নতুন জোন তৈরি বা আপডেট করুন',
                                          onTap: () => _guardWriteAction(
                                            () => _showAddEditBottomSheet(
                                              context,
                                              type: 'Zone',
                                              onSaved: _refresh,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _StoreLayoutActionCard(
                                          icon: Icons.view_module_rounded,
                                          title: 'র‍্যাক ম্যানেজ করুন',
                                          subtitle:
                                              'জোনের অধীনে র‍্যাক কনফিগার করুন',
                                          onTap: () => _guardWriteAction(
                                            () => _showAddEditBottomSheet(
                                              context,
                                              type: 'Rack',
                                              onSaved: _refresh,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _StoreLayoutActionCard(
                                          icon: Icons.layers_rounded,
                                          title: 'শেলফ ম্যানেজ করুন',
                                          subtitle:
                                              'র‍্যাকের ভিতরে শেলফ সেট করুন',
                                          onTap: () => _guardWriteAction(
                                            () => _showAddEditBottomSheet(
                                              context,
                                              type: 'Shelf',
                                              onSaved: _refresh,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _StoreLayoutActionCard(
                                          icon: Icons.archive_rounded,
                                          title: 'বিন ম্যানেজ করুন',
                                          subtitle:
                                              'বিন কোড ও স্টক লোকেশন নিয়ন্ত্রণ করুন',
                                          onTap: () => _guardWriteAction(
                                            () => _showAddEditBottomSheet(
                                              context,
                                              type: 'Bin',
                                              onSaved: _refresh,
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
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _guardWriteAction(
          () => _showAddEditBottomSheet(
            context,
            type: 'Zone',
            onSaved: _refresh,
          ),
        ),
        backgroundColor: DokanStoreLayoutManagementScreen._accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('জোন যোগ করুন',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildZoneCard(BuildContext context, _StoreZoneData zone) {
    return _StoreLayoutItemCard(
      title: Text(
        zone.name,
        style: const TextStyle(
          color: DokanStoreLayoutManagementScreen._text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        '${zone.racks.length}টি র‍্যাক · ${zone.totalStock} পিস স্টক',
        style: const TextStyle(
          color: DokanStoreLayoutManagementScreen._muted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: Icons.my_location_rounded,
      iconColor: DokanStoreLayoutManagementScreen._accent,
      iconBgColor: DokanStoreLayoutManagementScreen._accent.withOpacity(0.12),
      isSelected: _selectedZone == zone,
      onTap: () async {
        setState(() {
          _selectedZone = zone;
        });
        await Future.delayed(const Duration(milliseconds: 250));
        if (!context.mounted) return;
        await Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => _DokanStoreRackListScreen(
                  zone: zone,
                  isReadOnly: _isUsingOfflineSnapshot,
                ),
              ),
            )
            .then((_) => _refresh());
        setState(() {
          _selectedZone = null;
        });
      },
      onMorePressed: () => _showContextMenu(
        context,
        ref,
        type: 'Zone',
        item: zone,
        onChanged: _refresh,
        readOnly: _isUsingOfflineSnapshot,
      ),
    );
  }
}
