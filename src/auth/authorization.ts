import { MOBILE_ROLES, WEB_ROLES, type AppType, type AuthRole } from "./constants";

export function isAllowedForAppType(role: AuthRole, appType: AppType) {
  return appType === "WEB"
    ? WEB_ROLES.includes(role as (typeof WEB_ROLES)[number])
    : MOBILE_ROLES.includes(role as (typeof MOBILE_ROLES)[number]);
}

export function getDefaultRedirect(role: AuthRole, appType: AppType) {
  if (appType === "WEB") {
    return "/super-admin/dashboard";
  }

  return role === "SHOP_OWNER" ? "/shop/dashboard" : "/shop/dashboard";
}
