import { ConflictError, ForbiddenError, NotFoundError, PaymentRequiredError, ValidationError } from "@domain/shared/app-error";

export class ProductAccessForbiddenError extends ForbiddenError {
  constructor() {
    super("You do not have permission to manage products.");
  }
}

export class ProductNameRequiredError extends ValidationError {
  constructor() {
    super("Product name is required.");
  }
}

export class SkuRequiredError extends ValidationError {
  constructor() {
    super("SKU is required.");
  }
}

export class InvalidPriceError extends ValidationError {
  constructor() {
    super("Price must be a valid number.");
  }
}

export class InvalidSuggestedPriceError extends ValidationError {
  constructor() {
    super("Suggested selling price must be a valid number.");
  }
}

export class DuplicateSkuError extends ConflictError {
  constructor() {
    super("SKU already exists.");
  }
}

export class DuplicateBarcodeError extends ConflictError {
  constructor() {
    super("Barcode already exists.");
  }
}

export class ProductNotFoundError extends NotFoundError {
  constructor() {
    super("Product not found.");
  }
}

export class BarcodeNotAssignedError extends NotFoundError {
  constructor() {
    super("Barcode is not assigned for this product.");
  }
}

export class InvalidStockError extends ValidationError {
  constructor() {
    super("Stock must be a valid number.");
  }
}

export class InvalidLowStockLimitError extends ValidationError {
  constructor() {
    super("Low stock limit must be a valid number.");
  }
}

export class DuplicateShopBarcodeError extends ConflictError {
  constructor() {
    super("Barcode already exists in this shop.");
  }
}

export class FreeTierProductLimitError extends PaymentRequiredError {
  constructor(details: Record<string, unknown>) {
    super("Free tier allows up to 50 products per shop.", details);
  }
}

export class ManualStockDeductionDisabledError extends ValidationError {
  constructor() {
    super("Manual stock deduction has been disabled. Use sales, purchase returns, or damage workflows instead.");
  }
}

export class ApprovalRequestNotFoundError extends NotFoundError {
  constructor() {
    super("Approval request not found.");
  }
}

export class InvalidProductStatusError extends ValidationError {
  constructor() {
    super("A valid status is required.");
  }
}
