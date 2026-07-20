import { hashOtpCode, normalizeMobile, resolveAuthContext } from "@domain/auth/auth.entity";
import { ValidationError } from "@domain/shared/app-error";

import { issueSession } from "../issue-session";
import type { AuthRepository } from "../ports/auth-repository.port";

export type VerifyRegistrationOtpCommand = {
  registrationId: string | undefined;
  mobile: string | undefined;
  otp: string | undefined;
};

export class VerifyRegistrationOtpUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(command: VerifyRegistrationOtpCommand) {
    const registrationId = command.registrationId?.trim() ?? "";
    const mobile = normalizeMobile(command.mobile);
    const otpCode = command.otp?.trim() ?? "";

    if (!mobile || !otpCode) {
      throw new ValidationError("Mobile number and OTP are required.");
    }

    const otp = await this.authRepository.findLatestPendingOtpByRecipient(mobile);

    if (!otp || otp.status !== "PENDING") {
      throw new ValidationError("No active OTP found for this registration.");
    }

    if (otp.expiresAt <= new Date()) {
      await this.authRepository.markOtpExpired(otp.id);
      throw new ValidationError("OTP has expired.");
    }

    const nextAttempts = Number(otp.attempts ?? 0) + 1;

    if (otp.codeHash !== hashOtpCode(otpCode)) {
      await this.authRepository.recordFailedOtpAttempt(otp.id, nextAttempts, nextAttempts >= Number(otp.maxAttempts ?? 5));
      throw new ValidationError("Invalid OTP.");
    }

    const verifiedAt = new Date();
    await this.authRepository.markOtpVerified(otp.id, verifiedAt, nextAttempts);

    if (registrationId) {
      await this.authRepository.markRegistrationDraftOtpVerified(
        registrationId,
        verifiedAt,
        new Date(Date.now() + 30 * 60 * 1000),
      );
    }

    const phoneVariations = [mobile, "0" + mobile, "+880" + mobile, "880" + mobile];
    const user = await this.authRepository.findUserByIdentity(mobile, phoneVariations);

    let session: { authenticated: true; role: string; appType: string; tokens: { accessToken: string; refreshToken: string }; user: { id: string; name: string; mobile: string | null }; shop: { id: string; shopCode: string | null; shopName: string | null } | null } | null = null;

    if (user) {
      const authContext = resolveAuthContext(user, "MOBILE");
      if (authContext) {
        const issued = await issueSession(this.authRepository, {
          userId: user.id,
          role: authContext.role,
          appType: "MOBILE",
          shopId: authContext.shopId,
        });

        session = {
          authenticated: true,
          role: authContext.role,
          appType: "MOBILE",
          tokens: { accessToken: issued.accessToken, refreshToken: issued.refreshToken },
          user: { id: user.id, name: user.name, mobile: user.phone },
          shop: authContext.shopId
            ? {
                id: authContext.shopId,
                shopCode: user.ownedShops.find((s) => s.id === authContext.shopId)?.shopCode ?? null,
                shopName: user.ownedShops.find((s) => s.id === authContext.shopId)?.shopName ?? null,
              }
            : null,
        };
      }
    }

    return { registrationId: registrationId || otp.id, session };
  }
}
