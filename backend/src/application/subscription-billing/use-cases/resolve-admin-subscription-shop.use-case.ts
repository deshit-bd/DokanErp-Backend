import type { AuthRole } from "@domain/shared/auth-role";
import { ForbiddenError, ValidationError } from "@domain/shared/app-error";
import { SubscriptionShopNotFoundError } from "@domain/subscription-billing/subscription-billing.errors";

import type { ShopScope, SubscriptionBillingRepository } from "../ports/subscription-billing-repository.port";

export class ResolveAdminSubscriptionShopUseCase {
  constructor(private readonly subscriptionBillingRepository: SubscriptionBillingRepository) {}

  async execute(role: AuthRole, requestedShopId: string | undefined): Promise<ShopScope> {
    if (!["SUPER_ADMIN", "ADMIN"].includes(role)) {
      throw new ForbiddenError("You do not have permission to view subscriptions.");
    }

    const shopId = requestedShopId?.trim();

    if (!shopId) {
      throw new ValidationError("shopId is required for subscription lookup.");
    }

    const shop = await this.subscriptionBillingRepository.resolveShopIdentifier(shopId);

    if (!shop) {
      throw new SubscriptionShopNotFoundError("Shop not found for the provided shopId/shopCode.");
    }

    return shop;
  }
}
