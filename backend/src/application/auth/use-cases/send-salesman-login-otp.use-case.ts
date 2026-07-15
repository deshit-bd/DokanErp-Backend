import { generateOtpCode, getOtpExpiryDate, getOtpExpirySeconds, hashOtpCode } from "@domain/auth/auth.entity";

import type { AuthRepository } from "../ports/auth-repository.port";
import { VerifySalesmanCredentialsUseCase } from "./verify-salesman-credentials.use-case";

export class SendSalesmanLoginOtpUseCase {
  private readonly verifySalesmanCredentials: VerifySalesmanCredentialsUseCase;

  constructor(private readonly authRepository: AuthRepository) {
    this.verifySalesmanCredentials = new VerifySalesmanCredentialsUseCase(authRepository);
  }

  async execute(rawMobile: string | undefined, rawPassword: string | undefined, rawShopIdentifier: string | undefined) {
    const { mobile, shopId, user, authContext } = await this.verifySalesmanCredentials.execute(
      rawMobile,
      rawPassword,
      rawShopIdentifier,
    );

    await this.authRepository.cancelPendingLoginOtps(user.id, shopId);

    const code = generateOtpCode();
    const otp = await this.authRepository.createOtp({
      userId: user.id,
      shopId: authContext.shopId ?? shopId,
      purpose: "LOGIN",
      recipient: mobile,
      codeHash: hashOtpCode(code),
      expiresAt: getOtpExpiryDate(),
    });

    console.log(`[auth] Salesman login OTP for ${mobile} (${otp.id}) shop ${shopId}: ${code}`);

    return {
      loginRequestId: otp.id,
      expiresAt: otp.expiresAt,
      expiresInSeconds: getOtpExpirySeconds(),
      demoOtp: code,
    };
  }
}
