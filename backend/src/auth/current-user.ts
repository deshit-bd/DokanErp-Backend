import type { Request, Response } from "express";
import type { UserStatus } from "@prisma/client";

import { prisma } from "../config/prisma";

import { parseCookies } from "./cookies";
import { ACCESS_TOKEN_COOKIE } from "./constants";
import type { AccessTokenPayload } from "./jwt";
import { getAuthSecret } from "./session";
import { verifyAccessToken } from "./jwt";

export type AuthError = {
  status: number;
  body: { message: string };
};

export type AuthenticatedUser = {
  user: {
    id: string;
    name: string;
    email: string | null;
    phone: string | null;
    profileImageUrl: string | null;
    status: UserStatus;
  };
  payload: AccessTokenPayload;
};

export async function getAuthenticatedUser(request: Request) {
  const accessToken = parseCookies(request)[ACCESS_TOKEN_COOKIE];

  if (!accessToken) {
    return { status: 401, body: { message: "Not authenticated." } };
  }

  const payload = verifyAccessToken(accessToken, getAuthSecret());

  if (!payload) {
    return { status: 401, body: { message: "Session expired." } };
  }

  const user = await prisma.user.findUnique({
    where: { id: payload.sub },
    select: {
      id: true,
      name: true,
      email: true,
      phone: true,
      profileImageUrl: true,
      status: true,
    },
  });

  if (!user) {
    return { status: 404, body: { message: "User not found." } };
  }

  return { user, payload };
}

export function isAuthError(auth: AuthError | AuthenticatedUser): auth is AuthError {
  return "status" in auth;
}

export function sendAuthError(response: Response, auth: AuthError) {
  return response.status(auth.status).json(auth.body);
}
