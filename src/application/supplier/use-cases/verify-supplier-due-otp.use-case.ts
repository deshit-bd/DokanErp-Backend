import { normalizeText } from "@domain/supplier/supplier.entity";
import { SupplierDueOtpExpiredError, SupplierDueOtpNotFoundError, SupplierDueOtpPhoneRequiredError } from "@domain/supplier/supplier.errors";

import type { SupplierDueOtpStore } from "../ports/supplier-due-otp-store.port";

export class VerifySupplierDueOtpUseCase {
  constructor(private readonly otpStore: SupplierDueOtpStore) {}

  execute(body: { phone: string; otp?: string }) {
    if (!body.phone) {
      throw new SupplierDueOtpPhoneRequiredError();
    }

    const normalizedPhone = normalizeText(body.phone);
    const record = this.otpStore.get(normalizedPhone);

    if (!record) {
      throw new SupplierDueOtpNotFoundError();
    }

    if (Date.now() > record.expiresAt) {
      this.otpStore.delete(normalizedPhone);
      throw new SupplierDueOtpExpiredError();
    }

    const isWebConfirmed = record.status === "CONFIRMED";
    const isOtpCorrect = Boolean(body.otp && body.otp.trim() !== "" && record.code === body.otp.trim());

    if (!isWebConfirmed && !isOtpCorrect) {
      return { verified: false, message: "সরবরাহকারী এখনও পেমেন্ট নিশ্চিত করেননি।" };
    }

    this.otpStore.delete(normalizedPhone);

    return { verified: true, message: "Confirmed successfully." };
  }
}
