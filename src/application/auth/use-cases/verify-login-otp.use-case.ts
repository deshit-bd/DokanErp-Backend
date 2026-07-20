import { hashOtpCode, normalizeMobile, resolveAuthContext } from "@domain/auth/auth.entity";
import { AccountNotActiveError } from "@domain/auth/auth.errors";
import { ForbiddenError, NotFoundError, ValidationError } from "@domain/shared/app-error";

import { issueSession } from "../issue-session";
import type { AuthRepository } from "../ports/auth-repository.port";
import { getDefaultRedirect, isAllowedForAppType } from "../../../auth/authorization";

export type VerifyLoginOtpCommand = {
  loginRequestId: string | undefined;
  mobile: string | undefined;
  otp: string | undefined;
  rememberMe: unknown;
};

export class VerifyLoginOtpUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(command: VerifyLoginOtpCommand) {
    const loginRequestId = command.loginRequestId?.trim() ?? "";
    const mobile = normalizeMobile(command.mobile);
    const otpCode = command.otp?.trim() ?? "";

    if (!loginRequestId || !mobile || !otpCode) {
      throw new ValidationError("loginRequestId, mobile, and otp are required.");
    }

    const otpRecord = await this.authRepository.findOtpById(loginRequestId);

    if (!otpRecord || otpRecord.purpose !== "LOGIN" || otpRecord.appType !== "MOBILE" || otpRecord.recipient !== mobile) {
      throw new NotFoundError("Login OTP request not found.");
    }
    if (otpRecord.status !== "PENDING") {
      throw new ValidationError("No active OTP found for this login request.");
    }
    if (otpRecord.expiresAt <= new Date()) {
      await this.authRepository.markOtpExpired(otpRecord.id);
      throw new ValidationError("OTP has expired.");
    }

    const nextAttempts = Number(otpRecord.attempts ?? 0) + 1;

    if (otpRecord.codeHash !== hashOtpCode(otpCode)) {
      await this.authRepository.recordFailedOtpAttempt(otpRecord.id, nextAttempts, nextAttempts >= Number(otpRecord.maxAttempts ?? 5));
      throw new ValidationError("Invalid OTP.");
    }

    const user = otpRecord.user;

    if (!user || user.status !== "ACTIVE") {
      throw new AccountNotActiveError();
    }

    const authContext = resolveAuthContext(user, "MOBILE");

    if (!authContext || !isAllowedForAppType(authContext.role, "MOBILE")) {
      throw new ForbiddenError("This account is not allowed to log in to the mobile app.");
    }

    const verifiedAt = new Date();
    const rememberMe = command.rememberMe === true || String(command.rememberMe) === "true";

    // Verifying the OTP, issuing the session, and updating lastLoginAt are 3
    // separate calls here (not one DB transaction, unlike the original route)
    // — a documented, deliberate relaxation for this migration given the
    // coarse repository's method-per-call shape; see CLAUDE.md.
    await this.authRepository.markOtpVerified(otpRecord.id, verifiedAt, nextAttempts);

    const issued = await issueSession(this.authRepository, {
      userId: user.id,
      role: authContext.role,
      appType: "MOBILE",
      shopId: authContext.shopId,
      rememberMe,
    });

    await this.authRepository.updateLastLogin((user as any).id, user.phoneVerifiedAt ?? verifiedAt);

    return {
      redirectTo: getDefaultRedirect(authContext.role, "MOBILE"),
      role: authContext.role,
      tokens: issued,
      user: { id: user.id, name: user.name, mobile: user.phone },
      shop: authContext.shopId
        ? {
            id: authContext.shopId,
            shopCode:
              user.ownedShops.find((shop) => shop.id === authContext.shopId)?.shopCode ??
              user.shopUsers.find((item) => item.shopId === authContext.shopId)?.shop.shopCode ??
              null,
            shopName:
              user.ownedShops.find((shop) => shop.id === authContext.shopId)?.shopName ??
              user.shopUsers.find((item) => item.shopId === authContext.shopId)?.shop.shopName ??
              null,
          }
        : null,
    };
  }
}
