import { AppError, ForbiddenError, NotFoundError, ValidationError } from "@domain/shared/app-error";

// Matches the original route's unusual (but preserved-as-is) 451 status for
// "no shop associated with this session" on the salesman-performance
// endpoint specifically — every other staff endpoint uses 403/404 for
// similar cases.
export class ShopIdNotAssociatedError extends AppError {
  readonly statusCode = 451;
  constructor() {
    super("Shop ID not associated with user.");
  }
}

export class StaffMemberNotFoundError extends NotFoundError {
  constructor(message = "Staff account not found in this shop.") {
    super(message);
  }
}

export class OwnerOnlyStaffError extends ForbiddenError {
  constructor(message = "Only shop owners can manage staff accounts.") {
    super(message);
  }
}

export { ValidationError };
