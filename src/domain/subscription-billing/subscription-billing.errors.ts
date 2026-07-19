import { ForbiddenError, NotFoundError, ValidationError } from "@domain/shared/app-error";

export class OwnerSubscriptionOnlyError extends ForbiddenError {
  constructor() {
    super("Only shop owners can manage subscriptions.");
  }
}

export class SubscriptionShopScopeError extends ForbiddenError {
  constructor() {
    super("You can only manage the subscription for your own shop.");
  }
}

export class SubscriptionShopIdRequiredError extends ValidationError {
  constructor() {
    super("shopId is required for subscription operations.");
  }
}

export class SubscriptionShopNotFoundError extends NotFoundError {
  constructor(message = "Shop not found for the provided shopId.") {
    super(message);
  }
}

export class InvoiceAlreadyPaidError extends ValidationError {
  constructor() {
    super("Today's subscription invoice is already paid.");
  }
}

export class InvalidPaymentAmountError extends ValidationError {
  constructor() {
    super("Amount must be a valid positive number.");
  }
}

export class PaymentAmountMismatchError extends ValidationError {
  constructor(remainingAmount: number) {
    super(`Subscription payment must be exactly BDT ${remainingAmount}.`);
  }
}
