import { normalizeText } from "@domain/customer/customer.entity";
import { DueOtpPhoneRequiredError, DueOtpRequestExpiredError, DueOtpRequestNotFoundError } from "@domain/customer/customer.errors";

import type { CustomerDueOtpStore } from "../ports/customer-due-otp-store.port";

export class VerifyCustomerDueOtpUseCase {
  constructor(private readonly otpStore: CustomerDueOtpStore) {}

  execute(body: { phone: string; otp?: string }) {
    if (!body.phone) {
      throw new DueOtpPhoneRequiredError();
    }

    const normalizedPhone = normalizeText(body.phone);
    const record = this.otpStore.get(normalizedPhone);

    if (!record) {
      throw new DueOtpRequestNotFoundError();
    }

    if (Date.now() > record.expiresAt) {
      this.otpStore.delete(normalizedPhone);
      throw new DueOtpRequestExpiredError();
    }

    const isWebConfirmed = record.status === "CONFIRMED";
    const isOtpCorrect = Boolean(body.otp && body.otp.trim() !== "" && record.code === body.otp.trim());

    if (!isWebConfirmed && !isOtpCorrect) {
      return { verified: false, message: "গ্রাহক এখনও বকেয়া পেমেন্ট নিশ্চিত করেননি।" };
    }

    this.otpStore.delete(normalizedPhone);

    return { verified: true, message: "Confirmed successfully." };
  }
}
