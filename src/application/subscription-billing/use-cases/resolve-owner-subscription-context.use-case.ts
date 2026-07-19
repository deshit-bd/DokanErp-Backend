import type { AppType, AuthRole } from "@domain/shared/auth-role";
import {
  OwnerSubscriptionOnlyError,
  SubscriptionShopIdRequiredError,
  SubscriptionShopNotFoundError,
  SubscriptionShopScopeError,
} from "@domain/subscription-billing/subscription-billing.errors";

import type { ShopScope, SubscriptionBillingRepository } from "../ports/subscription-billing-repository.port";

export class ResolveOwnerSubscriptionContextUseCase {
  constructor(private readonly subscriptionBillingRepository: SubscriptionBillingRepository) {}

  async execute(input: { appType: AppType; role: AuthRole; authShopId: string | undefined; requestedShopId: string | undefined }): Promise<ShopScope> {
    if (input.appType !== "MOBILE" || input.role !== "SHOP_OWNER") {
      throw new OwnerSubscriptionOnlyError();
    }

    const shopId = input.authShopId ?? input.requestedShopId ?? "";

    if (!shopId) {
      throw new SubscriptionShopIdRequiredError();
    }

    if (input.authShopId && input.authShopId !== shopId) {
      throw new SubscriptionShopScopeError();
    }

    const shop = await this.subscriptionBillingRepository.findShopById(shopId);

    if (!shop) {
      throw new SubscriptionShopNotFoundError();
    }

    return shop;
  }
}
