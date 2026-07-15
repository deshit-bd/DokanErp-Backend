import type { UnitStatus, UnitType } from "@prisma/client";

export type Unit = {
  id: string;
  name: string;
  shortName: string;
  type: UnitType;
  description: string | null;
  status: UnitStatus;
  shopId: string | null;
  isGlobal: boolean;
  isApproved: boolean;
  createdAt: Date;
  updatedAt: Date;
};

export type UnitStats = {
  total: number;
  active: number;
  inactive: number;
  archived: number;
};

// Distinct from category's toDisplayStatus (which only replaces underscores
// and keeps casing) — units historically title-case their labels instead
// ("ACTIVE" -> "Active"). Preserved as a separate function deliberately.
export function toDisplayLabel(value: string): string {
  return value
    .toLowerCase()
    .split("_")
    .map((segment) => segment.charAt(0).toUpperCase() + segment.slice(1))
    .join(" ");
}

export function computeUnitStats(units: Pick<Unit, "status">[]): UnitStats {
  return {
    total: units.length,
    active: units.filter((unit) => unit.status === "ACTIVE").length,
    inactive: units.filter((unit) => unit.status === "INACTIVE").length,
    archived: units.filter((unit) => unit.status === "ARCHIVED").length,
  };
}
