import type { NextFunction, Request, Response } from "express";

import { ForbiddenError, NotFoundError, UnauthorizedError } from "@domain/shared/app-error";
import type { AuthRole } from "@domain/shared/auth-role";
import type { RequestContext } from "@application/shared/request-context";

// Bridges to the existing (not-yet-migrated) session/JWT resolution in
// src/auth/current-user.ts rather than duplicating cookie/JWT parsing here.
// src/auth/* is the last module scheduled to migrate (see CLAUDE.md) because
// every other module's auth middleware depends on its stable session
// contract; until then, this adapter is the one sanctioned bridge into it.
import { getAuthenticatedUser, isAuthError } from "../../../auth/current-user";

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      context?: RequestContext;
    }
  }
}

export async function authMiddleware(request: Request, _response: Response, next: NextFunction) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    // getAuthenticatedUser returns 401 for missing/expired sessions but 404
    // when the JWT is valid yet its user no longer exists — preserve that
    // distinction instead of collapsing everything to 401.
    return next(
      auth.status === 404 ? new NotFoundError(auth.body.message) : new UnauthorizedError(auth.body.message),
    );
  }

  request.context = {
    userId: auth.user.id,
    userName: auth.user.name,
    role: auth.payload.role as AuthRole,
    appType: auth.payload.appType as RequestContext["appType"],
    shopId: auth.payload.shopId,
  };

  next();
}

export function requireRole(...roles: AuthRole[]) {
  return (request: Request, _response: Response, next: NextFunction) => {
    if (!request.context) {
      return next(new UnauthorizedError());
    }
    if (!roles.includes(request.context.role)) {
      return next(new ForbiddenError());
    }
    next();
  };
}
