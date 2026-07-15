import { createHash } from "node:crypto";

import type { AppType, AuthRole } from "@domain/shared/auth-role";

export const REGISTRATION_DRAFT_TTL_MS = 30 * 60 * 1000;
export const OTP_TTL_MS = 2 * 60 * 1000;
export const POST_OTP_VERIFIED_TTL_MS = 30 * 60 * 1000;

export type AuthContext = { role: AuthRole; shopId?: string };

export type ShopMembership = { id: string; status: string; shopCode?: string | null; shopName?: string | null };
export type ShopUserMembership = { shopId: string; role: string; shop: { status: string; shopCode?: string | null; shopName?: string | null } };

export type UserForAuthContext = {
  platformUser: { role: string } | null;
  ownedShops: ShopMembership[];
  shopUsers: ShopUserMembership[];
};

export function normalizeMobile(value?: string | null): string {
  if (!value) return "";
  const trimmed = value.trim();

  if (trimmed.includes("@")) {
    return trimmed;
  }

  let cleaned = trimmed.replace(/\D/g, "");

  if (cleaned.startsWith("880") && cleaned.length > 10) {
    cleaned = cleaned.slice(3);
  } else if (cleaned.startsWith("88") && cleaned.length > 10) {
    cleaned = cleaned.slice(2);
  }

  if (cleaned.startsWith("0")) {
    cleaned = cleaned.slice(1);
  }

  return cleaned;
}

export function normalizeOptionalText(value?: string | null): string | null {
  const normalized = value?.trim();
  return normalized ? normalized : null;
}

export function normalizeNumberInput(value?: string | number | null): number | null {
  if (value === null || value === undefined || value === "") {
    return null;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

export function validatePasswordRules(password: string): boolean {
  return password.trim().length >= 4;
}

export function validatePinRules(pin: string): boolean {
  return /^\d{4}$/.test(pin.trim());
}

export function hashOtpCode(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

export function generateOtpCode(): string {
  return String(Math.floor(1000 + Math.random() * 9000));
}

export function buildShopCode(shopName: string): string {
  const prefix =
    shopName
      .toUpperCase()
      .replace(/[^A-Z0-9]/g, "")
      .slice(0, 6) || "SHOP";

  return `${prefix}${Date.now().toString().slice(-6)}`;
}

export function getRegistrationDraftExpiryDate(): Date {
  return new Date(Date.now() + REGISTRATION_DRAFT_TTL_MS);
}

export function getOtpExpiryDate(): Date {
  return new Date(Date.now() + OTP_TTL_MS);
}

export function getPostOtpVerifiedExpiryDate(): Date {
  return new Date(Date.now() + POST_OTP_VERIFIED_TTL_MS);
}

export function getOtpExpirySeconds(): number {
  return Math.floor(OTP_TTL_MS / 1000);
}

/** Phone-number variations to search when looking up a user by a mobile-shaped identity (matches historical inconsistent phone storage formats: bare, leading-0, +880, 880). */
export function buildPhoneVariations(identity: string): string[] | null {
  const isPhone = /^\+?\d+$/.test(identity.trim().replace(/[-\s]/g, ""));
  const normalized = normalizeMobile(identity);

  if (!isPhone || !normalized) {
    return null;
  }

  return [normalized, "0" + normalized, "+880" + normalized, "880" + normalized];
}

/** Pure resolution of a user's effective role/shop for a given appType, given already-loaded relations. */
export function resolveAuthContext(
  user: UserForAuthContext | null,
  appType: AppType,
  requestedShopId?: string,
): AuthContext | null {
  if (!user) {
    return null;
  }

  if (appType === "WEB") {
    return user.platformUser ? { role: user.platformUser.role as AuthRole } : null;
  }

  const activeOwnedShops = user.ownedShops.filter((shop) => shop.status !== "BLOCKED" && shop.status !== "SUSPENDED");
  const activeMemberships = user.shopUsers.filter(
    (membership) => membership.shop.status !== "BLOCKED" && membership.shop.status !== "SUSPENDED",
  );

  if (requestedShopId) {
    const ownedShop = activeOwnedShops.find((shop) => shop.id === requestedShopId);

    if (ownedShop) {
      return { role: "SHOP_OWNER", shopId: ownedShop.id };
    }

    const membership = activeMemberships.find((item) => item.shopId === requestedShopId);

    if (!membership) {
      return null;
    }

    return { role: membership.role as AuthRole, shopId: membership.shopId };
  }

  if (activeOwnedShops.length > 0) {
    return { role: "SHOP_OWNER", shopId: activeOwnedShops[0]?.id };
  }

  const activeMembership = activeMemberships[0];

  if (!activeMembership) {
    return null;
  }

  return { role: activeMembership.role as AuthRole, shopId: activeMembership.shopId };
}
