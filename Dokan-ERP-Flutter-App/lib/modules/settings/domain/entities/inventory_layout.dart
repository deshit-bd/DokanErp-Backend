enum InventoryMode {
  general,
  rack;

  bool get isAdvanced => this == InventoryMode.rack;

  String get apiValue => isAdvanced ? 'RACK' : 'GENERAL';

  static InventoryMode fromApi(Object? value) {
    return '$value'.trim().toUpperCase() == 'RACK'
        ? InventoryMode.rack
        : InventoryMode.general;
  }
}

class InventoryLayoutTree {
  const InventoryLayoutTree({this.zones = const []});

  final List<InventoryZone> zones;
}

class InventoryZone {
  const InventoryZone({
    required this.id,
    required this.name,
    this.racks = const [],
  });

  final String id;
  final String name;
  final List<InventoryRack> racks;
}

class InventoryRack {
  const InventoryRack({
    required this.id,
    required this.name,
    this.zoneId = '',
    this.shelves = const [],
  });

  final String id;
  final String name;
  final String zoneId;
  final List<InventoryShelf> shelves;
}

class InventoryShelf {
  const InventoryShelf({
    required this.id,
    required this.name,
    this.zoneId = '',
    this.rackId = '',
    this.direction = '',
    this.bins = const [],
  });

  final String id;
  final String name;
  final String zoneId;
  final String rackId;
  final String direction;
  final List<InventoryBin> bins;
}

class InventoryBin {
  const InventoryBin({
    required this.id,
    required this.code,
    this.zoneId = '',
    this.rackId = '',
    this.shelfId = '',
    this.zoneName = '',
    this.rackName = '',
    this.shelfName = '',
    this.quantity = 0,
  });

  final String id;
  final String code;
  final String zoneId;
  final String rackId;
  final String shelfId;
  final String zoneName;
  final String rackName;
  final String shelfName;
  final int quantity;
}

class InventoryReceiveContext {
  const InventoryReceiveContext({
    required this.mode,
    this.bins = const [],
  });

  final InventoryMode mode;
  final List<InventoryBin> bins;
}
