import { generateOtpCode, getOtpExpiryDate, getOtpExpirySeconds, hashOtpCode } from "@domain/auth/auth.entity";

import type { AuthRepository } from "../ports/auth-repository.port";
import { VerifyOwnerCredentialsUseCase } from "./verify-owner-credentials.use-case";

// Backs all three of /pre-login, /send-owner-login-otp, /owners-login-otp —
// they call the same underlying handler in the original route file.
export class SendOwnerLoginOtpUseCase {
  private readonly verifyOwnerCredentials: VerifyOwnerCredentialsUseCase;

  constructor(private readonly authRepository: AuthRepository) {
    this.verifyOwnerCredentials = new VerifyOwnerCredentialsUseCase(authRepository);
  }

  async execute(rawMobile: string | undefined, rawPassword: string | undefined) {
    const { mobile, user, authContext } = await this.verifyOwnerCredentials.execute(rawMobile, rawPassword);

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

    console.log(`[auth] Owner login OTP for ${mobile} (${otp.id}): ${code}`);

    return {
      loginRequestId: otp.id,
      expiresAt: otp.expiresAt,
      expiresInSeconds: getOtpExpirySeconds(),
      demoOtp: code,
    };
  }
}
