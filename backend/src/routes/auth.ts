import crypto from "node:crypto";
import { AppType, UserStatus } from "@prisma/client";
import { type Response, Router } from "express";

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
import { canAddSalesmanInCurrentTier, ensureShopSubscription, evaluateShopSubscriptionAccess } from "../subscription/access";

const router = Router();
const REGISTRATION_DRAFT_TTL_MS = 30 * 60 * 1000;
const OTP_TTL_MS = 2 * 60 * 1000;
const POST_OTP_VERIFIED_TTL_MS = 30 * 60 * 1000;

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
  pin?: string;
  permissions?: {
    canSell?: boolean;
    canViewStock?: boolean;
    canViewReports?: boolean;
    canChangePrice?: boolean;
    canCollectDue?: boolean;
  };
};

type RegisterOwnerDraftBody = {
  name?: string;
  mobile?: string;
  email?: string | null;
  password?: string;
  confirmPassword?: string;
  shopName?: string;
  shopAddress?: string;
  shopCategory?: string;
  shopLocation?: string | null;
  latitude?: number | string | null;
  longitude?: number | string | null;
};

type SendOtpBody = {
  registrationId?: string;
  mobile?: string;
};

type VerifyOtpBody = {
  registrationId?: string;
  mobile?: string;
  otp?: string;
};

type SetupPinBody = {
  registrationId?: string;
  pin?: string;
  confirmPin?: string;
};

type CompleteRegistrationBody = {
  registrationId?: string;
};

type SendLoginOtpBody = {
  mobile?: string;
};

type VerifyLoginOtpBody = {
  loginRequestId?: string;
  mobile?: string;
  otp?: string;
};

type PreLoginBody = {
  mobile?: string;
  password?: string;
};

type SalesmanLoginBody = {
  mobile?: string;
  password?: string;
  shopId?: string;
};

type ResolvedUser = Exclude<Awaited<ReturnType<typeof findUserByIdentity>>, null>;

type OwnerCredentialVerificationResult =
  | {
      error: {
        status: number;
        body: { message: string };
      };
    }
  | {
      mobile: string;
      user: ResolvedUser;
      authContext: { role: AuthRole; shopId?: string };
    };

type SalesmanCredentialVerificationResult =
  | {
      error: {
        status: number;
        body: { message: string };
      };
    }
  | {
      mobile: string;
      shopId: string;
      user: ResolvedUser;
      authContext: { role: AuthRole; shopId?: string };
    };

function isMobileApiRequest(request: ScopedRequest) {
  return request.apiClientAppType === AppType.MOBILE;
}

function normalizeOptionalText(value?: string | null) {
  const normalized = value?.trim();
  return normalized ? normalized : null;
}

function validatePasswordRules(password: string) {
  return password.trim().length >= 4;
}

function validatePinRules(pin: string) {
  return /^\d{4}$/.test(pin.trim());
}

function normalizeMobile(value?: string | null) {
  return value?.trim() ?? "";
}

