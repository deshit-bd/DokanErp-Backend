import { buildStaffIdentifierVariants, buildStaffSummary, mapStaffMember } from "@domain/staff/staff.entity";
import { StaffMemberNotFoundError, ValidationError } from "@domain/staff/staff.errors";

import type { StaffRepository } from "../ports/staff-repository.port";

export class UpdateStaffStatusUseCase {
  constructor(private readonly staffRepository: StaffRepository) {}

  async execute(shopId: string, rawStaffUserId: string, rawStatus: string | undefined) {
    const staffUserId = rawStaffUserId.trim();
    const status = (rawStatus ?? "").trim().toUpperCase();

    if (!staffUserId) {
      throw new ValidationError("Staff user id is required.");
    }
    if (status !== "ACTIVE" && status !== "INACTIVE") {
      throw new ValidationError("Status must be ACTIVE or INACTIVE.");
    }

    const variants = buildStaffIdentifierVariants(staffUserId);
    const member = await this.staffRepository.findSalesmanByIdentifier(shopId, variants);

    if (!member) {
      throw new StaffMemberNotFoundError();
    }

    const updatedUser = await this.staffRepository.updateUserStatus(member.user.id, status);
    const updatedStaff = mapStaffMember({ ...member, user: updatedUser });

    const allMembers = await this.staffRepository.findSalesmenForShop(shopId);
    const summary = buildStaffSummary(allMembers.map(mapStaffMember));

    return { staff: updatedStaff, summary };
  }
}
