import { computeUnitStats, type Unit, type UnitStats } from "@domain/unit/unit.entity";

import type { UnitListScope, UnitRepository } from "../ports/unit-repository.port";

export class ListUnitsUseCase {
  constructor(private readonly unitRepository: UnitRepository) {}

  async execute(scope: UnitListScope): Promise<{ units: Unit[]; stats: UnitStats }> {
    const units = await this.unitRepository.findMany(scope);
    return { units, stats: computeUnitStats(units) };
  }
}
