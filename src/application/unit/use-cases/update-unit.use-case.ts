import type { UnitStatus, UnitType } from "@prisma/client";

import type { Unit } from "@domain/unit/unit.entity";
import { DuplicateUnitFieldsError, UnitEditForbiddenError, UnitNotFoundError } from "@domain/unit/unit.errors";

import type { UnitRepository } from "../ports/unit-repository.port";

export type UpdateUnitCommand = {
  id: string;
  name: string | undefined;
  shortName: string | undefined;
  type: UnitType | undefined;
  description: string | null | undefined;
  status: UnitStatus | undefined;
  isAdmin: boolean;
  shopId: string | undefined;
};

export class UpdateUnitUseCase {
  constructor(private readonly unitRepository: UnitRepository) {}

  async execute(command: UpdateUnitCommand): Promise<Unit> {
    const unit = await this.unitRepository.findById(command.id);

    if (!unit) {
      throw new UnitNotFoundError();
    }

    if (!command.isAdmin && unit.shopId !== command.shopId) {
      throw new UnitEditForbiddenError();
    }

    const name = command.name?.trim();
    const shortName = command.shortName?.trim();
    const description = command.description !== undefined ? command.description?.trim() || null : undefined;
    const type = command.type;
    const status = command.status;

    if (name !== undefined || shortName !== undefined) {
      const scope = { isAdmin: command.isAdmin, shopId: command.shopId };
      const duplicate = await this.unitRepository.findDuplicateForUpdate(
        name || unit.name,
        shortName || unit.shortName,
        command.id,
        scope,
      );

      if (duplicate) {
        throw new DuplicateUnitFieldsError();
      }
    }

    return this.unitRepository.update(command.id, { name, shortName, type, description, status });
  }
}
