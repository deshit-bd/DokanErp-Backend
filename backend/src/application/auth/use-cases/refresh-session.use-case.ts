import { resolveAuthContext } from "@domain/auth/auth.entity";
import { AccountNotActiveError } from "@domain/auth/auth.errors";
import { ForbiddenError, PaymentRequiredError, UnauthorizedError } from "@domain/shared/app-error";

import type { AuthRepository } from "../ports/auth-repository.port";
import { getDefaultRedirect, isAllowedForAppType } from "../../../auth/authorization";
import { createAccessToken, createRefreshTokenValue, getRefreshTokenExpiryDate, hashRefreshToken } from "../../../auth/session";

export class RefreshSessionUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(refreshToken: string | undefined) {
    if (!refreshToken) {
      throw new UnauthorizedError("Refresh token missing.");
    }

    const tokenRecord = await this.authRepository.findRefreshTokenByHash(hashRefreshToken(refreshToken));

    if (!tokenRecord) {
      throw new UnauthorizedError("Invalid refresh token.", { clearAuthCookies: true });
    }

    if (tokenRecord.revokedAt || tokenRecord.expiresAt <= new Date()) {
      await this.authRepository.revokeRefreshFamily(tokenRecord.family);
      throw new UnauthorizedError("Refresh token expired.", { clearAuthCookies: true });
    }

    const user = tokenRecord.user;

    if (user.status !== "ACTIVE") {
      await this.authRepository.revokeRefreshFamily(tokenRecord.family);
      throw new AccountNotActiveError(undefined, { clearAuthCookies: true });
    }

    const authContext =
      tokenRecord.appType === "WEB"
        ? user.platformUser
          ? { role: user.platformUser.role as any }
          : null
        : resolveAuthContext(user, "MOBILE", undefined);

    if (!authContext || !isAllowedForAppType(authContext.role, tokenRecord.appType)) {
      await this.authRepository.revokeRefreshFamily(tokenRecord.family);
      throw new ForbiddenError("Login access is no longer allowed.", { clearAuthCookies: true });
    }

    let blockedOwnerSubscriptionAccess: any = null;

    if (tokenRecord.appType === "MOBILE" && "shopId" in authContext && authContext.shopId) {
      const { evaluateSalesmanTrialAccess, evaluateShopSubscriptionAccess } = await import("../../../subscription/access");
      const subscriptionAccess = await evaluateShopSubscriptionAccess(authContext.shopId);

      if (!subscriptionAccess.allowed) {
        if (authContext.role === "SALESMAN") {
          const salesmanTrial = await evaluateSalesmanTrialAccess(authContext.shopId, user.id);

          if (!salesmanTrial.allowed) {
            await this.authRepository.revokeRefreshFamily(tokenRecord.family);
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

    await this.authRepository.revokeRefreshToken(tokenRecord.id);

    const durationMs = tokenRecord.expiresAt.getTime() - tokenRecord.createdAt.getTime();
    const rememberMe = durationMs > 1.5 * 24 * 60 * 60 * 1000;

    const rotatedRefreshToken = createRefreshTokenValue();
    await this.authRepository.createRefreshToken({
      userId: user.id,
      tokenHash: hashRefreshToken(rotatedRefreshToken),
      family: tokenRecord.family,
      appType: tokenRecord.appType,
      expiresAt: getRefreshTokenExpiryDate(rememberMe),
    });

    const accessToken = createAccessToken({
      userId: user.id,
      role: authContext.role,
      appType: tokenRecord.appType,
      sessionFamily: tokenRecord.family,
      shopId: "shopId" in authContext ? authContext.shopId : undefined,
    });

    return {
      message: blockedOwnerSubscriptionAccess?.message ?? "Session refreshed.",
      redirectTo: getDefaultRedirect(authContext.role, tokenRecord.appType),
      role: authContext.role,
      appType: tokenRecord.appType,
      subscription: blockedOwnerSubscriptionAccess,
      subscriptionLocked: blockedOwnerSubscriptionAccess?.allowed === false,
      tokens: { accessToken, refreshToken: rotatedRefreshToken },
    };
  }
}