function normalizeNumberInput(value?: string | number | null) {
  if (value === null || value === undefined || value === "") {
    return null;
  }

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function hashValue(value: string) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

function generateOtpCode() {
  return String(Math.floor(1000 + Math.random() * 9000));
}

function buildShopCode(shopName: string) {
  const prefix = shopName
    .toUpperCase()
    .replace(/[^A-Z0-9]/g, "")
    .slice(0, 6) || "SHOP";

  return `${prefix}${Date.now().toString().slice(-6)}`;
}

async function createUniqueShopCode(transaction: typeof prisma | any, shopName: string) {
  let shopCode = buildShopCode(shopName);

  for (let attempt = 0; attempt < 5; attempt += 1) {
    const existingShop = await transaction.shop.findUnique({
      where: { shopCode },
      select: { id: true },
    });

    if (!existingShop) {
      return shopCode;
    }

    shopCode = buildShopCode(`${shopName}${attempt}`);
  }

  return `${buildShopCode(shopName)}${Math.floor(Math.random() * 1000)}`;
}

async function getActiveRegistrationDraft(registrationId: string) {
  return (prisma as any).ownerRegistrationDraft.findFirst({
    where: {
      id: registrationId,
      completedAt: null,
      status: {
        notIn: ["CANCELLED", "EXPIRED", "COMPLETED"],
      },
      expiresAt: {
        gt: new Date(),
      },
    },
  });
}

function getRegistrationDraftExpiryDate() {
  return new Date(Date.now() + REGISTRATION_DRAFT_TTL_MS);
}

function getOtpExpiryDate() {
  return new Date(Date.now() + OTP_TTL_MS);
}

function getPostOtpVerifiedExpiryDate() {
  return new Date(Date.now() + POST_OTP_VERIFIED_TTL_MS);
}

function getOtpExpirySeconds() {
  return Math.floor(OTP_TTL_MS / 1000);
}

async function resolveShopIdentifier(shopIdentifier?: string | null) {
  const normalized = shopIdentifier?.trim();

  if (!normalized) {
    return null;
  }

  return (prisma as any).shop.findFirst({
    where: {
      OR: [{ id: normalized }, { shopCode: normalized }],
    },
    select: {
      id: true,
      shopCode: true,
      shopName: true,
      status: true,
    },
  });
}

async function verifyOwnerLoginCredentials(body: PreLoginBody): Promise<OwnerCredentialVerificationResult> {
  const mobile = normalizeMobile(body.mobile);
  const password = body.password?.trim() ?? "";

  if (!mobile || !password) {
    return {
      error: {
        status: 400,
        body: { message: "Mobile number and password are required." },
      },
    };
  }

  const user = await findUserByIdentity(mobile);

  if (!user || user.phone !== mobile || user.status !== UserStatus.ACTIVE || !verifyPassword(password, user.passwordHash)) {
    return {
      error: {
        status: 401,
        body: { message: "Invalid mobile number or password." },
      },
    };
  }

  const authContext = resolveAuthContext(user, AppType.MOBILE);

  if (!authContext || authContext.role !== "SHOP_OWNER") {
    return {
      error: {
        status: 403,
        body: { message: "Only shop owners can use this login flow." },
      },
    };
  }

  return { mobile, user, authContext };
}

async function verifySalesmanLoginCredentials(body: SalesmanLoginBody): Promise<SalesmanCredentialVerificationResult> {
  const mobile = normalizeMobile(body.mobile);
  const password = body.password?.trim() ?? "";
  const shopIdentifier = body.shopId?.trim() ?? "";

  if (!mobile || !password || !shopIdentifier) {
    return {
      error: {
        status: 400,
        body: { message: "Mobile number, password, and shopId are required." },
      },
    };
  }

  const shop = await resolveShopIdentifier(shopIdentifier);

  if (!shop) {
    return {
      error: {
        status: 404,
        body: { message: "Shop not found for the provided shopId/shopCode." },
      },
    };
  }

  const user = await findUserByIdentity(mobile);

  if (!user || user.phone !== mobile || user.status !== UserStatus.ACTIVE || !verifyPassword(password, user.passwordHash)) {
    return {
      error: {
        status: 401,
        body: { message: "Invalid mobile number or password." },
      },
    };
  }

  const authContext = resolveAuthContext(user, AppType.MOBILE, shop.id);

  if (!authContext || authContext.role !== "SALESMAN" || authContext.shopId !== shop.id) {
    return {
      error: {
        status: 403,
        body: { message: "This salesman account is not allowed for the selected shop." },
      },
    };
  }

  return { mobile, shopId: shop.id, user, authContext };
}

async function handleOwnerLoginOtpRequest(request: ScopedRequest, response: Response) {
  const result = await verifyOwnerLoginCredentials(request.body as PreLoginBody);

  if ("error" in result) {
    const { error } = result;
    return response.status(error.status).json(error.body);
  }

  const { mobile, user, authContext } = result;

  await (prisma as any).otpVerification.updateMany({
    where: {
      userId: user.id,
      purpose: "LOGIN",
      status: "PENDING",
    },
    data: {
      status: "CANCELLED",
    },
  });

  const code = generateOtpCode();
  const otp = await (prisma as any).otpVerification.create({
    data: {
      userId: user.id,
      shopId: authContext.shopId ?? null,
      appType: "MOBILE",
      purpose: "LOGIN",
      channel: "SMS",
      recipient: mobile,
      codeHash: hashValue(code),
      expiresAt: getOtpExpiryDate(),
      status: "PENDING",
    },
    select: {
      id: true,
      expiresAt: true,
    },
  });

  console.log(`[auth] Owner login OTP for ${mobile} (${otp.id}): ${code}`);

  return response.json({
    message: "Password verified. OTP sent successfully.",
    loginRequestId: otp.id,
    expiresAt: otp.expiresAt,
    expiresInSeconds: getOtpExpirySeconds(),
    demoOtp: code,
    requiresOtp: true,
  });
}

async function handleSalesmanLoginOtpRequest(request: ScopedRequest, response: Response) {
  const result = await verifySalesmanLoginCredentials(request.body as SalesmanLoginBody);

  if ("error" in result) {
    const { error } = result;
    return response.status(error.status).json(error.body);
  }

  const { mobile, shopId, user, authContext } = result;

  await (prisma as any).otpVerification.updateMany({
    where: {
      userId: user.id,
      shopId,
      purpose: "LOGIN",
      status: "PENDING",
    },
    data: {
      status: "CANCELLED",
    },
  });

  const code = generateOtpCode();
  const otp = await (prisma as any).otpVerification.create({
    data: {
      userId: user.id,
      shopId: authContext.shopId ?? shopId,
      appType: "MOBILE",
      purpose: "LOGIN",
      channel: "SMS",
      recipient: mobile,
      codeHash: hashValue(code),
      expiresAt: getOtpExpiryDate(),
      status: "PENDING",
    },
    select: {
      id: true,
      expiresAt: true,
    },
  });

  console.log(`[auth] Salesman login OTP for ${mobile} (${otp.id}) shop ${shopId}: ${code}`);

  return response.json({
    message: "Password verified. OTP sent successfully.",
    loginRequestId: otp.id,
    expiresAt: otp.expiresAt,
    expiresInSeconds: getOtpExpirySeconds(),
    demoOtp: code,
    requiresOtp: true,
  });
}

async function handleVerifyLoginOtpRequest(request: ScopedRequest, response: Response) {
  const body = request.body as VerifyLoginOtpBody;
  const loginRequestId = body.loginRequestId?.trim() ?? "";
  const mobile = normalizeMobile(body.mobile);
  const otpCode = body.otp?.trim() ?? "";

  if (!loginRequestId || !mobile || !otpCode) {
    return response.status(400).json({ message: "loginRequestId, mobile, and otp are required." });
  }

  const otpRecord = await (prisma as any).otpVerification.findUnique({
    where: { id: loginRequestId },
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

  if (
    !otpRecord ||
    otpRecord.purpose !== "LOGIN" ||
    otpRecord.appType !== "MOBILE" ||
    otpRecord.recipient !== mobile
  ) {
    return response.status(404).json({ message: "Login OTP request not found." });
  }

  if (otpRecord.status !== "PENDING") {
    return response.status(400).json({ message: "No active OTP found for this login request." });
  }

  if (otpRecord.expiresAt <= new Date()) {
    await (prisma as any).otpVerification.update({
      where: { id: otpRecord.id },
      data: { status: "EXPIRED" },
    });

    return response.status(400).json({ message: "OTP has expired." });
  }

  const nextAttempts = Number(otpRecord.attempts ?? 0) + 1;

  if (otpRecord.codeHash !== hashValue(otpCode)) {
    await (prisma as any).otpVerification.update({
      where: { id: otpRecord.id },
      data: {
        attempts: nextAttempts,
        status: nextAttempts >= Number(otpRecord.maxAttempts ?? 5) ? "CANCELLED" : otpRecord.status,
      },
    });

    return response.status(400).json({ message: "Invalid OTP." });
  }

  const user = otpRecord.user;

  if (!user || user.status !== UserStatus.ACTIVE) {
    return response.status(403).json({ message: "User account is not active." });
  }

  const authContext = resolveAuthContext(user, AppType.MOBILE);

  if (!authContext || !isAllowedForAppType(authContext.role, AppType.MOBILE)) {
    return response.status(403).json({ message: "This account is not allowed to log in to the mobile app." });
  }

  const verifiedAt = new Date();
  const refreshToken = createRefreshTokenValue();
  const sessionFamily = createSessionFamily();

  await prisma.$transaction(async (transaction) => {
    const tx = transaction as any;

    await tx.otpVerification.update({
      where: { id: otpRecord.id },
      data: {
        attempts: nextAttempts,
        verifiedAt,
        consumedAt: verifiedAt,
        status: "VERIFIED",
      },
    });

    await tx.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: hashRefreshToken(refreshToken),
        family: sessionFamily,
        appType: "MOBILE",
        expiresAt: getRefreshTokenExpiryDate(),
      },
    });

    await tx.user.update({
      where: { id: user.id },
      data: {
        lastLoginAt: verifiedAt,
        phoneVerifiedAt: user.phoneVerifiedAt ?? verifiedAt,
      },
    });
  });

  const accessToken = createAccessToken({
    userId: user.id,
    role: authContext.role,
    appType: AppType.MOBILE,
    sessionFamily,
    shopId: authContext.shopId,
  });

  setAccessCookie(response, accessToken);
  setRefreshCookie(response, refreshToken);

  return response.json({
    message: "Login successful.",
    authenticated: true,
    redirectTo: getDefaultRedirect(authContext.role, AppType.MOBILE),
    role: authContext.role,
    appType: AppType.MOBILE,
    user: {
      id: user.id,
      name: user.name,
      mobile: user.phone,
    },
    shop: authContext.shopId
      ? {
          id: authContext.shopId,
          shopCode:
            user.ownedShops.find((shop: { id: string; shopCode?: string | null }) => shop.id === authContext.shopId)
              ?.shopCode ??
            user.shopUsers.find(
              (item: { shopId: string; shop: { shopCode?: string | null } }) => item.shopId === authContext.shopId,
            )?.shop.shopCode ??
            null,
        }
      : null,
  });
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
      return response.status(400).json({ message: "Password must be at least 4 characters long." });
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
      const tx = transaction as any;
      const shopCode = await createUniqueShopCode(tx, shopName);
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
          shopCode,
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

      await ensureShopSubscription(shop.id, tx, new Date());

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
        shopCode: (result.shop as { shopCode?: string | null }).shopCode ?? null,
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
    const requestedShopIdentifier = body.shopId?.trim() || auth.payload.shopId || "";
    const name = body.name?.trim();
    const mobile = body.mobile?.trim();
    const email = normalizeOptionalText(body.email);
    const password = body.password ?? "";
    const pin = body.pin?.trim() ?? "";
    const permissions = {
      canSell: body.permissions?.canSell ?? false,
      canViewStock: body.permissions?.canViewStock ?? false,
      canViewReports: body.permissions?.canViewReports ?? false,
      canChangePrice: body.permissions?.canChangePrice ?? false,
      canCollectDue: body.permissions?.canCollectDue ?? false,
    };

    if (!requestedShopIdentifier) {
      return response.status(400).json({ message: "shopId is required." });
    }

    if (!name) {
      return response.status(400).json({ message: "Salesman name is required." });
    }

    if (!mobile) {
      return response.status(400).json({ message: "Mobile number is required." });
    }

    if (!validatePasswordRules(password)) {
      return response.status(400).json({ message: "Password must be at least 4 characters long." });
    }

    if (pin && !validatePinRules(pin)) {
      return response.status(400).json({ message: "PIN must be exactly 4 digits." });
    }

    const requestedShop = await resolveShopIdentifier(requestedShopIdentifier);

    if (!requestedShop) {
      return response.status(404).json({ message: "Shop not found for the provided shopId/shopCode." });
    }

    const ownedShop = owner.ownedShops.find(
      (shop) => shop.id === requestedShop.id && shop.status !== "BLOCKED" && shop.status !== "SUSPENDED",
    );

    if (!ownedShop) {
      return response.status(403).json({ message: "You can only add salesmen to your own active shop." });
    }

    const salesmanAccess = await canAddSalesmanInCurrentTier(ownedShop.id);

    if (!salesmanAccess.allowed) {
      return response.status(salesmanAccess.access?.tier === "BLOCKED" ? 402 : 403).json({
        message: salesmanAccess.message,
        subscription: salesmanAccess.access,
      });
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
      const tx = transaction as any;
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

      const shopUser = await transaction.shopUser.create({
        data: {
          shopId: ownedShop.id,
          userId: user.id,
          role: "SALESMAN",
          isBillable: true,
        },
      });

      await tx.salesmanPermission.create({
        data: {
          shopUserId: shopUser.id,
          canSell: permissions.canSell,
          canViewStock: permissions.canViewStock,
          canViewReports: permissions.canViewReports,
          canChangePrice: permissions.canChangePrice,
          canCollectDue: permissions.canCollectDue,
        },
      });

      if (pin) {
        await tx.userPin.create({
          data: {
            userId: user.id,
            pinHash: hashValue(pin),
            status: "ACTIVE",
          },
        });
      }

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
      permissions,
      pinRequiredFromSettings: !pin,
    });
  } catch (error) {
    console.error("Register salesman route error:", error);

    return response.status(500).json({
      message: "Salesman registration failed. Please check server setup and try again.",
    });
  }
});

