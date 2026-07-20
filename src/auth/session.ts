import { createHash, randomBytes, randomUUID } from "node:crypto";

import type { Response } from "express";

import type { AppType, AuthRole } from "./constants";
import {
  ACCESS_TOKEN_COOKIE,
  ACCESS_TOKEN_TTL_SECONDS,
  REFRESH_TOKEN_COOKIE,
  REFRESH_TOKEN_TTL_SECONDS,
} from "./constants";
import { signAccessToken } from "./jwt";
import { env } from "../config/env";

export function getAuthSecret() {
  return env.AUTH_JWT_SECRET;
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

export function getRefreshTokenExpiryDate(rememberMe: boolean = false) {
  const duration = rememberMe ? 60 * 60 * 24 * 3 : 60 * 60 * 24 * 1; // 3 days vs 1 day
  return new Date(Date.now() + duration * 1000);
}

function getCookieOptions(maxAge: number) {
  return {
    httpOnly: true,
    sameSite: "lax" as const,
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: maxAge * 1000,
  };
}

export function setAccessCookie(response: Response, token: string) {
  response.cookie(ACCESS_TOKEN_COOKIE, token, getCookieOptions(ACCESS_TOKEN_TTL_SECONDS));
}

export function setRefreshCookie(response: Response, token: string, rememberMe: boolean = false) {
  const duration = rememberMe ? 60 * 60 * 24 * 3 : 60 * 60 * 24 * 1; // 3 days vs 1 day
  response.cookie(REFRESH_TOKEN_COOKIE, token, getCookieOptions(duration));
}

export function clearAuthCookies(response: Response) {
  response.cookie(ACCESS_TOKEN_COOKIE, "", { ...getCookieOptions(ACCESS_TOKEN_TTL_SECONDS), maxAge: 0 });
  response.cookie(REFRESH_TOKEN_COOKIE, "", { ...getCookieOptions(REFRESH_TOKEN_TTL_SECONDS), maxAge: 0 });
}
