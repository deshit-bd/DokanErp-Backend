import type { NextFunction, Request, Response } from "express";

// Express 4 does not forward rejected promises from an async handler to
// next(err) automatically. Every controller method must be wrapped with this
// so a thrown AppError reaches error-handler.middleware.ts instead of becoming
// an unhandled rejection.
export function asyncHandler(handler: (request: Request, response: Response) => Promise<void>) {
  return (request: Request, response: Response, next: NextFunction) => {
    handler(request, response).catch(next);
  };
}
