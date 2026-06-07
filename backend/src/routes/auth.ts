import { AppType, UserStatus } from "@prisma/client";
import { Router } from "express";

import { prisma } from "../config/prisma";

import { getDefaultRedirect, isAllowedForAppType } from "../auth/authorization";
import { parseCookies } from "../auth/cookies";
import { REFRESH_TOKEN_COOKIE, type AuthRole } from "../auth/constants";
import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { verifyPassword } from "../auth/password";
import {
  clearAuthCookies,
  createAccessToken,
  createRefreshTokenValue,
  createSessionFamily,
  getRefreshTokenExpiryDate,
  hashRefreshToken,
  setAccessCookie,
  setRefreshCookie,
} from "../auth/session";

const router = Router();

type LoginBody = {
  identity?: string;
  password?: string;
  appType?: AppType;
};

async function findUserByIdentity(identity: string) {
  const user = await prisma.user.findFirst({
    where: {
      OR: [{ email: identity }, { phone: identity }],
    },
    include: {
      platformUser: true,
      shopUsers: {
        include: {
          shop: true,
        },
      },
    },
  });

  if (user) {
    return user;
  }

  const shop = await prisma.shop.findFirst({
    where: { shopName: identity },
    include: {
      owner: {
        include: {
          platformUser: true,
          shopUsers: {
            include: {
              shop: true,
            },
          },
        },
      },
    },
  });

  return shop?.owner ?? null;
}

function resolveAuthContext(
  user: Awaited<ReturnType<typeof findUserByIdentity>>,
  appType: AppType,
): { role: AuthRole; shopId?: string } | null {
  if (!user) {
    return null;
  }

  if (appType === AppType.WEB) {
    return user.platformUser ? { role: user.platformUser.role as AuthRole } : null;
  }

  const activeMembership = user.shopUsers.find(
    (membership) => membership.shop.status !== "BLOCKED" && membership.shop.status !== "SUSPENDED",
  );

  if (!activeMembership) {
    return null;
  }

  return {
    role: activeMembership.role as AuthRole,
    shopId: activeMembership.shopId,
  };
}

async function revokeRefreshFamily(family: string) {
  await prisma.refreshToken.updateMany({
    where: {
      family,
      revokedAt: null,
    },
    data: {
      revokedAt: new Date(),
    },
  });
}

router.post("/login", async (request, response) => {
  try {
    const body = request.body as LoginBody;
    const identity = body.identity?.trim();
    const password = body.password?.trim();
    const appType = body.appType ?? AppType.WEB;

    if (!identity || !password) {
      return response.status(400).json({ message: "Email/mobile/store ID and password are required." });
    }

    const user = await findUserByIdentity(identity);

    if (!user || user.status !== UserStatus.ACTIVE || !verifyPassword(password, user.passwordHash)) {
      clearAuthCookies(response);
      return response.status(401).json({ message: "Invalid login credentials." });
    }

    const authContext = resolveAuthContext(user, appType);

    if (!authContext || !isAllowedForAppType(authContext.role, appType)) {
      const appLabel = appType === AppType.WEB ? "web app" : "mobile app";
      return response
        .status(403)
        .json({ message: `This account is not allowed to log in to the ${appLabel}.` });
    }

    const refreshToken = createRefreshTokenValue();
    const sessionFamily = createSessionFamily();
    const refreshTokenRecord = await prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: hashRefreshToken(refreshToken),
        family: sessionFamily,
        appType,
        expiresAt: getRefreshTokenExpiryDate(),
      },
    });

    const accessToken = createAccessToken({
      userId: user.id,
      role: authContext.role,
      appType,
      sessionFamily: refreshTokenRecord.family,
      shopId: authContext.shopId,
    });

    await prisma.user.update({
      where: { id: user.id },
      data: {
        lastLoginAt: new Date(),
      },
    });

    setAccessCookie(response, accessToken);
    setRefreshCookie(response, refreshToken);

    return response.json({
      message: "Login successful.",
      redirectTo: getDefaultRedirect(authContext.role, appType),
      role: authContext.role,
      appType,
    });
  } catch (error) {
    console.error("Login route error:", error);

    const message =
      error instanceof Error && /Can't reach database server|connect|database/i.test(error.message)
        ? "Database is not ready. Start PostgreSQL and run Prisma setup first."
        : "Login service failed. Please check server setup and try again.";

    return response.status(500).json({ message });
  }
});