router.post("/register-owner-draft", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This registration route is only available for the mobile app." });
    }

    const body = request.body as RegisterOwnerDraftBody;
    const name = body.name?.trim();
    const mobile = normalizeMobile(body.mobile);
    const email = normalizeOptionalText(body.email);
    const password = body.password ?? "";
    const confirmPassword = body.confirmPassword ?? "";
    const shopName = body.shopName?.trim();
    const shopAddress = body.shopAddress?.trim();
    const shopCategory = body.shopCategory?.trim();
    const shopLocation = normalizeOptionalText(body.shopLocation);
    const latitude = normalizeNumberInput(body.latitude);
    const longitude = normalizeNumberInput(body.longitude);

    if (!name) {
      return response.status(400).json({ message: "Owner name is required." });
    }

    if (!mobile) {
      return response.status(400).json({ message: "Mobile number is required." });
    }

    if (!validatePasswordRules(password)) {
      return response.status(400).json({ message: "Password must be at least 4 characters long." });
    }

    if (password !== confirmPassword) {
      return response.status(400).json({ message: "Confirm password does not match." });
    }

    if (!shopName) {
      return response.status(400).json({ message: "Shop name is required." });
    }

    if (!shopAddress) {
      return response.status(400).json({ message: "Shop address is required." });
    }

    if (!shopCategory) {
      return response.status(400).json({ message: "Shop category is required." });
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

    const duplicateDraft = await (prisma as any).ownerRegistrationDraft.findFirst({
      where: {
        OR: [{ mobile }, { shopName }],
        status: {
          notIn: ["CANCELLED", "EXPIRED", "COMPLETED"],
        },
        expiresAt: {
          gt: new Date(),
        },
      },
      select: { id: true, mobile: true, shopName: true },
    });

    if (duplicateDraft) {
      return response.status(409).json({
        message:
          duplicateDraft.mobile === mobile
            ? "A pending registration already exists for this mobile number."
            : "A pending registration already exists for this shop name.",
      });
    }

    const draft = await (prisma as any).ownerRegistrationDraft.create({
      data: {
        name,
        mobile,
        email,
        passwordHash: password,
        shopName,
        shopAddress,
        shopCategory,
        shopLocationLabel: shopLocation,
        latitude,
        longitude,
        status: "PENDING",
        expiresAt: getRegistrationDraftExpiryDate(),
      },
      select: {
        id: true,
        mobile: true,
        shopName: true,
        status: true,
        expiresAt: true,
      },
    });

    return response.status(201).json({
      message: "Registration draft created successfully.",
      registrationId: draft.id,
      draft,
    });
  } catch (error) {
    console.error("Register owner draft route error:", error);

    return response.status(500).json({
      message: "Registration draft could not be created. Please check server setup and try again.",
    });
  }
});

