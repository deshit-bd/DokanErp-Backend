import { generateOtpCode, getOtpExpiryDate, hashOtpCode, normalizeMobile } from "@domain/auth/auth.entity";
import { ValidationError } from "@domain/shared/app-error";

import type { AuthRepository } from "../ports/auth-repository.port";

export class SendRegistrationOtpUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(rawMobile: string | undefined, registrationId: string | undefined) {
    const mobile = normalizeMobile(rawMobile);

    if (!mobile) {
      throw new ValidationError("Mobile number is required.");
    }

    const code = generateOtpCode();
    const otp = await this.authRepository.createOtp({
      purpose: "REGISTRATION",
      recipient: mobile,
      codeHash: hashOtpCode(code),
      expiresAt: getOtpExpiryDate(),
    });

    const trimmedRegistrationId = registrationId?.trim() ?? "";

    if (trimmedRegistrationId) {
      const draft = await this.authRepository.findActiveRegistrationDraft(trimmedRegistrationId);
      if (draft && draft.mobile === mobile) {
        await this.authRepository.linkOtpToRegistrationDraft(draft.id, otp.id);
      }
    }

    console.log(`[auth] OTP for ${mobile}: ${code}`);

    return {
      registrationId: trimmedRegistrationId || otp.id,
      expiresAt: otp.expiresAt,
      demoOtp: code,
    };
  }
}
