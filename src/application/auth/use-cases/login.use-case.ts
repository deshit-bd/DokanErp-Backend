import { buildPhoneVariations, resolveAuthContext } from "@domain/auth/auth.entity";
import { InvalidCredentialsError } from "@domain/auth/auth.errors";
import type { AppType } from "@domain/shared/auth-role";
import { ForbiddenError, PaymentRequiredError, ValidationError } from "@domain/shared/app-error";

import { issueSession } from "../issue-session";
import type { AuthRepository } from "../ports/auth-repository.port";
import { getDefaultRedirect, isAllowedForAppType } from "../../../auth/authorization";
import { verifyPassword } from "../../../auth/password";

export type LoginCommand = {
  identity: string | undefined;
  password: string | undefined;
  requestedShopIdentifier: string | undefined;
  appType: AppType;
  rememberMe: unknown;
};

export class LoginUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(command: LoginCommand) {
    const identity = command.identity?.trim();
    const password = command.password?.trim();
    const appType = command.appType;

    const requestedShop = command.requestedShopIdentifier
      ? await this.authRepository.resolveShopIdentifier(command.requestedShopIdentifier)
      : null;
    const requestedShopId = requestedShop?.id;

    if (!identity || !password) {
      throw new ValidationError("Email/mobile/store ID and password are required.");
    }

    const user = await this.authRepository.findUserByIdentity(identity, buildPhoneVariations(identity));

    if (!user || user.status !== "ACTIVE" || !(await verifyPassword(password, user.passwordHash))) {
      throw new InvalidCredentialsError("Invalid login credentials.", { clearAuthCookies: true });
    }

    const authContext = resolveAuthContext(user, appType, requestedShopId);

    if (!authContext || !isAllowedForAppType(authContext.role, appType)) {
      const appLabel = appType === "WEB" ? "web app" : "mobile app";
      throw new ForbiddenError(
        appType === "MOBILE" && requestedShopId
          ? "This mobile account is not allowed for the selected shop."
          : `This account is not allowed to log in to the ${appLabel}.`,
      );
    }

    let blockedOwnerSubscriptionAccess: any = null;

    if (appType === "MOBILE" && authContext.shopId) {
      const { evaluateSalesmanTrialAccess, evaluateShopSubscriptionAccess } = await import("../../../subscription/access");
      const subscriptionAccess = await evaluateShopSubscriptionAccess(authContext.shopId);

      if (!subscriptionAccess.allowed) {
        if (authContext.role === "SALESMAN") {
          const salesmanTrial = await evaluateSalesmanTrialAccess(authContext.shopId, user.id);

          if (!salesmanTrial.allowed) {
            throw new PaymentRequiredError(subscriptionAccess.message ?? "Subscription access denied.", {
              subscription: subscriptionAccess,
              salesmanTrial,
              clearAuthCookies: true,
            });
          }
        } else {
          blockedOwnerSubscriptionAccess = subscriptionAccess;
        }
      }
    }

    const rememberMe = command.rememberMe === true || String(command.rememberMe) === "true";
    const issued = await issueSession(this.authRepository, {
      userId: user.id,
      role: authContext.role,
      appType,
      shopId: authContext.shopId,
      rememberMe,
    });

    await this.authRepository.updateLastLogin(user.id);

    const shop = authContext.shopId ? await this.authRepository.findShopById(authContext.shopId) : null;

    let permissions = {
      canSell: true,
      canViewStock: true,
      canViewReports: true,
      canChangePrice: true,
      canCollectDue: true,
    };

    if (authContext.role === "SALESMAN" && authContext.shopId) {
      const salesmanPermissions = await this.authRepository.getSalesmanPermissions(authContext.shopId, user.id);
      if (salesmanPermissions) {
        permissions = salesmanPermissions;
      }
    }

    return {
      message: blockedOwnerSubscriptionAccess?.message ?? "Login successful.",
      redirectTo: getDefaultRedirect(authContext.role, appType),
      role: authContext.role,
      appType,
      subscription: blockedOwnerSubscriptionAccess,
      subscriptionLocked: blockedOwnerSubscriptionAccess?.allowed === false,
      permissions,
      tokens: issued,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: authContext.role,
        shop: shop ? { id: shop.id, name: shop.shopName, shopCode: shop.shopCode } : null,
      },
    };
  }
}
