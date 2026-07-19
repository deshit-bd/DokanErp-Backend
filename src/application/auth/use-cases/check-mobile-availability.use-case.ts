import { normalizeMobile } from "@domain/auth/auth.entity";
import { ConflictError, ValidationError } from "@domain/shared/app-error";

import type { AuthRepository } from "../ports/auth-repository.port";

export class CheckMobileAvailabilityUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(rawMobile: string | undefined): Promise<{ message: string }> {
    const mobile = normalizeMobile(rawMobile);

    if (!mobile) {
      throw new ValidationError("Mobile number is required.");
    }

    const existingUser = await this.authRepository.findUserByPhone(mobile);

    if (existingUser) {
      throw new ConflictError("Mobile number is already in use by a salesman or owner.");
    }

    const duplicateDraft = await this.authRepository.findDuplicateRegistrationDraftByMobile(mobile);

    if (duplicateDraft) {
      throw new ConflictError("A pending registration already exists for this mobile number.");
    }

    return { message: "Mobile number is available." };
  }
}
