import { mapInvoice, mapPayment } from "@domain/subscription-billing/subscription-billing.entity";

import type { ShopScope, SubscriptionBillingRepository } from "../ports/subscription-billing-repository.port";

export class GetSubscriptionOverviewUseCase {
  constructor(private readonly subscriptionBillingRepository: SubscriptionBillingRepository) {}

  async execute(shop: ShopScope) {
    const { evaluateShopSubscriptionAccess, ensureDailyInvoice } = await import("../../../subscription/access");

    const access = await evaluateShopSubscriptionAccess(shop.id);
    const invoice = access.billingDate ? await ensureDailyInvoice(shop.id) : null;

    const [recentInvoices, recentPayments] = await Promise.all([
      this.subscriptionBillingRepository.findRecentInvoices(shop.id, 6),
      this.subscriptionBillingRepository.findRecentPayments(shop.id, 6),
    ]);

    return {
      shop,
      subscription: access,
      invoice: invoice ? mapInvoice(invoice) : null,
      recentInvoices: recentInvoices.map(mapInvoice),
      recentPayments: recentPayments.map(mapPayment),
    };
  }
}
