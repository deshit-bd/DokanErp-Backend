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
  shopId?: string;
};

type ScopedRequest = Parameters<typeof getAuthenticatedUser>[0] & {
  apiClientAppType?: AppType;
};

type RegisterOwnerBody = {
  shopName?: string;
  name?: string;
  mobile?: string;
  email?: string | null;
  password?: string;
  confirmPassword?: string;
};

type RegisterSalesmanBody = {
  shopId?: string;
  name?: string;
  mobile?: string;
  email?: string | null;
  password?: string;
};

function isMobileApiRequest(request: ScopedRequest) {
  return request.apiClientAppType === AppType.MOBILE;
}

function normalizeOptionalText(value?: string | null) {
  const normalized = value?.trim();
  return normalized ? normalized : null;
}

function validatePasswordRules(password: string) {
  return password.trim().length >= 8;
}

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
      ownedShops: true,
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
          ownedShops: true,
        },
      },
    },
  });

  return shop?.owner ?? null;
}

function resolveAuthContext(
  user: Awaited<ReturnType<typeof findUserByIdentity>>,
  appType: AppType,
  requestedShopId?: string,
): { role: AuthRole; shopId?: string } | null {
  if (!user) {
    return null;
  }

  if (appType === AppType.WEB) {
    return user.platformUser ? { role: user.platformUser.role as AuthRole } : null;
  }

  const activeOwnedShops = user.ownedShops.filter(
    (shop) => shop.status !== "BLOCKED" && shop.status !== "SUSPENDED",
  );

  const activeMemberships = user.shopUsers.filter(
    (membership) => membership.shop.status !== "BLOCKED" && membership.shop.status !== "SUSPENDED",
  );

  if (requestedShopId) {
    const ownedShop = activeOwnedShops.find((shop) => shop.id === requestedShopId);

    if (ownedShop) {
      return {
        role: "SHOP_OWNER",
        shopId: ownedShop.id,
      };
    }

    const membership = activeMemberships.find((item) => item.shopId === requestedShopId);

    if (!membership) {
      return null;
    }

    return {
      role: membership.role as AuthRole,
      shopId: membership.shopId,
    };
  }

  if (activeOwnedShops.length > 0) {
    return {
      role: "SHOP_OWNER",
      shopId: activeOwnedShops[0]?.id,
    };
  }

  const activeMembership = activeMemberships[0];

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

router.post("/register-owner", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This registration route is only available for the mobile app." });
    }

    const body = request.body as RegisterOwnerBody;
    const shopName = body.shopName?.trim();
    const name = body.name?.trim();
    const mobile = body.mobile?.trim();
    const email = normalizeOptionalText(body.email);
    const password = body.password ?? "";
    const confirmPassword = body.confirmPassword ?? "";

    if (!shopName) {
      return response.status(400).json({ message: "Shop name is required." });
    }

    if (!name) {
      return response.status(400).json({ message: "Owner name is required." });
    }

    if (!mobile) {
      return response.status(400).json({ message: "Mobile number is required." });
    }

    if (!validatePasswordRules(password)) {
      return response.status(400).json({ message: "Password must be at least 8 characters long." });
    }

    if (password !== confirmPassword) {
      return response.status(400).json({ message: "Confirm password does not match." });
    }

    const [existingUserByPhone, existingUserByEmail, existingShopByName] = await Promise.all([
      prisma.user.findUnique({
        where: { phone: mobile },
        select: { id: true },
      }),
      email
        ? prisma.user.findUnique({
            where: { email },
            select: { id: true },
          })
        : Promise.resolve(null),
      prisma.shop.findFirst({
        where: { shopName },
        select: { id: true },
      }),
    ]);

    if (existingUserByPhone) {
      return response.status(409).json({ message: "Mobile number is already in use." });
    }

    if (existingUserByEmail) {
      return response.status(409).json({ message: "Email is already in use." });
    }

    if (existingShopByName) {
      return response.status(409).json({ message: "Shop name is already in use." });
    }

    const result = await prisma.$transaction(async (transaction) => {
      const user = await transaction.user.create({
        data: {
          name,
          phone: mobile,
          email,
          passwordHash: password,
          status: UserStatus.ACTIVE,
        },
      });

      const shop = await transaction.shop.create({
        data: {
          shopName,
          ownerUserId: user.id,
          phone: mobile,
          email,
          status: "ACTIVE",
        },
      });

      await transaction.shopUser.create({
        data: {
          shopId: shop.id,
          userId: user.id,
          role: "SHOP_OWNER",
          isBillable: true,
        },
      });

      return { user, shop };
    });

    return response.status(201).json({
      message: "Shop owner registered successfully.",
      user: {
        id: result.user.id,
        name: result.user.name,
        mobile: result.user.phone,
        email: result.user.email,
        status: result.user.status,
      },
      shop: {
        id: result.shop.id,
        shopName: result.shop.shopName,
        ownerUserId: result.shop.ownerUserId,
        status: result.shop.status,
      },
    });
  } catch (error) {
    console.error("Register owner route error:", error);

    return response.status(500).json({
      message: "Shop owner registration failed. Please check server setup and try again.",
    });
  }
});

