// Deliberately re-declared here rather than imported from src/auth/constants.ts:
// domain/ must never depend on src/auth (a pre-migration module). These unions
// must stay in sync with src/auth/constants.ts's AppType/AuthRole until auth.ts
// itself migrates (last module in the sequence — see CLAUDE.md), at which point
// this becomes the single source of truth and src/auth/constants.ts is deleted.
export const WEB_ROLES = ["SUPER_ADMIN", "ADMIN"] as const;
export const MOBILE_ROLES = ["SHOP_OWNER", "SALESMAN"] as const;

export type AppType = "WEB" | "MOBILE";
export type PlatformRole = (typeof WEB_ROLES)[number];
export type MobileRole = (typeof MOBILE_ROLES)[number];
export type AuthRole = PlatformRole | MobileRole;
