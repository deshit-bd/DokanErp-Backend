import { getPostOtpVerifiedExpiryDate, hashOtpCode, validatePinRules } from "@domain/auth/auth.entity";
import { NotFoundError, ValidationError } from "@domain/shared/app-error";

import type { AuthRepository } from "../ports/auth-repository.port";

export class SetupRegistrationPinUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(registrationId: string | undefined, pin: string | undefined, confirmPin: string | undefined) {
    const id = registrationId?.trim() ?? "";
    const pinValue = pin?.trim() ?? "";
    const confirmPinValue = confirmPin?.trim() ?? "";

    if (!id || !pinValue || !confirmPinValue) {
      throw new ValidationError("registrationId, pin, and confirmPin are required.");
    }
    if (!validatePinRules(pinValue)) {
      throw new ValidationError("PIN must be exactly 4 digits.");
    }
    if (pinValue !== confirmPinValue) {
      throw new ValidationError("Confirm PIN does not match.");
    }

    const draft = await this.authRepository.findActiveRegistrationDraft(id);

    if (!draft) {
      throw new NotFoundError("Registration draft not found.");
    }
    if (!draft.otpVerifiedAt) {
      throw new ValidationError("OTP must be verified before setting a PIN.");
    }

    await this.authRepository.setRegistrationDraftPin(draft.id, hashOtpCode(pinValue), new Date(), getPostOtpVerifiedExpiryDate());

    return { registrationId: draft.id };
  }
}
