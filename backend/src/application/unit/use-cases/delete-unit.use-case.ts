import { UnitInUseError, UnitNotFoundError } from "@domain/unit/unit.errors";

import type { UnitRepository } from "../ports/unit-repository.port";

export class DeleteUnitUseCase {
  constructor(private readonly unitRepository: UnitRepository) {}

  async execute(id: string): Promise<void> {
    const unit = await this.unitRepository.findByIdWithProductCount(id);

    if (!unit) {
      throw new UnitNotFoundError();
    }

    if (unit.productCount > 0) {
      throw new UnitInUseError();
    }

    await this.unitRepository.delete(id);
  }
}
