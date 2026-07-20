import type { SupplierDueVerificationRecord } from "@domain/supplier/supplier.entity";

export interface SupplierDueOtpStore {
  set(phone: string, record: SupplierDueVerificationRecord): void;
  get(phone: string): SupplierDueVerificationRecord | undefined;
  delete(phone: string): void;
  findByToken(token: string): { phone: string; record: SupplierDueVerificationRecord } | null;
}
