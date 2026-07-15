import { buildStaffSummary, mapStaffMember } from "@domain/staff/staff.entity";

import type { StaffRepository } from "../ports/staff-repository.port";

export class ListStaffUseCase {
  constructor(private readonly staffRepository: StaffRepository) {}

  async execute(shopId: string) {
    const members = await this.staffRepository.findSalesmenForShop(shopId);
    const staff = members.map(mapStaffMember);
    return { summary: buildStaffSummary(staff), staff };
  }
}
