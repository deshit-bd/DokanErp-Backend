import { validatePasswordRules } from "@domain/auth/auth.entity";
import { NotFoundError, ValidationError } from "@domain/shared/app-error";

import type { AuthRepository } from "../ports/auth-repository.port";
import { hashPassword, verifyPassword } from "../../../auth/password";

export class ChangePasswordUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(userId: string, input: { currentPassword: string | undefined; newPassword: string | undefined; confirmPassword: string | undefined }) {
    const currentPassword = input.currentPassword?.trim() ?? "";
    const newPassword = input.newPassword?.trim() ?? "";
    const confirmPassword = input.confirmPassword?.trim() ?? "";

    if (!currentPassword || !newPassword || !confirmPassword) {
      throw new ValidationError("Current password, new password, and confirm password are required.");
    }
    if (!validatePasswordRules(newPassword)) {
      throw new ValidationError("New password must be at least 4 characters.");
    }
    if (newPassword !== confirmPassword) {
      throw new ValidationError("Confirm password does not match.");
    }

    const existingUser = await this.authRepository.findUserPasswordHash(userId);

    if (!existingUser) {
      throw new NotFoundError("User not found.");
    }
    if (!(await verifyPassword(currentPassword, existingUser.passwordHash))) {
      throw new ValidationError("Current password is incorrect.");
    }
    if (currentPassword === newPassword) {
      throw new ValidationError("New password must be different from current password.");
    }

    await this.authRepository.updateUserPassword(userId, await hashPassword(newPassword));
  }
}
