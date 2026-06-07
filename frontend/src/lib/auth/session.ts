import { createHash, randomBytes, randomUUID } from "node:crypto";

import type { AppType, AuthRole } from "./constants";
import {
  ACCESS_TOKEN_COOKIE,
  ACCESS_TOKEN_TTL_SECONDS,
  REFRESH_TOKEN_COOKIE,
  REFRESH_TOKEN_TTL_SECONDS,
} from "./constants";
import { signAccessToken } from "./jwt";

export function getAuthSecret() {
  return process.env.AUTH_JWT_SECRET || process.env.JWT_SECRET || "dev-only-auth-secret";
}

export function hashRefreshToken(token: string) {
  return createHash("sha256").update(token).digest("hex");
}

export function createRefreshTokenValue() {
  return randomBytes(48).toString("base64url");
}

export function createSessionFamily() {
  return randomUUID();
}

export function createAccessToken(input: {
  userId: string;
  role: AuthRole;
  appType: AppType;
  sessionFamily: string;
  shopId?: string;
}) {
  return signAccessToken(
    {
      sub: input.userId,
      role: input.role,
      appType: input.appType,
      sessionFamily: input.sessionFamily,
      shopId: input.shopId,
    },
    getAuthSecret(),
    ACCESS_TOKEN_TTL_SECONDS,
  );
}

export function getRefreshTokenExpiryDate() {
  return new Date(Date.now() + REFRESH_TOKEN_TTL_SECONDS * 1000);
}

export function getCookieOptions(maxAge: number) {
  return {
    httpOnly: true,
    sameSite: "lax" as const,
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge,
  };
}

export function getAccessCookieOptions() {
  return getCookieOptions(ACCESS_TOKEN_TTL_SECONDS);
}

export function getRefreshCookieOptions() {
  return getCookieOptions(REFRESH_TOKEN_TTL_SECONDS);
}

export function clearAuthCookies(response: {
  cookies: {
    set: (name: string, value: string, options: Record<string, unknown>) => void;
  };
}) {
  response.cookies.set(ACCESS_TOKEN_COOKIE, "", { ...getAccessCookieOptions(), maxAge: 0 });
  response.cookies.set(REFRESH_TOKEN_COOKIE, "", { ...getRefreshCookieOptions(), maxAge: 0 });
}
