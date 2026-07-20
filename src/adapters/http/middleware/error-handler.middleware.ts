import type { NextFunction, Request, Response } from "express";

import { AppError } from "@domain/shared/app-error";

import { clearAuthCookies } from "../../../auth/session";

// Single place errors become HTTP responses. Controllers/use-cases throw
// AppError subclasses; nothing else in adapters/http should call
// response.status(...).json(...) directly for an error case.
export function errorHandlerMiddleware(
  error: unknown,
  _request: Request,
  response: Response,
  _next: NextFunction,
) {
  if (response.headersSent) {
    return;
  }

  if (error instanceof AppError) {
    // A few legacy login/refresh failure paths clear the auth cookies before
    // responding (e.g. invalid credentials, a blocked salesman trial).
    // Use cases signal this via `details.clearAuthCookies` since they can't
    // touch an Express Response themselves.
    if (error.details?.clearAuthCookies) {
      clearAuthCookies(response);
    }
    const { clearAuthCookies: _clear, ...responseDetails } = error.details ?? {};
    return response.status(error.statusCode).json({ message: error.message, ...responseDetails });
  }

  console.error("Unhandled error:", error);
  return response.status(500).json({ message: "Internal server error." });
}
