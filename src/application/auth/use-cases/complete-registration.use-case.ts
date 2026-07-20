import { ConflictError, NotFoundError, ValidationError } from "@domain/shared/app-error";

import { issueSession } from "../issue-session";
import type { AuthRepository } from "../ports/auth-repository.port";

export class CompleteRegistrationUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(registrationId: string | undefined) {
    const id = registrationId?.trim() ?? "";

    if (!id) {
      throw new ValidationError("registrationId is required.");
    }

    const draft = await this.authRepository.findRegistrationDraftWithOtp(id);

    if (!draft) {
      throw new NotFoundError("Registration draft not found.");
    }
    if (!draft.otpVerifiedAt) {
      throw new ValidationError("OTP must be verified before completing registration.");
    }
    if (!draft.pinHash) {
      throw new ValidationError("PIN must be set before completing registration.");
    }
    if (draft.completedAt || draft.status === "COMPLETED") {
      throw new ValidationError("Registration has already been completed.");
    }

    const [existingUserByPhone, existingUserByEmail, existingShopByName] = await Promise.all([
      this.authRepository.findUserByPhone(draft.mobile),
      draft.email ? this.authRepository.findUserByEmail(draft.email) : Promise.resolve(null),
      this.authRepository.findShopByName(draft.shopName),
    ]);

    if (existingUserByPhone || existingUserByEmail || existingShopByName) {
      throw new ConflictError("Registration can no longer be completed because the owner or shop already exists.");
    }

    const result = await this.authRepository.completeRegistrationDraft(draft);

    const issued = await issueSession(this.authRepository, {
      userId: result.user.id,
      role: "SHOP_OWNER",
      appType: "MOBILE",
      shopId: result.shop.id,
    });

    return { result, tokens: issued };
  }
}
