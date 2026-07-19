import type { AppType, AuthRole } from "@domain/shared/auth-role";

export type RequestContext = {
  userId: string;
  userName: string;
  role: AuthRole;
  appType: AppType;
  shopId?: string;
};
