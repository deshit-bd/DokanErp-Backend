import { ConflictError, ForbiddenError, NotFoundError, ValidationError } from "@domain/shared/app-error";

export class CustomerAccessForbiddenError extends ForbiddenError {
  constructor() {
    super("You do not have permission to manage customers.");
  }
}

export class CustomerFinanceShopIdRequiredError extends ValidationError {
  constructor() {
    super("shopId is required for customer finance operations.");
  }
}

export class CustomerFinanceScopeForbiddenError extends ForbiddenError {
  constructor() {
    super("You can only access customer finance for your own shop.");
  }
}

export class CustomerShopNotFoundError extends NotFoundError {
  constructor() {
    super("Shop not found for the provided shopId/shopCode.");
  }
}

export class CustomerNameRequiredError extends ValidationError {
  constructor() {
    super("Customer name is required.");
  }
}

export class CustomerAlreadyLinkedToShopError extends ConflictError {
  constructor(details: Record<string, unknown>) {
    super("Customer already added for this shop.", details);
  }
}

export class CustomerNotFoundError extends NotFoundError {
  constructor() {
    super("Customer not found.");
  }
}

export class CustomerNotFoundForShopError extends NotFoundError {
  constructor() {
    super("Customer not found for this shop.");
  }
}

export class CustomerCouldNotBeResolvedError extends NotFoundError {
  constructor() {
    super("Customer could not be resolved or linked to this shop.");
  }
}

export class SaleNotFoundError extends NotFoundError {
  constructor() {
    super("Sale not found.");
  }
}

export class SaleAlreadyCancelledError extends ValidationError {
  constructor() {
    super("This sale is already cancelled.");
  }
}

export class CancellationReasonRequiredError extends ValidationError {
  constructor() {
    super("Cancellation reason is required.");
  }
}

export class SaleItemsRequiredError extends ValidationError {
  constructor() {
    super("At least one sale item is required.");
  }
}

export class InvalidSaleItemError extends ValidationError {
  constructor() {
    super("Each sale item requires a valid product, quantity, and sale price.");
  }
}

export class InvalidPaidAmountError extends ValidationError {
  constructor() {
    super("Paid amount must be a valid number.");
  }
}

export class InvalidStoreCreditUsedError extends ValidationError {
  constructor() {
    super("storeCreditUsed must be a valid number.");
  }
}

export class InvalidDiscountAmountError extends ValidationError {
  constructor() {
    super("discountAmount must be a valid number.");
  }
}

export class InvalidTaxAmountError extends ValidationError {
  constructor() {
    super("taxAmount must be a valid number.");
  }
}

export class InvalidChargeAmountError extends ValidationError {
  constructor() {
    super("chargeAmount must be a valid number.");
  }
}

export class CustomerPaymentValidationError extends ValidationError {}

export class SaleProductsDoNotExistError extends ValidationError {
  constructor() {
    super("One or more sale products do not exist.");
  }
}

export class MoneyBoxNotFoundForShopError extends NotFoundError {
  constructor() {
    super("Money box not found for this shop.");
  }
}

export class StoreCreditExceedsAvailableError extends ValidationError {
  constructor() {
    super("Requested store credit is greater than available customer credit.");
  }
}

// NOTE: these reproduce the original's error-message-prefix sniffing in the
// checkout transaction's catch block (`error.message.startsWith(...)`) — the
// original mapped these specific conditions to 400 while anything else fell
// through to 503. Using dedicated ValidationError subclasses preserves the
// 400 status without needing string-prefix matching in the controller.
export class ProductNotFoundInShopInventoryError extends ValidationError {
  constructor(masterProductId: string) {
    super(`Product not found in shop inventory: ${masterProductId}`);
  }
}

export class InsufficientStockError extends ValidationError {
  constructor(available: number, requested: number) {
    super(`Insufficient stock for product. Available: ${available}, Requested: ${requested}`);
  }
}

export class InsufficientBatchStockError extends ValidationError {
  constructor(requested: number, allocated: number) {
    super(`Insufficient batch stock for product. Requested: ${requested}, Allocated: ${allocated}`);
  }
}

export class PaidPlusStoreCreditExceedsTotalError extends ValidationError {
  constructor() {
    super("Paid amount plus store credit cannot be greater than total sale amount.");
  }
}

export class CustomerPaymentAmountInvalidError extends ValidationError {
  constructor() {
    super("Amount must be a valid positive number.");
  }
}

export class NoOutstandingDueError extends ValidationError {
  constructor() {
    super("This customer has no outstanding due in the selected shop.");
  }
}

export class PaymentExceedsOutstandingDueError extends ValidationError {
  constructor() {
    super("Payment amount cannot be greater than the outstanding due.");
  }
}

export class DueOtpMobileRequiredError extends ValidationError {
  constructor() {
    super("Mobile number is required.");
  }
}

export class DueOtpPhoneRequiredError extends ValidationError {
  constructor() {
    super("Phone number is required.");
  }
}

export class DueOtpRequestNotFoundError extends ValidationError {
  constructor() {
    super("Request not found or expired.");
  }
}

export class DueOtpRequestExpiredError extends ValidationError {
  constructor() {
    super("Request has expired.");
  }
}
