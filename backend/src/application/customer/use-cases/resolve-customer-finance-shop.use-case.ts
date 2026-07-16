import type { AuthRole } from "@domain/shared/auth-role";
import {
  CustomerAccessForbiddenError,
  CustomerFinanceScopeForbiddenError,
  CustomerFinanceShopIdRequiredError,
  CustomerShopNotFoundError,
} from "@domain/customer/customer.errors";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export type ResolveCustomerFinanceShopCommand = {
  role: AuthRole;
  authShopId: string | undefined;
  queryShopId: string;
  bodyShopId: string;
};

export class ResolveCustomerFinanceShopUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async execute(command: ResolveCustomerFinanceShopCommand): Promise<ShopScope> {
    if (!["SUPER_ADMIN", "ADMIN", "SHOP_OWNER", "SALESMAN"].includes(command.role)) {
      throw new CustomerAccessForbiddenError();
    }

    // NOTE: preserves the legacy `??` chaining quirk — see reports'/purchases'
    // resolve-shop-context use cases for the same pattern.
    const rawShopId = command.authShopId ?? command.queryShopId ?? command.bodyShopId ?? "";

    if (!rawShopId) {
      throw new CustomerFinanceShopIdRequiredError();
    }

    if (["SHOP_OWNER", "SALESMAN"].includes(command.role) && command.authShopId && command.authShopId !== rawShopId) {
      throw new CustomerFinanceScopeForbiddenError();
    }

    const shop = await this.customerRepository.resolveShopIdentifier(rawShopId);

    if (!shop) {
      throw new CustomerShopNotFoundError();
    }

    return shop;
  }
}
