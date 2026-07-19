import type { NextFunction, Request, Response } from "express";
import type { AppType } from "@prisma/client";

import { NotFoundError } from "@domain/shared/app-error";

type ScopedRequest = Request & { apiClientAppType?: AppType };

// Many auth endpoints (registration, OTP, mobile login variants) only exist
// for the mobile app's API scope (/app/api/*) — mirrors the original route's
// per-handler isMobileApiRequest(request) check, which returned 404 (not 403)
// to avoid revealing the route exists at all to the web scope.
export function requireMobileScope(message: string) {
  return (request: Request, _response: Response, next: NextFunction) => {
    if ((request as ScopedRequest).apiClientAppType !== "MOBILE") {
      return next(new NotFoundError(message));
    }
    next();
  };
}
