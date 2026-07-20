import type { UnitStatus, UnitType } from "@prisma/client";

import type { Unit } from "@domain/unit/unit.entity";

export type UnitListScope = { isAdmin: boolean; shopId?: string };

export type CreateUnitInput = {
  name: string;
  shortName: string;
  type: UnitType;
  description: string | null;
  status: UnitStatus;
  shopId: string | null;
  isGlobal: boolean;
  isApproved: boolean;
};

export type UpdateUnitInput = {
  name?: string;
  shortName?: string;
  type?: UnitType;
  description?: string | null;
  status?: UnitStatus;
};

export interface UnitRepository {
  findMany(scope: UnitListScope): Promise<Unit[]>;
  findById(id: string): Promise<Unit | null>;
  findByIdWithProductCount(id: string): Promise<{ id: string; productCount: number } | null>;
  /** Duplicate check for create: matches name OR shortName within the visible scope. */
  findDuplicateForCreate(name: string, shortName: string, scope: UnitListScope): Promise<{ id: string; name: string; shortName: string } | null>;
  /** Duplicate check for update: same shape, excluding the unit being updated. */
  findDuplicateForUpdate(name: string, shortName: string, excludeId: string, scope: UnitListScope): Promise<{ id: string } | null>;
  create(input: CreateUnitInput): Promise<Unit>;
  update(id: string, input: UpdateUnitInput): Promise<Unit>;
  delete(id: string): Promise<void>;
  approve(id: string): Promise<Unit>;
}
