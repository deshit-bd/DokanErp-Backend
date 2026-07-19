import { ConflictError, ForbiddenError, NotFoundError, ServiceUnavailableError, ValidationError } from "@domain/shared/app-error";

// --- Pre-transaction validation (clean, deliberate status codes) ---

export class PurchaseShopIdRequiredError extends ValidationError {
  constructor() {
    super("shopId is required for purchase operations.");
  }
}

export class PurchaseShopNotFoundError extends NotFoundError {
  constructor() {
    super("Shop not found for the provided shopId/shopCode.");
  }
}

export class PurchaseItemsRequiredError extends ValidationError {
  constructor() {
    super("At least one purchase item is required.");
  }
}

export class InvalidPurchaseItemError extends ValidationError {
  constructor() {
    super("Each purchase item requires a valid product, quantity, and purchase price.");
  }
}

export class InvalidExpiryDateError extends ValidationError {
  constructor() {
    super("Expiry date must be a valid date.");
  }
}

export class PurchaseProductNotFoundInShopError extends NotFoundError {
  constructor(masterProductId: string) {
    super(`Product not found in shop: ${masterProductId}`);
  }
}

export class InvalidDiscountAmountError extends ValidationError {
  constructor() {
    super("Discount amount must be a valid number.");
  }
}

export class InvalidExtraChargeAmountError extends ValidationError {
  constructor() {
    super("Extra charge amount must be a valid number.");
  }
}

export class InvalidPaidAmountError extends ValidationError {
  constructor() {
    super("Paid amount must be a valid number.");
  }
}

export class PaidAmountExceedsTotalError extends ValidationError {
  constructor() {
    super("Paid amount cannot be greater than total amount.");
  }
}

export class PurchasePaymentValidationError extends ValidationError {}

export class PurchaseProductsDoNotExistError extends ValidationError {
  constructor() {
    super("One or more purchase products do not exist.");
  }
}

export class SupplierNotLinkedToShopError extends NotFoundError {
  constructor() {
    super("Supplier is not linked to this shop. Add the supplier to this store first.");
  }
}

export class MoneyBoxNotFoundForPurchaseError extends ValidationError {
  constructor() {
    super("No active money box found for this purchase method.");
  }
}

export class MoneyBoxNotFoundForPaymentError extends ValidationError {
  constructor() {
    super("No active money box found for this payment method.");
  }
}

export class BankAccountNotFoundError extends ValidationError {
  constructor() {
    super("No active bank account found for this shop.");
  }
}

export class PurchaseNotFoundError extends NotFoundError {
  constructor() {
    super("Purchase not found.");
  }
}

export class PurchaseNotEditableError extends ConflictError {
  constructor() {
    super("Only pending or draft purchases can be updated.");
  }
}

export class InvalidPurchaseDateError extends ValidationError {
  constructor() {
    super("Purchase date must be a valid date.");
  }
}

export class InvalidPaymentAmountRequiredError extends ValidationError {
  constructor() {
    super("A valid payment amount is required.");
  }
}

export class ReturnItemsRequiredError extends ValidationError {
  constructor() {
    super("At least one return item is required.");
  }
}

export class InvalidReturnItemError extends ValidationError {
  constructor() {
    super("Each return item requires a valid purchase item and quantity.");
  }
}

export class OnlyShopOwnersCanApprovePurchasesError extends ForbiddenError {
  constructor() {
    super("Only shop owners can approve purchases.");
  }
}

export class OnlyShopOwnersCanRejectPurchasesError extends ForbiddenError {
  constructor() {
    super("Only shop owners can reject purchases.");
  }
}

export class OnlyPendingPurchasesCanBeRejectedError extends ValidationError {
  constructor() {
    super("Only pending purchases can be rejected.");
  }
}

export class InvalidReceivedProductError extends ValidationError {
  constructor() {
    super("Each received product requires a valid product, physical count, buying price, and selling price.");
  }
}

// --- In-transaction business-rule failures ---
// NOTE: the original code threw plain `Error`s inside `$transaction` callbacks
// for these, and the *outer* catch block for each endpoint funneled them into
// a 503 response using the raw thrown message (not the semantically "correct"
// 400/404/409). That is a real legacy quirk — preserved deliberately here via
// `ServiceUnavailableError` subclasses rather than "fixed" into more sensible
// status codes. See CLAUDE.md's purchases migration notes.

export class RejectedPurchasesCannotBeApprovedError extends ServiceUnavailableError {
  constructor() {
    super("Rejected purchases cannot be approved.");
  }
}

export class RejectedPurchasesCannotBeReceivedError extends ServiceUnavailableError {
  constructor() {
    super("Rejected purchases cannot be received.");
  }
}

export class ApprovedPurchasesCannotBeCancelledError extends ServiceUnavailableError {
  constructor() {
    super("Approved purchases cannot be cancelled.");
  }
}

export class OnlyApprovedPurchasesReceiveDuePaymentsError extends ServiceUnavailableError {
  constructor() {
    super("Only approved purchases can receive due payments.");
  }
}

export class PaymentExceedsRemainingDueError extends ServiceUnavailableError {
  constructor() {
    super("Payment amount cannot be greater than the remaining due.");
  }
}

export class PurchaseHasNoSupplierForPaymentError extends ServiceUnavailableError {
  constructor() {
    super("This purchase has no supplier for due payment.");
  }
}

export class OnlyApprovedPurchasesCanBeReturnedError extends ServiceUnavailableError {
  constructor() {
    super("Only approved purchases can be returned.");
  }
}

export class ReturnItemNotInPurchaseError extends ServiceUnavailableError {
  constructor() {
    super("One or more selected purchase items do not belong to this purchase.");
  }
}

export class ReturnQuantityExceedsAvailableError extends ServiceUnavailableError {
  constructor(productName: string) {
    super(`Return quantity exceeds available quantity for ${productName}.`);
  }
}

export class InvalidPhysicalCountError extends ServiceUnavailableError {
  constructor(productName: string) {
    super(`Invalid physical count for ${productName}.`);
  }
}

export class UnknownReceivedProductError extends ServiceUnavailableError {
  constructor() {
    super("One or more received purchase products do not exist on this order.");
  }
}

export class ReceivePurchasePaymentInfoError extends ServiceUnavailableError {
  constructor(message: string) {
    super(message);
  }
}

// NOTE: the original `/:id/receive` handler's catch block has no special case
// for these two sentinels (unlike `/` and `/:id/payments`, which map them to a
// clean 400) — so the literal internal string leaked as the user-facing
// message at 503. Preserved verbatim, not "fixed" into a friendlier message,
// per this migration's behavior-parity rule.
export class ReceivePurchaseMoneyBoxNotFoundError extends ServiceUnavailableError {
  constructor() {
    super("MONEY_BOX_NOT_FOUND");
  }
}

export class ReceivePurchaseBankAccountNotFoundError extends ServiceUnavailableError {
  constructor() {
    super("BANK_ACCOUNT_NOT_FOUND");
  }
}
