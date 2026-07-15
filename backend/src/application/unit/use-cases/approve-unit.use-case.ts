import type { Unit } from "@domain/unit/unit.entity";
import { UnitNotFoundError } from "@domain/unit/unit.errors";

import type { UnitRepository } from "../ports/unit-repository.port";

export class ApproveUnitUseCase {
  constructor(private readonly unitRepository: UnitRepository) {}

  async execute(id: string): Promise<Unit> {
    const unit = await this.unitRepository.findById(id);

    if (!unit) {
      throw new UnitNotFoundError();
    }

    return this.unitRepository.approve(id);
  }
}
