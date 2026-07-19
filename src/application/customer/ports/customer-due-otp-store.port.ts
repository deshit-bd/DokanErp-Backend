import type { CustomerDueVerificationRecord } from "@domain/customer/customer.entity";

export interface CustomerDueOtpStore {
  set(phone: string, record: CustomerDueVerificationRecord): void;
  get(phone: string): CustomerDueVerificationRecord | undefined;
  delete(phone: string): void;
  findByToken(token: string): { phone: string; record: CustomerDueVerificationRecord } | null;
}