router.post("/register-salesman", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This registration route is only available for the mobile app." });
    }

    const auth = await getAuthenticatedUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    if (auth.payload.appType !== AppType.MOBILE || auth.payload.role !== "SHOP_OWNER") {
      return response.status(403).json({ message: "Only shop owners can add salesmen." });
    }

    const owner = await prisma.user.findUnique({
      where: { id: auth.user.id },
      include: {
        ownedShops: {
          select: { id: true, shopName: true, status: true },
        },
      },
    });

    if (!owner) {
      return response.status(404).json({ message: "Owner account not found." });
    }

    const body = request.body as RegisterSalesmanBody;
    const requestedShopId = body.shopId?.trim() || auth.payload.shopId || "";
    const name = body.name?.trim();
    const mobile = body.mobile?.trim();
    const email = normalizeOptionalText(body.email);
    const password = body.password ?? "";

    if (!requestedShopId) {
      return response.status(400).json({ message: "shopId is required." });
    }

    if (!name) {
      return response.status(400).json({ message: "Salesman name is required." });
    }

    if (!mobile) {
      return response.status(400).json({ message: "Mobile number is required." });
    }

    if (!validatePasswordRules(password)) {
      return response.status(400).json({ message: "Password must be at least 8 characters long." });
    }

    const ownedShop = owner.ownedShops.find(
      (shop) => shop.id === requestedShopId && shop.status !== "BLOCKED" && shop.status !== "SUSPENDED",
    );

    if (!ownedShop) {
      return response.status(403).json({ message: "You can only add salesmen to your own active shop." });
    }

    const [existingUserByPhone, existingUserByEmail] = await Promise.all([
      prisma.user.findUnique({
        where: { phone: mobile },
        select: { id: true },
      }),
      email
        ? prisma.user.findUnique({
            where: { email },
            select: { id: true },
          })
        : Promise.resolve(null),
    ]);

    if (existingUserByPhone) {
      return response.status(409).json({ message: "Mobile number is already in use." });
    }

    if (existingUserByEmail) {
      return response.status(409).json({ message: "Email is already in use." });
    }

    const result = await prisma.$transaction(async (transaction) => {
      const user = await transaction.user.create({
        data: {
          name,
          phone: mobile,
          email,
          passwordHash: password,
          status: UserStatus.ACTIVE,
          createdByUserId: auth.user.id,
        },
      });

      await transaction.shopUser.create({
        data: {
          shopId: ownedShop.id,
          userId: user.id,
          role: "SALESMAN",
          isBillable: true,
        },
      });

      return { user };
    });

    return response.status(201).json({
      message: "Salesman registered successfully.",
      user: {
        id: result.user.id,
        name: result.user.name,
        mobile: result.user.phone,
        email: result.user.email,
        status: result.user.status,
      },
      shop: {
        id: ownedShop.id,
        shopName: ownedShop.shopName,
      },
      role: "SALESMAN",
    });
  } catch (error) {
    console.error("Register salesman route error:", error);

    return response.status(500).json({
      message: "Salesman registration failed. Please check server setup and try again.",
    });
  }
});

router.post("/login", async (request, response) => {
  try {
    const body = request.body as LoginBody;
    const identity = body.identity?.trim();
    const password = body.password?.trim();
    const requestedShopId = body.shopId?.trim();
    const appType = body.appType ?? (request as ScopedRequest).apiClientAppType ?? AppType.WEB;

    if (!identity || !password) {
      return response.status(400).json({ message: "Email/mobile/store ID and password are required." });
    }

    const user = await findUserByIdentity(identity);

    if (!user || user.status !== UserStatus.ACTIVE || !verifyPassword(password, user.passwordHash)) {
      clearAuthCookies(response);
      return response.status(401).json({ message: "Invalid login credentials." });
    }

    const authContext = resolveAuthContext(user, appType, requestedShopId);

    if (!authContext || !isAllowedForAppType(authContext.role, appType)) {
      const appLabel = appType === AppType.WEB ? "web app" : "mobile app";
      return response
        .status(403)
        .json({
          message:
            appType === AppType.MOBILE && requestedShopId
              ? "This mobile account is not allowed for the selected shop."
              : `This account is not allowed to log in to the ${appLabel}.`,
        });
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
          ownedShops: true,
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
      : resolveAuthContext(user, AppType.MOBILE, undefined);

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
