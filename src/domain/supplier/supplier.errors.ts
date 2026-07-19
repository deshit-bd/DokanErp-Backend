import { ConflictError, ForbiddenError, NotFoundError, ValidationError } from "@domain/shared/app-error";

export class SupplierAccessForbiddenError extends ForbiddenError {
  constructor() {
    super("You do not have permission to manage suppliers.");
  }
}

export class SupplierFinanceAccessForbiddenError extends ForbiddenError {
  constructor() {
    super("Only shop owners can access supplier app routes.");
  }
}

export class SupplierFinanceShopIdRequiredError extends ValidationError {
  constructor() {
    super("shopId is required for supplier finance operations.");
  }
}

export class SupplierShopNotFoundError extends NotFoundError {
  constructor() {
    super("Shop not found for the provided shopId/shopCode.");
  }
}

export class SupplierNameRequiredError extends ValidationError {
  constructor() {
    super("Supplier name is required.");
  }
}

export class SupplierMobileRequiredError extends ValidationError {
  constructor() {
    super("Supplier mobile number is required.");
  }
}

export class InvalidDueAmountError extends ValidationError {
  constructor() {
    super("dueAmount must be a valid positive number or 0.");
  }
}

export class SupplierAlreadyLinkedToShopError extends ConflictError {
  constructor(details: Record<string, unknown>) {
    super("Supplier already added for this shop.", details);
  }
}

export class SupplierCodeRequiredError extends ValidationError {
  constructor() {
    super("Supplier code is required.");
  }
}

export class DuplicateSupplierCodeError extends ConflictError {
  constructor() {
    super("Supplier code already exists.");
  }
}

export class DuplicateSupplierNameError extends ConflictError {
  constructor() {
    super("Supplier name already exists.");
  }
}

export class SupplierNotFoundError extends NotFoundError {
  constructor() {
    super("Supplier not found.");
  }
}

export class InvalidSupplierStatusError extends ValidationError {
  constructor() {
    super("A valid supplier status is required.");
  }
}

export class SupplierInvalidPaymentAmountError extends ValidationError {
  constructor() {
    super("A valid payment amount is required.");
  }
}

export class SupplierPaymentValidationError extends ValidationError {}

export class SupplierDueOtpMobileRequiredError extends ValidationError {
  constructor() {
    super("Mobile number is required.");
  }
}

export class SupplierDueOtpAmountRequiredError extends ValidationError {
  constructor() {
    super("Payment amount must be greater than 0.");
  }
}

export class SupplierDueOtpPhoneRequiredError extends ValidationError {
  constructor() {
    super("Phone number is required.");
  }
}

export class SupplierDueOtpNotFoundError extends ValidationError {
  constructor() {
    super("Request not found or expired.");
  }
}

export class SupplierDueOtpExpiredError extends ValidationError {
  constructor() {
    super("Request has expired.");
  }
}
