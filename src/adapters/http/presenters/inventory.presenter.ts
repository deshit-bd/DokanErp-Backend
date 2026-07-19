import { deriveBinStatusFromQuantity, deserializeShelfName, getBinQuantity, toLabel } from "@domain/inventory/inventory.entity";
import type {
  InventoryBinRecord,
  InventoryRackRecord,
  InventoryShelfRecord,
  InventoryZoneRecord,
  LayoutTreeZone,
} from "@application/inventory/ports/inventory-repository.port";

export function toZoneDto(zone: InventoryZoneRecord) {
  return {
    id: zone.id,
    name: zone.name,
    subtitle: zone.subtitle,
    icon: zone.icon,
    rackCount: zone._count?.racks ?? 0,
    shelfCount: zone._count?.shelves ?? 0,
    binCount: zone._count?.bins ?? 0,
    createdAt: zone.createdAt,
    updatedAt: zone.updatedAt,
  };
}

export function toRackDto(rack: InventoryRackRecord) {
  return {
    id: rack.id,
    zoneId: rack.zoneId,
    name: rack.name,
    note: rack.note,
    shelfCount: rack.shelfCount,
    totalBins: rack.totalBins,
    usedBins: rack.usedBins,
    createdAt: rack.createdAt,
    updatedAt: rack.updatedAt,
  };
}

export function toShelfDto(shelf: InventoryShelfRecord) {
  const deserialized = deserializeShelfName(shelf.name);
  return {
    id: shelf.id,
    zoneId: shelf.zoneId,
    rackId: shelf.rackId,
    name: deserialized.name,
    direction: deserialized.direction,
    totalBins: shelf.totalBins,
    usedBins: shelf.usedBins,
    createdAt: shelf.createdAt,
    updatedAt: shelf.updatedAt,
  };
}

export function toBinDto(bin: InventoryBinRecord) {
  const qty = getBinQuantity(bin);
  return {
    id: bin.id,
    zoneId: bin.zoneId,
    rackId: bin.rackId,
    shelfId: bin.shelfId,
    code: bin.code,
    productName: toLabel(bin.productName, "খালি"),
    status: deriveBinStatusFromQuantity(qty),
    quantity: qty,
    quantityLabel: `${qty} পিস`,
    daysLabel: toLabel(bin.daysLabel, qty <= 0 ? "খালি" : "১ দিন"),
    createdAt: bin.createdAt,
    updatedAt: bin.updatedAt,
  };
}

export function toLayoutTreeDto(zones: LayoutTreeZone[]) {
  return zones.map((zone) => ({
    id: zone.id,
    name: zone.name,
    racks: zone.racks.map((rack) => ({
      id: rack.id,
      name: rack.name,
      shelves: rack.shelves.map((shelf) => {
        const deserialized = deserializeShelfName(shelf.name);
        return {
          id: shelf.id,
          name: deserialized.name,
          direction: deserialized.direction,
          bins: shelf.bins.map((bin) => ({
            id: bin.id,
            code: bin.code,
            quantity: getBinQuantity(bin),
            rackName: rack.name,
            shelfName: deserialized.name,
          })),
        };
      }),
    })),
  }));
}
