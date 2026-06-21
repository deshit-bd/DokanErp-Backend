import { NextRequest, NextResponse } from "next/server";

import { ACCESS_TOKEN_COOKIE } from "@/lib/auth/constants";

type AccessTokenPayload = {
  sub: string;
  appType: "WEB" | "MOBILE";
  role: "SUPER_ADMIN" | "ADMIN" | "SHOP_OWNER" | "SALESMAN";
  tokenType: "access";
  sessionFamily: string;
  shopId?: string;
  iat: number;
  exp: number;
};

function base64UrlToBase64(input: string) {
  const normalized = input.replace(/-/g, "+").replace(/_/g, "/");
  const padding = normalized.length % 4 === 0 ? "" : "=".repeat(4 - (normalized.length % 4));
  return `${normalized}${padding}`;
}

function bytesToBase64Url(bytes: Uint8Array) {
  let binary = "";

  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }

  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

function decodePayload(input: string) {
  return JSON.parse(atob(base64UrlToBase64(input))) as AccessTokenPayload;
}

async function verifyAccessToken(token: string, secret: string) {
  const [encodedHeader, encodedPayload, signature] = token.split(".");

  if (!encodedHeader || !encodedPayload || !signature) {
    return null;
  }

  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signed = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(`${encodedHeader}.${encodedPayload}`),
  );

  const expectedSignature = bytesToBase64Url(new Uint8Array(signed));

  if (expectedSignature !== signature) {
    return null;
  }

  const payload = decodePayload(encodedPayload);

  if (payload.tokenType !== "access" || payload.exp <= Math.floor(Date.now() / 1000)) {
    return null;
  }

  return payload;
}

function clearAccessCookie(response: NextResponse) {
  response.cookies.set(ACCESS_TOKEN_COOKIE, "", {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: 0,
  });
  return response;
}

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const token = request.cookies.get(ACCESS_TOKEN_COOKIE)?.value;
  const isSuperAdminPath = pathname.startsWith("/super-admin");
  const isShopPath = pathname.startsWith("/shop");

  const isPublicPath =
    pathname === "/" ||
    pathname === "/login" ||
    pathname === "/super-admin/login" ||
    pathname.startsWith("/api/auth/login") ||
    pathname.startsWith("/api/auth/refresh") ||
    pathname.startsWith("/api/auth/logout");

  if (!token) {
    if (isPublicPath || pathname.startsWith("/api/")) {
      return NextResponse.next();
    }

    return NextResponse.redirect(new URL("/login", request.url));
  }

  const secret = process.env.AUTH_JWT_SECRET || process.env.JWT_SECRET || "dev-only-auth-secret";
  const payload = await verifyAccessToken(token, secret);

  if (!payload) {
    if (isPublicPath || pathname.startsWith("/api/")) {
      return clearAccessCookie(NextResponse.next());
    }

    return clearAccessCookie(NextResponse.redirect(new URL("/login", request.url)));
  }

  if (pathname === "/") {
    if (payload.appType === "WEB") {
      return NextResponse.redirect(new URL("/super-admin/dashboard", request.url));
    }

    if (payload.appType === "MOBILE") {
      return NextResponse.redirect(new URL("/shop/dashboard", request.url));
    }
  }

  if (pathname === "/login") {
    if (payload.appType === "WEB") {
      return NextResponse.redirect(new URL("/super-admin/dashboard", request.url));
    }

    return clearAccessCookie(NextResponse.redirect(new URL("/super-admin/login", request.url)));
  }

  if (pathname === "/super-admin/login") {
    if (payload.appType === "WEB") {
      return NextResponse.redirect(new URL("/super-admin/dashboard", request.url));
    }

    return clearAccessCookie(NextResponse.next());
  }

  if (isSuperAdminPath) {
    if (payload.appType !== "WEB" || (payload.role !== "SUPER_ADMIN" && payload.role !== "ADMIN")) {
      return clearAccessCookie(NextResponse.redirect(new URL("/super-admin/login", request.url)));
    }
  }

  if (isShopPath) {
    if (payload.appType !== "MOBILE" || (payload.role !== "SHOP_OWNER" && payload.role !== "SALESMAN")) {
      return clearAccessCookie(NextResponse.redirect(new URL("/login", request.url)));
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/",
    "/login",
    "/shop/:path*",
    "/super-admin/:path*",
    "/api/auth/:path*",
  ],
};
