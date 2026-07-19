import type { AppType, AuthRole } from "@domain/shared/auth-role";
import { NotFoundError } from "@domain/shared/app-error";
import { OwnerOnlyStaffError } from "@domain/staff/staff.errors";

import type { StaffRepository } from "../ports/staff-repository.port";

export class ResolveOwnerShopContextUseCase {
  constructor(private readonly staffRepository: StaffRepository) {}

  async execute(input: { appType: AppType; role: AuthRole; shopId: string | undefined; userId: string }) {
    if (input.appType !== "MOBILE" || input.role !== "SHOP_OWNER" || !input.shopId) {
      throw new OwnerOnlyStaffError();
    }

    const shop = await this.staffRepository.findShopById(input.shopId);

    if (!shop) {
      throw new NotFoundError("Shop not found.");
    }

    if (shop.ownerUserId !== input.userId) {
      throw new OwnerOnlyStaffError("You can only manage staff for your own shop.");
    }

    return shop;
  }
}
