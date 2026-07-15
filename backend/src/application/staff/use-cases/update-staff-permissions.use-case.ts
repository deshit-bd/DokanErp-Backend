import { buildStaffIdentifierVariants, mapStaffMember, type StaffPermissions } from "@domain/staff/staff.entity";
import { StaffMemberNotFoundError, ValidationError } from "@domain/staff/staff.errors";

import type { StaffRepository } from "../ports/staff-repository.port";

export class UpdateStaffPermissionsUseCase {
  constructor(private readonly staffRepository: StaffRepository) {}

  async execute(shopId: string, rawStaffUserId: string, permissions: Partial<StaffPermissions>) {
    const staffUserId = rawStaffUserId.trim();

    if (!staffUserId) {
      throw new ValidationError("Staff user id is required.");
    }

    const variants = buildStaffIdentifierVariants(staffUserId);
    const member = await this.staffRepository.findSalesmanByIdentifierBasic(shopId, variants);

    if (!member) {
      throw new StaffMemberNotFoundError();
    }

    await this.staffRepository.upsertSalesmanPermissions(member.id, {
      canSell: Boolean(permissions.canSell),
      canViewStock: Boolean(permissions.canViewStock),
      canViewReports: Boolean(permissions.canViewReports),
      canChangePrice: Boolean(permissions.canChangePrice),
      canCollectDue: Boolean(permissions.canCollectDue),
    });

    const refreshed = await this.staffRepository.findShopUserById(member.id);

    return refreshed ? mapStaffMember(refreshed) : null;
  }
}
