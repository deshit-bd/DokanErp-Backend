import type { AppType, AuthRole } from "@domain/shared/auth-role";

import type { AuthRepository } from "./ports/auth-repository.port";

// Bridges to the existing (not-yet-migrated) token primitives in
// src/auth/session.ts and src/auth/jwt.ts rather than re-wrapping them in a
// new port: they're already framework-agnostic pure functions (no Express
// dependency), the same reasoning that lets adapters/http/middleware/
// auth.middleware.ts bridge into src/auth/current-user.ts.
import {
  createAccessToken,
  createRefreshTokenValue,
  createSessionFamily,
  getRefreshTokenExpiryDate,
  hashRefreshToken,
} from "../../auth/session";

export type IssuedSession = {
  accessToken: string;
  refreshToken: string;
  sessionFamily: string;
};

export async function issueSession(
  repository: AuthRepository,
  input: { userId: string; role: AuthRole; appType: AppType; shopId?: string; rememberMe?: boolean },
): Promise<IssuedSession> {
  const sessionFamily = createSessionFamily();
  const refreshToken = createRefreshTokenValue();

  await repository.createRefreshToken({
    userId: input.userId,
    tokenHash: hashRefreshToken(refreshToken),
    family: sessionFamily,
    appType: input.appType,
    expiresAt: getRefreshTokenExpiryDate(input.rememberMe ?? false),
  });

  const accessToken = createAccessToken({
    userId: input.userId,
    role: input.role,
    appType: input.appType,
    sessionFamily,
    shopId: input.shopId,
  });

  return { accessToken, refreshToken, sessionFamily };
}
