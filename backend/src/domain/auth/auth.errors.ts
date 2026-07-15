import { ConflictError, ForbiddenError, NotFoundError, UnauthorizedError, ValidationError } from "@domain/shared/app-error";

// Auth has ~60 distinct legacy error messages across 19 use cases. Rather
// than name a class per message (disproportionate here vs. categories/units/
// brands, where each error was reused across multiple call sites), most use
// cases throw the base ValidationError/ConflictError/etc. directly with the
// original message text. Only errors a caller needs to distinguish
// programmatically (none currently) would warrant a dedicated subclass.

export class InvalidCredentialsError extends UnauthorizedError {
  constructor(message = "Invalid login credentials.", details?: Record<string, unknown>) {
    super(message, details);
  }
}

export class AccountNotActiveError extends ForbiddenError {
  constructor(message = "User account is not active.", details?: Record<string, unknown>) {
    super(message, details);
  }
}

export class MobileOnlyRouteError extends NotFoundError {}

export class UserNotFoundError extends NotFoundError {
  constructor() {
    super("User not found.");
  }
}

export { ConflictError, ForbiddenError, NotFoundError, UnauthorizedError, ValidationError };
