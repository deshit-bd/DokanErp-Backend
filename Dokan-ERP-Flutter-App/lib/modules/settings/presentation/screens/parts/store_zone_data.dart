part of '../settings_screens.dart';

class _StoreZoneData {
  _StoreZoneData({
    this.id,
    required this.name,
    required this.racks,
  });

  String? id;
  String name;
  List<_StoreRackData> racks;

  int get totalStock => racks.fold<int>(0, (sum, r) => sum + r.totalStock);
  int get lowStockCount =>
      racks.fold<int>(0, (sum, r) => sum + r.lowStockCount);
}

class _StoreRackData {
  _StoreRackData({
    this.id,
    required this.name,
    required this.shelves,
  });

  String? id;
  String name;
  List<_StoreShelfData> shelves;

  int get totalStock => shelves.fold<int>(0, (sum, s) => sum + s.totalStock);
  int get lowStockCount =>
      shelves.fold<int>(0, (sum, s) => sum + s.lowStockCount);
  int get binCount => shelves.fold<int>(0, (sum, s) => sum + s.bins.length);
}

class _StoreShelfData {
  _StoreShelfData({
    this.id,
    required this.name,
    required this.direction,
    required this.bins,
  });

  String? id;
  String name;
  String direction;
  List<_StoreBinData> bins;

  int get totalStock => bins.fold<int>(0, (sum, b) => sum + b.quantity);
  int get lowStockCount => bins.where((b) => b.isLowStock).length;
}

class _StoreBinData {
  _StoreBinData({
    this.id,
    required this.code,
    required this.quantity,
    required this.rackName,
    required this.shelfName,
  });

  String? id;
  String code;
  int quantity;
  String rackName;
  String shelfName;

  bool get isLowStock => quantity < 10;

  String get locationPath {
    String zoneName = 'গ্রোসারি জোন';
    for (final zone in _storeZones) {
      for (final rack in zone.racks) {
        if (rack.name == rackName) {
          zoneName = zone.name;
          break;
        }
      }
    }
    return '$zoneName · $rackName · $shelfName';
  }
}

List<_StoreZoneData> _storeZones = <_StoreZoneData>[];

_StoreZoneData _storeZoneFromEntity(InventoryZone zone) {
  return _StoreZoneData(
    id: zone.id,
    name: zone.name,
    racks: zone.racks.map(_storeRackFromEntity).toList(growable: true),
  );
}

_StoreRackData _storeRackFromEntity(InventoryRack rack) {
  return _StoreRackData(
    id: rack.id,
    name: rack.name,
    shelves: rack.shelves.map(_storeShelfFromEntity).toList(growable: true),
  );
}

_StoreShelfData _storeShelfFromEntity(InventoryShelf shelf) {
  return _StoreShelfData(
    id: shelf.id,
    name: shelf.name,
    direction: shelf.direction,
    bins: shelf.bins.map(_storeBinFromEntity).toList(growable: true),
  );
}

_StoreBinData _storeBinFromEntity(InventoryBin bin) {
  return _StoreBinData(
    id: bin.id,
    code: bin.code,
    quantity: bin.quantity,
    rackName: bin.rackName,
    shelfName: bin.shelfName,
  );
}

List<_StoreBinData> get _lowStockBins {
  final List<_StoreBinData> result = [];
  for (final zone in _storeZones) {
    for (final rack in zone.racks) {
      for (final shelf in rack.shelves) {
        for (final bin in shelf.bins) {
          if (bin.isLowStock) {
            result.add(bin);
          }
        }
      }
    }
  }
  return result;
}

class DokanStoreLayoutDetailScreen extends StatelessWidget {
  const DokanStoreLayoutDetailScreen({
    super.key,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.breadcrumbs,
  });

  final String level;
  final String title;
  final String subtitle;
  final String details;
  final List<String> breadcrumbs;

  @override
  Widget build(BuildContext context) {
    final themeAccent = DokanStoreLayoutManagementScreen._accent;
    final themeBg = DokanStoreLayoutManagementScreen._bg;
    final themeText = DokanStoreLayoutManagementScreen._text;
    final themeMuted = DokanStoreLayoutManagementScreen._muted;

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        backgroundColor: themeBg,
        surfaceTintColor: themeBg,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: themeText,
            ),
          ),
        ),
        leadingWidth: 72,
        title: Text(
          title,
          style: const TextStyle(
            color: DokanStoreLayoutManagementScreen._text,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0E8F5F), Color(0xFF0A6F4A)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: breadcrumbs
                        .map(
                          (crumb) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.16)),
                            ),
                            child: Text(
                              crumb,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$level details',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.84),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _StoreLayoutSectionCard(
              title: 'স্ট্যাটাস',
              subtitle: 'দ্রুত সারাংশ',
              accent: themeAccent,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StoreLayoutMiniChip(
                      label: 'অ্যাক্টিভ',
                      icon: Icons.circle_rounded,
                      color: themeAccent),
                  _StoreLayoutMiniChip(
                      label: 'রিয়েল-টাইম',
                      icon: Icons.bolt_rounded,
                      color: themeAccent),
                  _StoreLayoutMiniChip(
                      label: details,
                      icon: Icons.inventory_2_rounded,
                      color: themeMuted),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _StoreLayoutSectionCard(
              title: 'দ্রুত পদক্ষেপ',
              subtitle: 'নতুন এন্ট্রি বা আপডেট',
              accent: themeAccent,
              child: Column(
                children: [
                  _StoreLayoutActionCard(
                    icon: Icons.edit_rounded,
                    title: 'সম্পাদনা',
                    subtitle: 'এই আইটেম কনফিগার করুন',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: 10),
                  _StoreLayoutActionCard(
                    icon: Icons.add_rounded,
                    title: 'নতুন যোগ করুন',
                    subtitle: 'এই লেভেলের অধীনে নতুন আইটেম তৈরি করুন',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
