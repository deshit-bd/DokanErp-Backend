import { ConflictError, ValidationError } from "@domain/shared/app-error";

import type { AuthRepository } from "../ports/auth-repository.port";

export class UpdateProfileUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(userId: string, input: { name: string | undefined; email: string | null | undefined; phone: string | null | undefined }) {
    const name = input.name?.trim();
    const email = input.email?.trim() || null;
    const phone = input.phone?.trim() || null;

    if (!name) {
      throw new ValidationError("Name is required.");
    }

    const existingByEmail = email ? await this.authRepository.findUserByAnyEmailExcept(email, userId) : null;

    if (existingByEmail) {
      throw new ConflictError("Email is already in use.");
    }

    const existingByPhone = phone ? await this.authRepository.findUserByAnyPhoneExcept(phone, userId) : null;

    if (existingByPhone) {
      throw new ConflictError("Phone is already in use.");
    }

    return this.authRepository.updateUserProfile(userId, { name, email, phone });
  }
}