router.post("/send-otp", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This OTP route is only available for the mobile app." });
    }

    const body = request.body as SendOtpBody;
    const registrationId = body.registrationId?.trim() ?? "";
    const mobile = normalizeMobile(body.mobile);

    if (!registrationId || !mobile) {
      return response.status(400).json({ message: "registrationId and mobile are required." });
    }

    const draft = await getActiveRegistrationDraft(registrationId);

    if (!draft || draft.mobile !== mobile) {
      return response.status(404).json({ message: "Registration draft not found." });
    }

    const code = generateOtpCode();
    const otp = await (prisma as any).otpVerification.create({
      data: {
        appType: "MOBILE",
        purpose: "REGISTRATION",
        channel: "SMS",
        recipient: mobile,
        codeHash: hashValue(code),
        expiresAt: getOtpExpiryDate(),
        status: "PENDING",
      },
      select: {
        id: true,
        expiresAt: true,
      },
    });

    await (prisma as any).ownerRegistrationDraft.update({
      where: { id: draft.id },
      data: {
        otpVerificationId: otp.id,
        status: "OTP_SENT",
      },
    });

    console.log(`[auth] OTP for ${mobile} (${draft.id}): ${code}`);

    return response.json({
      message: "OTP sent successfully.",
      registrationId: draft.id,
      expiresAt: otp.expiresAt,
      demoOtp: code,
    });
  } catch (error) {
    console.error("Send OTP route error:", error);

    return response.status(500).json({
      message: "OTP could not be sent. Please check server setup and try again.",
    });
  }
});

