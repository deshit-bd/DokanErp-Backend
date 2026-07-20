import { buildStaffIdentifierVariants } from "@domain/staff/staff.entity";
import { StaffMemberNotFoundError, ValidationError } from "@domain/staff/staff.errors";

import type { StaffRepository } from "../ports/staff-repository.port";

export class ResetStaffPinUseCase {
  constructor(private readonly staffRepository: StaffRepository) {}

  async execute(shopId: string, rawStaffUserId: string): Promise<void> {
    const staffUserId = rawStaffUserId.trim();

    if (!staffUserId) {
      throw new ValidationError("Staff user id is required.");
    }

    const variants = buildStaffIdentifierVariants(staffUserId);
    const member = await this.staffRepository.findSalesmanByIdentifierBasic(shopId, variants);

    if (!member) {
      throw new StaffMemberNotFoundError();
    }

    await this.staffRepository.upsertPinReset(member.userId);
  }
}
