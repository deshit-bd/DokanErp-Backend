import { toDisplayLabel, type Unit } from "@domain/unit/unit.entity";

export function toUnitDto(unit: Unit) {
  return {
    id: unit.id,
    name: unit.name,
    shortName: unit.shortName,
    type: unit.type,
    typeLabel: toDisplayLabel(unit.type),
    description: unit.description,
    status: unit.status,
    statusLabel: toDisplayLabel(unit.status),
    shopId: unit.shopId,
    isGlobal: unit.isGlobal,
    isApproved: unit.isApproved,
    createdAt: unit.createdAt,
    updatedAt: unit.updatedAt,
  };
}