router.post("/verify-otp", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This OTP route is only available for the mobile app." });
    }

    const body = request.body as VerifyOtpBody;
    const registrationId = body.registrationId?.trim() ?? "";
    const mobile = normalizeMobile(body.mobile);
    const otpCode = body.otp?.trim() ?? "";

    if (!registrationId || !mobile || !otpCode) {
      return response.status(400).json({ message: "registrationId, mobile, and otp are required." });
    }

    const draft = await (prisma as any).ownerRegistrationDraft.findUnique({
      where: { id: registrationId },
      include: {
        otpVerification: true,
      },
    });

    if (!draft || draft.mobile !== mobile) {
      return response.status(404).json({ message: "Registration draft not found." });
    }

    const otp = draft.otpVerification;

    if (!otp || otp.status !== "PENDING") {
      return response.status(400).json({ message: "No active OTP found for this registration." });
    }

    if (otp.expiresAt <= new Date()) {
      await (prisma as any).otpVerification.update({
        where: { id: otp.id },
        data: { status: "EXPIRED" },
      });

      return response.status(400).json({ message: "OTP has expired." });
    }

    const nextAttempts = Number(otp.attempts ?? 0) + 1;

    if (otp.codeHash !== hashValue(otpCode)) {
      await (prisma as any).otpVerification.update({
        where: { id: otp.id },
        data: {
          attempts: nextAttempts,
          status: nextAttempts >= Number(otp.maxAttempts ?? 5) ? "CANCELLED" : otp.status,
        },
      });

      return response.status(400).json({ message: "Invalid OTP." });
    }

    const verifiedAt = new Date();

    await prisma.$transaction(async (transaction) => {
      await (transaction as any).otpVerification.update({
        where: { id: otp.id },
        data: {
          attempts: nextAttempts,
          verifiedAt,
          consumedAt: verifiedAt,
          status: "VERIFIED",
        },
      });

      await (transaction as any).ownerRegistrationDraft.update({
        where: { id: draft.id },
        data: {
          otpVerifiedAt: verifiedAt,
          status: "OTP_VERIFIED",
          expiresAt: getPostOtpVerifiedExpiryDate(),
        },
      });
    });

    return response.json({
      message: "OTP verified successfully.",
      verified: true,
      registrationId: draft.id,
    });
  } catch (error) {
    console.error("Verify OTP route error:", error);

    return response.status(500).json({
      message: "OTP could not be verified. Please check server setup and try again.",
    });
  }
});

