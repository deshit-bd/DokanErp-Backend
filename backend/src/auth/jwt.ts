import { createHmac } from "node:crypto";

import type { AppType, AuthRole } from "./constants";

type SupportedTokenType = "access";

export type AccessTokenPayload = {
  sub: string;
  appType: AppType;
  role: AuthRole;
  tokenType: SupportedTokenType;
  sessionFamily: string;
  shopId?: string;
  iat: number;
  exp: number;
};

function base64UrlEncode(value: string | Buffer) {
  return Buffer.from(value)
    .toString("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
}

function base64UrlDecode(value: string) {
  const normalized = value.replace(/-/g, "+").replace(/_/g, "/");
  const padding = normalized.length % 4 === 0 ? "" : "=".repeat(4 - (normalized.length % 4));
  return Buffer.from(`${normalized}${padding}`, "base64").toString("utf8");
}

function signSegment(input: string, secret: string) {
  return createHmac("sha256", secret).update(input).digest("base64url");
}

export function signAccessToken(
  payload: Omit<AccessTokenPayload, "iat" | "exp" | "tokenType">,
  secret: string,
  expiresInSeconds: number,
) {
  const now = Math.floor(Date.now() / 1000);
  const tokenPayload: AccessTokenPayload = {
    ...payload,
    tokenType: "access",
    iat: now,
    exp: now + expiresInSeconds,
  };

  const header = {
    alg: "HS256",
    typ: "JWT",
  };

  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedPayload = base64UrlEncode(JSON.stringify(tokenPayload));
  const signature = signSegment(`${encodedHeader}.${encodedPayload}`, secret);

  return `${encodedHeader}.${encodedPayload}.${signature}`;
}

export function verifyAccessToken(token: string, secret: string) {
  const [encodedHeader, encodedPayload, signature] = token.split(".");

  if (!encodedHeader || !encodedPayload || !signature) {
    return null;
  }

  const expectedSignature = signSegment(`${encodedHeader}.${encodedPayload}`, secret);

  if (signature !== expectedSignature) {
    return null;
  }

  try {
    const payload = JSON.parse(base64UrlDecode(encodedPayload)) as AccessTokenPayload;

    if (payload.tokenType !== "access" || payload.exp <= Math.floor(Date.now() / 1000)) {
      return null;
    }

    return payload;
  } catch {
    return null;
  }
}