router.post("/refresh", async (request, response) => {
  const refreshToken = parseCookies(request)[REFRESH_TOKEN_COOKIE];

  if (!refreshToken) {
    return response.status(401).json({ message: "Refresh token missing." });
  }

  const tokenRecord = await prisma.refreshToken.findUnique({
    where: {
      tokenHash: hashRefreshToken(refreshToken),
    },
    include: {
      user: {
        include: {
          platformUser: true,
          shopUsers: {
            include: {
              shop: true,
            },
          },
        },
      },
    },
  });

  if (!tokenRecord) {
    clearAuthCookies(response);
    return response.status(401).json({ message: "Invalid refresh token." });
  }

  if (tokenRecord.revokedAt || tokenRecord.expiresAt <= new Date()) {
    await revokeRefreshFamily(tokenRecord.family);
    clearAuthCookies(response);
    return response.status(401).json({ message: "Refresh token expired." });
  }

  const user = tokenRecord.user;
  if (user.status !== UserStatus.ACTIVE) {
    await revokeRefreshFamily(tokenRecord.family);
    clearAuthCookies(response);
    return response.status(403).json({ message: "User account is not active." });
  }

  const authContext =
    tokenRecord.appType === AppType.WEB
      ? user.platformUser
        ? { role: user.platformUser.role as AuthRole }
        : null
      : (() => {
          const membership = user.shopUsers.find(
            (item) => item.shop.status !== "BLOCKED" && item.shop.status !== "SUSPENDED",
          );
          return membership ? { role: membership.role as AuthRole, shopId: membership.shopId } : null;
        })();

  if (!authContext || !isAllowedForAppType(authContext.role, tokenRecord.appType)) {
    await revokeRefreshFamily(tokenRecord.family);
    clearAuthCookies(response);
    return response.status(403).json({ message: "Login access is no longer allowed." });
  }

  await prisma.refreshToken.update({
    where: { id: tokenRecord.id },
    data: { revokedAt: new Date() },
  });

  const rotatedRefreshToken = createRefreshTokenValue();
  await prisma.refreshToken.create({
    data: {
      userId: user.id,
      tokenHash: hashRefreshToken(rotatedRefreshToken),
      family: tokenRecord.family,
      appType: tokenRecord.appType,
      expiresAt: getRefreshTokenExpiryDate(),
    },
  });

  const accessToken = createAccessToken({
    userId: user.id,
    role: authContext.role,
    appType: tokenRecord.appType,
    sessionFamily: tokenRecord.family,
    shopId: "shopId" in authContext ? authContext.shopId : undefined,
  });

  setAccessCookie(response, accessToken);
  setRefreshCookie(response, rotatedRefreshToken);

  return response.json({
    message: "Session refreshed.",
    redirectTo: getDefaultRedirect(authContext.role, tokenRecord.appType),
    role: authContext.role,
    appType: tokenRecord.appType,
  });
});

router.post("/logout", async (request, response) => {
  const refreshToken = parseCookies(request)[REFRESH_TOKEN_COOKIE];

  if (refreshToken) {
    await prisma.refreshToken.updateMany({
      where: {
        tokenHash: hashRefreshToken(refreshToken),
        revokedAt: null,
      },
      data: {
        revokedAt: new Date(),
      },
    });
  }

  clearAuthCookies(response);
  return response.json({ message: "Logged out successfully." });
});

router.get("/me", async (request, response) => {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return sendAuthError(response, auth);
  }

  return response.json({
    user: auth.user,
    session: {
      appType: auth.payload.appType,
      role: auth.payload.role,
      shopId: auth.payload.shopId ?? null,
    },
  });
});

router.patch("/me", async (request, response) => {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return sendAuthError(response, auth);
  }

  const body = request.body as {
    name?: string;
    email?: string | null;
    phone?: string | null;
  };

  const name = body.name?.trim();
  const email = body.email?.trim() || null;
  const phone = body.phone?.trim() || null;

  if (!name) {
    return response.status(400).json({ message: "Name is required." });
  }

  const existingByEmail = email
    ? await prisma.user.findFirst({
        where: {
          email,
          id: { not: auth.user.id },
        },
        select: { id: true },
      })
    : null;

  if (existingByEmail) {
    return response.status(409).json({ message: "Email is already in use." });
  }

  const existingByPhone = phone
    ? await prisma.user.findFirst({
        where: {
          phone,
          id: { not: auth.user.id },
        },
        select: { id: true },
      })
    : null;

  if (existingByPhone) {
    return response.status(409).json({ message: "Phone is already in use." });
  }

  const updatedUser = await prisma.user.update({
    where: { id: auth.user.id },
    data: {
      name,
      email,
      phone,
    },
    select: {
      id: true,
      name: true,
      email: true,
      phone: true,
      profileImageUrl: true,
      status: true,
    },
  });

  return response.json({
    message: "Profile updated successfully.",
    user: updatedUser,
  });
});

router.patch("/me/avatar", async (request, response) => {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return sendAuthError(response, auth);
  }

  const body = request.body as { profileImageUrl?: string };
  const profileImageUrl = body.profileImageUrl?.trim();

  if (!profileImageUrl) {
    return response.status(400).json({ message: "Profile image path is required." });
  }

  const updatedUser = await prisma.user.update({
    where: { id: auth.user.id },
    data: {
      profileImageUrl,
    },
    select: {
      id: true,
      name: true,
      email: true,
      phone: true,
      profileImageUrl: true,
      status: true,
    },
  });

  return response.json({
    message: "Profile image updated successfully.",
    user: updatedUser,
  });
});

export default router;