router.post("/setup-pin", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This PIN route is only available for the mobile app." });
    }

    const body = request.body as SetupPinBody;
    const registrationId = body.registrationId?.trim() ?? "";
    const pin = body.pin?.trim() ?? "";
    const confirmPin = body.confirmPin?.trim() ?? "";

    if (!registrationId || !pin || !confirmPin) {
      return response.status(400).json({ message: "registrationId, pin, and confirmPin are required." });
    }

    if (!validatePinRules(pin)) {
      return response.status(400).json({ message: "PIN must be exactly 4 digits." });
    }

    if (pin !== confirmPin) {
      return response.status(400).json({ message: "Confirm PIN does not match." });
    }

    const draft = await getActiveRegistrationDraft(registrationId);

    if (!draft) {
      return response.status(404).json({ message: "Registration draft not found." });
    }

    if (!draft.otpVerifiedAt) {
      return response.status(400).json({ message: "OTP must be verified before setting a PIN." });
    }

    const pinSetAt = new Date();

    await (prisma as any).ownerRegistrationDraft.update({
      where: { id: draft.id },
      data: {
        pinHash: hashValue(pin),
        pinSetAt,
        status: "PIN_SET",
        expiresAt: getPostOtpVerifiedExpiryDate(),
      },
    });

    return response.json({
      message: "PIN set successfully.",
      registrationId: draft.id,
    });
  } catch (error) {
    console.error("Setup PIN route error:", error);

    return response.status(500).json({
      message: "PIN could not be saved. Please check server setup and try again.",
    });
  }
});

router.post("/complete-registration", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This registration route is only available for the mobile app." });
    }

    const body = request.body as CompleteRegistrationBody;
    const registrationId = body.registrationId?.trim() ?? "";

    if (!registrationId) {
      return response.status(400).json({ message: "registrationId is required." });
    }

    const draft = await (prisma as any).ownerRegistrationDraft.findUnique({
      where: { id: registrationId },
      include: {
        otpVerification: true,
      },
    });

    if (!draft) {
      return response.status(404).json({ message: "Registration draft not found." });
    }

    if (!draft.otpVerifiedAt) {
      return response.status(400).json({ message: "OTP must be verified before completing registration." });
    }

    if (!draft.pinHash) {
      return response.status(400).json({ message: "PIN must be set before completing registration." });
    }

    if (draft.completedAt || draft.status === "COMPLETED") {
      return response.status(400).json({ message: "Registration has already been completed." });
    }

    const [existingUserByPhone, existingUserByEmail, existingShopByName] = await Promise.all([
      prisma.user.findUnique({
        where: { phone: draft.mobile },
        select: { id: true },
      }),
      draft.email
        ? prisma.user.findUnique({
            where: { email: draft.email },
            select: { id: true },
          })
        : Promise.resolve(null),
      prisma.shop.findFirst({
        where: { shopName: draft.shopName },
        select: { id: true },
      }),
    ]);

    if (existingUserByPhone || existingUserByEmail || existingShopByName) {
      return response.status(409).json({
        message: "Registration can no longer be completed because the owner or shop already exists.",
      });
    }

    const completedAt = new Date();

    const result = await prisma.$transaction(async (transaction) => {
      const tx = transaction as any;
      const shopCode = await createUniqueShopCode(tx, draft.shopName);

      const user = await tx.user.create({
        data: {
          name: draft.name,
          phone: draft.mobile,
          email: draft.email,
          passwordHash: draft.passwordHash,
          phoneVerifiedAt: draft.otpVerifiedAt,
          status: UserStatus.ACTIVE,
        },
      });

      const shop = await tx.shop.create({
        data: {
          shopCode,
          shopName: draft.shopName,
          ownerUserId: user.id,
          phone: draft.mobile,
          email: draft.email,
          businessType: draft.shopCategory,
          address: draft.shopAddress,
          area: draft.shopLocationLabel,
          status: "ACTIVE",
        },
      });

      await tx.shopUser.create({
        data: {
          shopId: shop.id,
          userId: user.id,
          role: "SHOP_OWNER",
          isBillable: true,
        },
      });

      await ensureShopSubscription(shop.id, tx, completedAt);

      await tx.userPin.create({
        data: {
          userId: user.id,
          pinHash: draft.pinHash,
          status: "ACTIVE",
        },
      });

      await tx.ownerRegistrationDraft.update({
        where: { id: draft.id },
        data: {
          completedAt,
          status: "COMPLETED",
        },
      });

      return { user, shop };
    });

    const refreshToken = createRefreshTokenValue();
    const sessionFamily = createSessionFamily();
    await prisma.refreshToken.create({
      data: {
        userId: result.user.id,
        tokenHash: hashRefreshToken(refreshToken),
        family: sessionFamily,
        appType: AppType.MOBILE,
        expiresAt: getRefreshTokenExpiryDate(),
      },
    });

    const accessToken = createAccessToken({
      userId: result.user.id,
      role: "SHOP_OWNER",
      appType: AppType.MOBILE,
      sessionFamily,
      shopId: result.shop.id,
    });

    setAccessCookie(response, accessToken);
    setRefreshCookie(response, refreshToken);

    return response.status(201).json({
      message: "Registration completed successfully.",
      user: {
        id: result.user.id,
        name: result.user.name,
        mobile: result.user.phone,
        email: result.user.email,
      },
      shop: {
        id: result.shop.id,
        shopCode: (result.shop as { shopCode?: string | null }).shopCode ?? null,
        shopName: result.shop.shopName,
      },
      role: "SHOP_OWNER",
      appType: AppType.MOBILE,
      redirectTo: "/welcome",
    });
  } catch (error) {
    console.error("Complete registration route error:", error);

    return response.status(500).json({
      message: "Registration could not be completed. Please check server setup and try again.",
    });
  }
});

