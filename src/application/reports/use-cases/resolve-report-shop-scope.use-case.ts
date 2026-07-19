import type { AuthRole } from "@domain/shared/auth-role";
import { ReportShopIdRequiredError, ReportShopScopeForbiddenError, ReportsAccessForbiddenError } from "@domain/reports/reports.errors";

export type ResolveReportShopScopeCommand = {
  role: AuthRole;
  authShopId: string | undefined;
  queryShopId: string | undefined;
  bodyShopId: string | undefined;
};

export class ResolveReportShopScopeUseCase {
  execute(command: ResolveReportShopScopeCommand): string {
    if (!["SUPER_ADMIN", "ADMIN", "SHOP_OWNER", "SALESMAN"].includes(command.role)) {
      throw new ReportsAccessForbiddenError();
    }

    // NOTE: preserves a legacy quirk — the original computed
    // `auth.shopId ?? (queryShopId ?? "") ?? (bodyShopId ?? "")`. Because the
    // query fallback is always a defined string (possibly ""), the `??`
    // chain never falls through to bodyShopId once authShopId is missing.
    // The controller passes queryShopId as "" (not undefined) when absent to
    // reproduce this exactly; bodyShopId is effectively dead here, same as
    // the original route.
    const shopId = command.authShopId ?? command.queryShopId ?? command.bodyShopId ?? "";

    if (!shopId) {
      throw new ReportShopIdRequiredError();
    }

    if (["SHOP_OWNER", "SALESMAN"].includes(command.role) && command.authShopId && command.authShopId !== shopId) {
      throw new ReportShopScopeForbiddenError();
    }

    return shopId;
  }
}
