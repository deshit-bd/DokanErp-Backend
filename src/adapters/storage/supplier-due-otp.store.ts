import type { SupplierDueVerificationRecord } from "@domain/supplier/supplier.entity";
import type { SupplierDueOtpStore } from "@application/supplier/ports/supplier-due-otp-store.port";

/**
 * In-memory (process-local) store for the WhatsApp-based supplier due
 * confirmation flow. Not persisted to the database — matches the original
 * `routes/suppliers.ts` module-level `Map`. A single shared instance is used
 * by both the `/send-due-otp`/`/verify-due-otp` API endpoints and the
 * top-level `/confirm-supplier-due/:token` HTML handlers.
 */
export class InMemorySupplierDueOtpStore implements SupplierDueOtpStore {
  private readonly records = new Map<string, SupplierDueVerificationRecord>();

  set(phone: string, record: SupplierDueVerificationRecord): void {
    this.records.set(phone, record);
  }

  get(phone: string): SupplierDueVerificationRecord | undefined {
    return this.records.get(phone);
  }

  delete(phone: string): void {
    this.records.delete(phone);
  }

  findByToken(token: string): { phone: string; record: SupplierDueVerificationRecord } | null {
    for (const [phone, record] of this.records.entries()) {
      if (record.token === token) {
        return { phone, record };
      }
    }
    return null;
  }
}

export const supplierDueOtpStore = new InMemorySupplierDueOtpStore();
