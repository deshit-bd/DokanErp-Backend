import { buildPhoneVariations, generateOtpCode, getOtpExpiryDate, getOtpExpirySeconds, hashOtpCode, normalizeMobile, resolveAuthContext } from "@domain/auth/auth.entity";
import { ForbiddenError, NotFoundError, ValidationError } from "@domain/shared/app-error";

import type { AuthRepository } from "../ports/auth-repository.port";
import { isAllowedForAppType } from "../../../auth/authorization";

// Distinct from send-owner/send-salesman-login-otp use cases: this generic
// flow does NOT verify a password — matches the original /send-login-otp
// route exactly (a pre-existing passwordless-OTP-request design, not
// something introduced by this migration).
export class SendLoginOtpUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(rawMobile: string | undefined) {
    const mobile = normalizeMobile(rawMobile);

    if (!mobile) {
      throw new ValidationError("Mobile number is required.");
    }

    const user = await this.authRepository.findUserByIdentity(mobile, buildPhoneVariations(mobile));

    const isPhoneMatch = user?.phone ? normalizeMobile(user.phone) === normalizeMobile(mobile) : false;
    const isEmailMatch = user?.email ? user.email.toLowerCase() === mobile.toLowerCase() : false;

    if (!user || (!isPhoneMatch && !isEmailMatch) || user.status !== "ACTIVE") {
      throw new NotFoundError("No active account found for this mobile number.");
    }

    const authContext = resolveAuthContext(user, "MOBILE");

    if (!authContext || !isAllowedForAppType(authContext.role, "MOBILE")) {
      throw new ForbiddenError("This account is not allowed to log in to the mobile app.");
    }

    await this.authRepository.cancelPendingLoginOtps(user.id);

    const code = generateOtpCode();
    const otp = await this.authRepository.createOtp({
      userId: user.id,
      shopId: authContext.shopId ?? null,
      purpose: "LOGIN",
      recipient: mobile,
      codeHash: hashOtpCode(code),
      expiresAt: getOtpExpiryDate(),
    });

    console.log(`[auth] Login OTP for ${mobile} (${otp.id}): ${code}`);

    return {
      loginRequestId: otp.id,
      expiresAt: otp.expiresAt,
      expiresInSeconds: getOtpExpirySeconds(),
      demoOtp: code,
    };
  }
}
