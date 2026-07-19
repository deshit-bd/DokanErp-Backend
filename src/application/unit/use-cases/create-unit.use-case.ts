import { UnitStatus, UnitType } from "@prisma/client";

import type { Unit } from "@domain/unit/unit.entity";
import {
  DuplicateUnitFieldError,
  UnitNameRequiredError,
  UnitShortNameRequiredError,
  UnitStatusInvalidError,
  UnitTypeRequiredError,
} from "@domain/unit/unit.errors";

import type { UnitRepository } from "../ports/unit-repository.port";

export type CreateUnitCommand = {
  name: string | undefined;
  shortName: string | undefined;
  type: UnitType | undefined;
  description: string | null | undefined;
  status: UnitStatus | undefined;
  isAdmin: boolean;
  shopId: string | undefined;
};

export class CreateUnitUseCase {
  constructor(private readonly unitRepository: UnitRepository) {}

  async execute(command: CreateUnitCommand): Promise<Unit> {
    const name = command.name?.trim();
    const shortName = command.shortName?.trim();
    const description = command.description?.trim() || null;
    const type = command.type;
    const status = command.status ?? UnitStatus.ACTIVE;

    if (!name) {
      throw new UnitNameRequiredError();
    }
    if (!shortName) {
      throw new UnitShortNameRequiredError();
    }
    if (!type || !Object.values(UnitType).includes(type)) {
      throw new UnitTypeRequiredError();
    }
    if (!Object.values(UnitStatus).includes(status)) {
      throw new UnitStatusInvalidError();
    }

    const scope = { isAdmin: command.isAdmin, shopId: command.shopId };
    const duplicate = await this.unitRepository.findDuplicateForCreate(name, shortName, scope);

    if (duplicate) {
      throw new DuplicateUnitFieldError(duplicate.name === name ? "Unit name" : "Short name");
    }

    return this.unitRepository.create({
      name,
      shortName,
      type,
      description,
      status,
      shopId: command.isAdmin ? null : (command.shopId ?? null),
      isGlobal: command.isAdmin,
      isApproved: command.isAdmin,
    });
  }
}
