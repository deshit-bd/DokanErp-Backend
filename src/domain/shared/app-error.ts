export abstract class AppError extends Error {
  abstract readonly statusCode: number;
  /** Extra fields merged into the JSON error response alongside `message` (e.g. `subscription`, `salesmanTrial` payloads some legacy endpoints attach). */
  details?: Record<string, unknown>;

  constructor(message: string, details?: Record<string, unknown>) {
    super(message);
    this.name = this.constructor.name;
    this.details = details;
  }
}

export class ValidationError extends AppError {
  readonly statusCode = 400;
}

export class UnauthorizedError extends AppError {
  readonly statusCode = 401;

  constructor(message = "Not authenticated.", details?: Record<string, unknown>) {
    super(message, details);
  }
}

export class PaymentRequiredError extends AppError {
  readonly statusCode = 402;
}

export class ForbiddenError extends AppError {
  readonly statusCode = 403;

  constructor(message = "You do not have permission to perform this action.", details?: Record<string, unknown>) {
    super(message, details);
  }
}

export class NotFoundError extends AppError {
  readonly statusCode = 404;

  constructor(message = "Resource not found.", details?: Record<string, unknown>) {
    super(message, details);
  }
}

export class ConflictError extends AppError {
  readonly statusCode = 409;
}

export class ServiceUnavailableError extends AppError {
  readonly statusCode = 503;
}

// For preserving a legacy endpoint's specific "Failed to X." 500 message when
// wrapping an unexpected (non-AppError) failure. Prefer a more specific
// AppError subclass for anything that isn't just bridging old fallback text.
export class InternalError extends AppError {
  readonly statusCode = 500;
}
