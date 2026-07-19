export const ACCESS_TOKEN_COOKIE = "mudi_access_token";
export const REFRESH_TOKEN_COOKIE = "mudi_refresh_token";

export const ACCESS_TOKEN_TTL_SECONDS = 60 * 15;
export const REFRESH_TOKEN_TTL_SECONDS = 60 * 60 * 24 * 7;

export const WEB_ROLES = ["SUPER_ADMIN", "ADMIN"] as const;
export const MOBILE_ROLES = ["SHOP_OWNER", "SALESMAN"] as const;

export type AppType = "WEB" | "MOBILE";
export type PlatformRole = (typeof WEB_ROLES)[number];
export type MobileRole = (typeof MOBILE_ROLES)[number];
export type AuthRole = PlatformRole | MobileRole;
