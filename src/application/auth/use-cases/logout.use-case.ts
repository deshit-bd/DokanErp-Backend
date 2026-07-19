import { hashRefreshToken } from "../../../auth/session";
import type { AuthRepository } from "../ports/auth-repository.port";

export class LogoutUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(refreshToken: string | undefined): Promise<void> {
    if (refreshToken) {
      await this.authRepository.revokeRefreshTokenByHash(hashRefreshToken(refreshToken));
    }
  }
}
