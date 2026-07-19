import type { AppType, AuthRole } from "@domain/shared/auth-role";
import { UserNotFoundError } from "@domain/auth/auth.errors";

import type { AuthRepository } from "../ports/auth-repository.port";

export class GetCurrentUserUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(input: { userId: string; role: AuthRole; appType: AppType; shopId?: string }) {
    const user = await this.authRepository.findUserById(input.userId);

    if (!user) {
      throw new UserNotFoundError();
    }

    const shop = input.shopId ? await this.authRepository.findShopById(input.shopId) : null;

    let permissions = {
      canSell: true,
      canViewStock: true,
      canViewReports: true,
      canChangePrice: true,
      canCollectDue: true,
    };

    if (input.role === "SALESMAN" && input.shopId) {
      const salesmanPermissions = await this.authRepository.getSalesmanPermissions(input.shopId, input.userId);
      if (salesmanPermissions) {
        permissions = salesmanPermissions;
      }
    }

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        profileImageUrl: user.profileImageUrl,
        status: user.status,
      },
      session: {
        appType: input.appType,
        role: input.role,
        shopId: input.shopId ?? null,
        shopCode: shop?.shopCode ?? null,
      },
      permissions,
    };
  }
}
