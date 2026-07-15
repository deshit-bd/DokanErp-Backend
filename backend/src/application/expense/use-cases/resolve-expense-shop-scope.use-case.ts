import type { AuthRole } from "@domain/shared/auth-role";
import { ForbiddenError } from "@domain/shared/app-error";
import { ShopIdRequiredError, ShopNotFoundError, ShopScopeForbiddenError } from "@domain/expense/expense.errors";

import type { ExpenseRepository, ShopScope } from "../ports/expense-repository.port";

export type ResolveExpenseShopScopeInput = {
  role: AuthRole;
  authShopId: string | undefined;
  requestedShopId: string | undefined;
  mode: "manage" | "report";
};

const MANAGE_ROLES: AuthRole[] = ["SUPER_ADMIN", "ADMIN", "SHOP_OWNER"];
const REPORT_ROLES: AuthRole[] = ["SUPER_ADMIN", "ADMIN", "SHOP_OWNER", "SALESMAN"];
const SCOPED_ROLES: AuthRole[] = ["SHOP_OWNER", "SALESMAN"];

export class ResolveExpenseShopScopeUseCase {
  constructor(private readonly expenseRepository: ExpenseRepository) {}

  async execute(input: ResolveExpenseShopScopeInput): Promise<ShopScope> {
    const allowedRoles = input.mode === "manage" ? MANAGE_ROLES : REPORT_ROLES;

    if (!allowedRoles.includes(input.role)) {
      throw new ForbiddenError(
        input.mode === "manage"
          ? "You do not have permission to manage expenses."
          : "You do not have permission to view expense reports.",
      );
    }

    const rawShopId = input.authShopId ?? input.requestedShopId ?? "";

    if (!rawShopId) {
      throw new ShopIdRequiredError(input.mode === "manage" ? "operations" : "report operations");
    }

    const scopedRoleCheck = input.mode === "manage" ? input.role === "SHOP_OWNER" : SCOPED_ROLES.includes(input.role);

    if (scopedRoleCheck && input.authShopId && input.authShopId !== rawShopId) {
      throw new ShopScopeForbiddenError(input.mode === "manage" ? "expenses" : "expense reports");
    }

    const shop = await this.expenseRepository.findShopByIdentifier(rawShopId);

    if (!shop) {
      throw new ShopNotFoundError();
    }

    return shop;
  }
}
