part of '../purchase_screens.dart';

class _InventoryBinOption {
  const _InventoryBinOption({
    required this.id,
    required this.code,
    required this.locationLabel,
  });

  final String id;
  final String code;
  final String locationLabel;

  factory _InventoryBinOption.fromJson(
    Map<String, dynamic> json,
    Map<String, String> zoneNames,
    Map<String, String> rackNames,
    Map<String, String> shelfNames,
  ) {
    final zoneId = json['zoneId'] as String? ?? '';
    final rackId = json['rackId'] as String? ?? '';
    final shelfId = json['shelfId'] as String? ?? '';
    final code = json['code'] as String? ?? '';
    final parts = <String>[
      if (zoneNames[zoneId]?.trim().isNotEmpty == true) zoneNames[zoneId]!,
      if (rackNames[rackId]?.trim().isNotEmpty == true) rackNames[rackId]!,
      if (shelfNames[shelfId]?.trim().isNotEmpty == true) shelfNames[shelfId]!,
      if (code.trim().isNotEmpty) code,
    ];
    return _InventoryBinOption(
      id: json['id'] as String? ?? '',
      code: code,
      locationLabel: parts.join(' • '),
    );
  }
}

class _InventoryShelfOption {
  const _InventoryShelfOption({
    required this.id,
    required this.name,
    required this.bins,
  });

  final String id;
  final String name;
  final List<_InventoryBinOption> bins;

  factory _InventoryShelfOption.fromJson(
    Map<String, dynamic> json, {
    required String zoneName,
    required String rackName,
  }) {
    final shelfName = json['name'] as String? ?? '';
    final bins = (json['bins'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (bin) => _InventoryBinOption(
            id: '${bin['id'] ?? ''}',
            code: '${bin['code'] ?? ''}',
            locationLabel: [
              zoneName,
              rackName,
              shelfName,
              '${bin['code'] ?? ''}'
            ].where((part) => part.trim().isNotEmpty).join(' • '),
          ),
        )
        .where((bin) => bin.id.isNotEmpty)
        .toList(growable: false);

    return _InventoryShelfOption(
      id: '${json['id'] ?? ''}',
      name: shelfName,
      bins: bins,
    );
  }
}

class _InventoryRackOption {
  const _InventoryRackOption({
    required this.id,
    required this.name,
    required this.shelves,
  });

  final String id;
  final String name;
  final List<_InventoryShelfOption> shelves;

  factory _InventoryRackOption.fromJson(
    Map<String, dynamic> json, {
    required String zoneName,
  }) {
    final rackName = json['name'] as String? ?? '';
    final shelves = (json['shelves'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (shelf) => _InventoryShelfOption.fromJson(
            shelf.map((key, value) => MapEntry('$key', value)),
            zoneName: zoneName,
            rackName: rackName,
          ),
        )
        .where((shelf) => shelf.id.isNotEmpty)
        .toList(growable: false);

    return _InventoryRackOption(
      id: '${json['id'] ?? ''}',
      name: rackName,
      shelves: shelves,
    );
  }
}

class _InventoryZoneOption {
  const _InventoryZoneOption({
    required this.id,
    required this.name,
    required this.racks,
  });

  final String id;
  final String name;
  final List<_InventoryRackOption> racks;

  factory _InventoryZoneOption.fromJson(Map<String, dynamic> json) {
    final zoneName = json['name'] as String? ?? '';
    final racks = (json['racks'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (rack) => _InventoryRackOption.fromJson(
            rack.map((key, value) => MapEntry('$key', value)),
            zoneName: zoneName,
          ),
        )
        .where((rack) => rack.id.isNotEmpty)
        .toList(growable: false);

    return _InventoryZoneOption(
      id: '${json['id'] ?? ''}',
      name: zoneName,
      racks: racks,
    );
  }
}

class _PurchaseReceiveDialogResult {
  const _PurchaseReceiveDialogResult({
    required this.lines,
    required this.placements,
    required this.paidAmount,
    required this.paymentMethod,
    this.paymentDetails,
  });

  final List<PurchaseReceiveLineInput> lines;
  final List<PurchaseInventoryPlacementInput> placements;
  final int paidAmount;
  final String paymentMethod;
  final Map<String, dynamic>? paymentDetails;
}