router.post("/pre-login", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This login route is only available for the mobile app." });
    }

    return handleOwnerLoginOtpRequest(scopedRequest, response);
  } catch (error) {
    console.error("Pre-login route error:", error);

    return response.status(500).json({
      message: "Pre-login could not be completed. Please check server setup and try again.",
    });
  }
});

router.post("/owners-login", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This login route is only available for the mobile app." });
    }

    const result = await verifyOwnerLoginCredentials(scopedRequest.body as PreLoginBody);

    if ("error" in result) {
      const { error } = result;
      return response.status(error.status).json(error.body);
    }

    const { mobile, user, authContext } = result;

    return response.json({
      message: "Owner credentials verified successfully.",
      verified: true,
      requiresOtp: true,
      nextStep: "/app/api/auth/owners-login-otp",
      owner: {
        id: user.id,
        name: user.name,
        mobile,
      },
      shop: authContext.shopId
        ? {
            id: authContext.shopId,
            shopCode: user.ownedShops.find((shop) => shop.id === authContext.shopId)?.shopCode ?? null,
          }
        : null,
    });
  } catch (error) {
    console.error("Owners login route error:", error);

    return response.status(500).json({
      message: "Owner login could not be completed. Please check server setup and try again.",
    });
  }
});

router.post("/salesmans-login", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This login route is only available for the mobile app." });
    }

    const result = await verifySalesmanLoginCredentials(scopedRequest.body as SalesmanLoginBody);

    if ("error" in result) {
      const { error } = result;
      return response.status(error.status).json(error.body);
    }

    const { mobile, shopId, user } = result;

    return response.json({
      message: "Salesman credentials verified successfully.",
      verified: true,
      requiresOtp: true,
      nextStep: "/app/api/auth/salesmans-login-otp",
      salesman: {
        id: user.id,
        name: user.name,
        mobile,
      },
      shop: {
        id: shopId,
        shopCode: user.shopUsers.find((item) => item.shopId === shopId)?.shop.shopCode ?? null,
      },
    });
  } catch (error) {
    console.error("Salesmans login route error:", error);

    return response.status(500).json({
      message: "Salesman login could not be completed. Please check server setup and try again.",
    });
  }
});

router.post("/send-owner-login-otp", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This login route is only available for the mobile app." });
    }

    return handleOwnerLoginOtpRequest(scopedRequest, response);
  } catch (error) {
    console.error("Send owner login OTP route error:", error);

    return response.status(500).json({
      message: "Owner login OTP could not be sent. Please check server setup and try again.",
    });
  }
});

router.post("/owners-login-otp", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This login route is only available for the mobile app." });
    }

    return handleOwnerLoginOtpRequest(scopedRequest, response);
  } catch (error) {
    console.error("Owners login OTP route error:", error);

    return response.status(500).json({
      message: "Owner login OTP could not be sent. Please check server setup and try again.",
    });
  }
});

