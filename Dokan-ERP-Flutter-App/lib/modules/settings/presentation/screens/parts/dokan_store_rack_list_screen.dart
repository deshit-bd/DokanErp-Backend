part of '../settings_screens.dart';

class _DokanStoreRackListScreen extends ConsumerStatefulWidget {
  const _DokanStoreRackListScreen({
    required this.zone,
    required this.isReadOnly,
  });
  final _StoreZoneData zone;
  final bool isReadOnly;

  @override
  ConsumerState<_DokanStoreRackListScreen> createState() =>
      _DokanStoreRackListScreenState();
}

class _DokanStoreRackListScreenState
    extends ConsumerState<_DokanStoreRackListScreen> {
  _StoreRackData? _selectedRack;
  void _refresh() => setState(() {});

  void _guardWriteAction(VoidCallback action) {
    if (widget.isReadOnly) {
      _showInventoryWriteUnavailableMessage(context);
      return;
    }
    action();
  }

  @override
  Widget build(BuildContext context) {
    final zone = widget.zone;
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
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: DokanStoreLayoutManagementScreen._text,
            ),
          ),
        ),
        leadingWidth: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              zone.name,
              style: const TextStyle(
                color: DokanStoreLayoutManagementScreen._text,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'র‍্যাক লিস্ট',
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
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _StoreLayoutBreadcrumb(
                          steps: ['হোম', 'স্টোর লেআউট', zone.name, 'র‍্যাক'],
                        ),
                        const SizedBox(height: 14),
                        if (widget.isReadOnly) ...[
                          const _InventoryOfflineNotice(),
                          const SizedBox(height: 14),
                        ],
                        _StoreLayoutSectionCard(
                          title: 'র‍্যাক লিস্ট',
                          subtitle:
                              '${zone.racks.length}টি র‍্যাক নিবন্ধিত আছে',
                          accent: DokanStoreLayoutManagementScreen._accent,
                          child: Column(
                            children: [
                              if (zone.racks.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Text(
                                      'কোনো র‍্যাক পাওয়া যায়নি। একটি নতুন র‍্যাক যোগ করুন।'),
                                )
                              else
                                for (final rack in zone.racks) ...[
                                  _buildRackCard(context, rack),
                                  if (rack != zone.racks.last)
                                    const SizedBox(height: 12),
                                ],
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
            type: 'Rack',
            parent: zone,
            onSaved: _refresh,
          ),
        ),
        backgroundColor: DokanStoreLayoutManagementScreen._accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('র‍্যাক যোগ করুন',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRackCard(BuildContext context, _StoreRackData rack) {
    return _StoreLayoutItemCard(
      title: Text(
        rack.name,
        style: const TextStyle(
          color: DokanStoreLayoutManagementScreen._text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        '${rack.shelves.length}টি শেলফ · ${rack.binCount}টি বিন · ${rack.totalStock} পিস স্টক',
        style: const TextStyle(
          color: DokanStoreLayoutManagementScreen._muted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: Icons.view_module_rounded,
      iconColor: DokanStoreLayoutManagementScreen._accent,
      iconBgColor: DokanStoreLayoutManagementScreen._accent.withOpacity(0.12),
      isSelected: _selectedRack == rack,
      onTap: () async {
        setState(() {
          _selectedRack = rack;
        });
        await Future.delayed(const Duration(milliseconds: 250));
        if (!context.mounted) return;
        await Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => _DokanStoreShelfListScreen(
                  zone: widget.zone,
                  rack: rack,
                  isReadOnly: widget.isReadOnly,
                ),
              ),
            )
            .then((_) => _refresh());
        setState(() {
          _selectedRack = null;
        });
      },
      onMorePressed: () => _showContextMenu(
        context,
        ref,
        type: 'Rack',
        item: rack,
        parent: widget.zone,
        onChanged: _refresh,
        readOnly: widget.isReadOnly,
      ),
    );
  }
}

class _DokanStoreShelfListScreen extends ConsumerStatefulWidget {
  const _DokanStoreShelfListScreen({
    required this.zone,
    required this.rack,
    required this.isReadOnly,
  });
  final _StoreZoneData zone;
  final _StoreRackData rack;
  final bool isReadOnly;

  @override
  ConsumerState<_DokanStoreShelfListScreen> createState() =>
      _DokanStoreShelfListScreenState();
}

class _DokanStoreShelfListScreenState
    extends ConsumerState<_DokanStoreShelfListScreen> {
  _StoreShelfData? _selectedShelf;
  void _refresh() => setState(() {});

  void _guardWriteAction(VoidCallback action) {
    if (widget.isReadOnly) {
      _showInventoryWriteUnavailableMessage(context);
      return;
    }
    action();
  }

  @override
  Widget build(BuildContext context) {
    final zone = widget.zone;
    final rack = widget.rack;
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
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: DokanStoreLayoutManagementScreen._text,
            ),
          ),
        ),
        leadingWidth: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rack.name,
              style: const TextStyle(
                color: DokanStoreLayoutManagementScreen._text,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'জোন: ${zone.name}',
              style: const TextStyle(
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
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _StoreLayoutBreadcrumb(
                          steps: ['হোম', zone.name, rack.name, 'শেলফ'],
                        ),
                        const SizedBox(height: 14),
                        if (widget.isReadOnly) ...[
                          const _InventoryOfflineNotice(),
                          const SizedBox(height: 14),
                        ],
                        _StoreLayoutSectionCard(
                          title: 'শেলফ লিস্ট',
                          subtitle:
                              '${rack.shelves.length}টি শেলফ নিবন্ধিত আছে',
                          accent: DokanStoreLayoutManagementScreen._accent,
                          child: Column(
                            children: [
                              if (rack.shelves.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Text(
                                      'কোনো শেলফ পাওয়া যায়নি। একটি নতুন শেলফ যোগ করুন।'),
                                )
                              else
                                for (final shelf in rack.shelves) ...[
                                  _buildShelfCard(context, shelf),
                                  if (shelf != rack.shelves.last)
                                    const SizedBox(height: 12),
                                ],
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
            type: 'Shelf',
            parent: rack,
            onSaved: _refresh,
          ),
        ),
        backgroundColor: DokanStoreLayoutManagementScreen._accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('শেলফ যোগ করুন',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildShelfCard(BuildContext context, _StoreShelfData shelf) {
    return _StoreLayoutItemCard(
      title: Text(
        shelf.name,
        style: const TextStyle(
          color: DokanStoreLayoutManagementScreen._text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        '${shelf.bins.length}টি বিন · ${shelf.totalStock} পিস স্টক',
        style: const TextStyle(
          color: DokanStoreLayoutManagementScreen._muted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: Icons.layers_rounded,
      iconColor: Colors.orange,
      iconBgColor: Colors.orange.withOpacity(0.12),
      isSelected: _selectedShelf == shelf,
      onTap: () async {
        setState(() {
          _selectedShelf = shelf;
        });
        await Future.delayed(const Duration(milliseconds: 250));
        if (!context.mounted) return;
        await Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => _DokanStoreBinListScreen(
                    zone: widget.zone, rack: widget.rack, shelf: shelf),
              ),
            )
            .then((_) => _refresh());
        setState(() {
          _selectedShelf = null;
        });
      },
      onMorePressed: () => _showContextMenu(
        context,
        ref,
        type: 'Shelf',
        item: shelf,
        parent: widget.rack,
        onChanged: _refresh,
        readOnly: widget.isReadOnly,
      ),
    );
  }
}

class _InventoryOfflineNotice extends StatelessWidget {
  const _InventoryOfflineNotice();

  @override
  Widget build(BuildContext context) {
    return _StoreLayoutSectionCard(
      title: 'অফলাইন ভিউ',
      subtitle:
          'এই লেআউটটি ক্যাশে থেকে দেখানো হচ্ছে। সার্ভারের সাথে সংযোগ না আসা পর্যন্ত নতুন তথ্য সংরক্ষণ করা যাবে না।',
      accent: DokanStoreLayoutManagementScreen._warning,
      child: const Text(
        'সংযোগ ফিরে এলে রিফ্রেশ করে আবার চেষ্টা করুন।',
        style: TextStyle(
          color: DokanStoreLayoutManagementScreen._muted,
          fontSize: 13.5,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
