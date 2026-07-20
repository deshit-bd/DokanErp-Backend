import type { NextFunction, Request, Response } from "express";
import type { ZodType } from "zod";

import { ValidationError } from "@domain/shared/app-error";

type ValidationSchemas = {
  body?: ZodType;
  query?: ZodType;
  params?: ZodType;
};

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      validated?: { body?: unknown; query?: unknown; params?: unknown };
    }
  }
}

export function validate(schemas: ValidationSchemas) {
  return (request: Request, _response: Response, next: NextFunction) => {
    const validated: Request["validated"] = {};

    for (const [key, schema] of Object.entries(schemas) as [keyof ValidationSchemas, ZodType][]) {
      const result = schema.safeParse((request as unknown as Record<string, unknown>)[key]);

      if (!result.success) {
        return next(new ValidationError(result.error.issues[0]?.message ?? "Invalid request."));
      }

      validated[key] = result.data;
    }

    request.validated = validated;
    next();
  };
}