router.post("/salesmans-login-otp", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This login route is only available for the mobile app." });
    }

    return handleSalesmanLoginOtpRequest(scopedRequest, response);
  } catch (error) {
    console.error("Salesmans login OTP route error:", error);

    return response.status(500).json({
      message: "Salesman login OTP could not be sent. Please check server setup and try again.",
    });
  }
});

router.post("/send-login-otp", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This OTP route is only available for the mobile app." });
    }

    const body = request.body as SendLoginOtpBody;
    const mobile = normalizeMobile(body.mobile);

    if (!mobile) {
      return response.status(400).json({ message: "Mobile number is required." });
    }

    const user = await findUserByIdentity(mobile);

    if (!user || user.phone !== mobile || user.status !== UserStatus.ACTIVE) {
      return response.status(404).json({ message: "No active account found for this mobile number." });
    }

    const authContext = resolveAuthContext(user, AppType.MOBILE);

    if (!authContext || !isAllowedForAppType(authContext.role, AppType.MOBILE)) {
      return response.status(403).json({ message: "This account is not allowed to log in to the mobile app." });
    }

    await (prisma as any).otpVerification.updateMany({
      where: {
        userId: user.id,
        purpose: "LOGIN",
        status: "PENDING",
      },
      data: {
        status: "CANCELLED",
      },
    });

    const code = generateOtpCode();
    const otp = await (prisma as any).otpVerification.create({
      data: {
        userId: user.id,
        shopId: authContext.shopId ?? null,
        appType: "MOBILE",
        purpose: "LOGIN",
        channel: "SMS",
        recipient: mobile,
        codeHash: hashValue(code),
        expiresAt: getOtpExpiryDate(),
        status: "PENDING",
      },
      select: {
        id: true,
        expiresAt: true,
      },
    });

    console.log(`[auth] Login OTP for ${mobile} (${otp.id}): ${code}`);

    return response.json({
      message: "OTP sent successfully.",
      loginRequestId: otp.id,
      expiresAt: otp.expiresAt,
      expiresInSeconds: getOtpExpirySeconds(),
      demoOtp: code,
    });
  } catch (error) {
    console.error("Send login OTP route error:", error);

    return response.status(500).json({
      message: "Login OTP could not be sent. Please check server setup and try again.",
    });
  }
});

router.post("/verify-login-otp", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This OTP route is only available for the mobile app." });
    }
    return handleVerifyLoginOtpRequest(scopedRequest, response);
  } catch (error) {
    console.error("Verify login OTP route error:", error);

    return response.status(500).json({
      message: "Login OTP could not be verified. Please check server setup and try again.",
    });
  }
});

router.post("/owners-verify-otp", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This OTP route is only available for the mobile app." });
    }

    return handleVerifyLoginOtpRequest(scopedRequest, response);
  } catch (error) {
    console.error("Owners verify OTP route error:", error);

    return response.status(500).json({
      message: "Owner OTP could not be verified. Please check server setup and try again.",
    });
  }
});

router.post("/salesmans-verify-otp", async (request, response) => {
  try {
    const scopedRequest = request as ScopedRequest;

    if (!isMobileApiRequest(scopedRequest)) {
      return response.status(404).json({ message: "This OTP route is only available for the mobile app." });
    }

    return handleVerifyLoginOtpRequest(scopedRequest, response);
  } catch (error) {
    console.error("Salesmans verify OTP route error:", error);

    return response.status(500).json({
      message: "Salesman OTP could not be verified. Please check server setup and try again.",
    });
  }
});

router.post("/login", async (request, response) => {
  try {
    const body = request.body as LoginBody;
    const identity = body.identity?.trim();
    const password = body.password?.trim();
    const requestedShopIdentifier = body.shopId?.trim();
    const appType = body.appType ?? (request as ScopedRequest).apiClientAppType ?? AppType.WEB;

    const requestedShop = requestedShopIdentifier ? await resolveShopIdentifier(requestedShopIdentifier) : null;
    const requestedShopId = requestedShop?.id;

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

    if (appType === AppType.MOBILE && authContext.shopId) {
      const subscriptionAccess = await evaluateShopSubscriptionAccess(authContext.shopId);

      if (!subscriptionAccess.allowed) {
        clearAuthCookies(response);
        return response.status(402).json({
          message: subscriptionAccess.message,
          subscription: subscriptionAccess,
        });
      }
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

  if (tokenRecord.appType === AppType.MOBILE && "shopId" in authContext && authContext.shopId) {
    const subscriptionAccess = await evaluateShopSubscriptionAccess(authContext.shopId);

    if (!subscriptionAccess.allowed) {
      await revokeRefreshFamily(tokenRecord.family);
      clearAuthCookies(response);
      return response.status(402).json({
        message: subscriptionAccess.message,
        subscription: subscriptionAccess,
      });
    }
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
