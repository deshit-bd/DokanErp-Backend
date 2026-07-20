import { ValidationError } from "@domain/shared/app-error";

import type { AuthRepository } from "../ports/auth-repository.port";

export class UpdateAvatarUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(userId: string, profileImageUrl: string | undefined) {
    const trimmed = profileImageUrl?.trim();

    if (!trimmed) {
      throw new ValidationError("Profile image path is required.");
    }

    return this.authRepository.updateUserAvatar(userId, trimmed);
  }
}
