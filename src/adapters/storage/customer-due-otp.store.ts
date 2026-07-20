import type { CustomerDueVerificationRecord } from "@domain/customer/customer.entity";
import type { CustomerDueOtpStore } from "@application/customer/ports/customer-due-otp-store.port";

/**
 * In-memory (process-local) store for the customer WhatsApp due-confirmation
 * flow. Matches the original `routes/customers.ts` module-level `Map` —
 * distinct from the supplier equivalent (different record shape: `products`
 * list rather than `paymentAmount`/`paymentMethod`/`notes`).
 */
export class InMemoryCustomerDueOtpStore implements CustomerDueOtpStore {
  private readonly records = new Map<string, CustomerDueVerificationRecord>();

  set(phone: string, record: CustomerDueVerificationRecord): void {
    this.records.set(phone, record);
  }

  get(phone: string): CustomerDueVerificationRecord | undefined {
    return this.records.get(phone);
  }

  delete(phone: string): void {
    this.records.delete(phone);
  }

  findByToken(token: string): { phone: string; record: CustomerDueVerificationRecord } | null {
    for (const [phone, record] of this.records.entries()) {
      if (record.token === token) {
        return { phone, record };
      }
    }
    return null;
  }
}

export const customerDueOtpStore = new InMemoryCustomerDueOtpStore();
