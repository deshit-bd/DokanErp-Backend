import crypto from "node:crypto";

import { normalizeText, normalizeWhatsAppNumber } from "@domain/supplier/supplier.entity";
import { SupplierDueOtpAmountRequiredError, SupplierDueOtpMobileRequiredError } from "@domain/supplier/supplier.errors";

import type { SupplierDueOtpStore } from "../ports/supplier-due-otp-store.port";

export class SendSupplierDueOtpUseCase {
  constructor(private readonly otpStore: SupplierDueOtpStore) {}

  execute(
    body: { phone: string; supplierName: string; dueAmount: number; paymentAmount: number; paymentMethod?: string; notes?: string[] },
    baseUrl: string,
  ) {
    const normalizedPhone = normalizeText(body.phone);
    const normalizedName = normalizeText(body.supplierName) || "সরবরাহকারী";
    const normalizedDueAmount = Number(body.dueAmount ?? 0);
    const normalizedPaymentAmount = Number(body.paymentAmount ?? 0);
    const normalizedPaymentMethod = normalizeText(body.paymentMethod) || "CASH";
    const normalizedNotes = Array.isArray(body.notes) ? body.notes.map((item) => normalizeText(item)).filter(Boolean) : [];

    if (!normalizedPhone) {
      throw new SupplierDueOtpMobileRequiredError();
    }

    if (!Number.isFinite(normalizedPaymentAmount) || normalizedPaymentAmount <= 0) {
      throw new SupplierDueOtpAmountRequiredError();
    }

    const code = Math.floor(1000 + Math.random() * 9000).toString();
    const token = crypto.randomBytes(16).toString("hex");

    this.otpStore.set(normalizedPhone, {
      token,
      code,
      expiresAt: Date.now() + 10 * 60 * 1000,
      status: "PENDING",
      supplierName: normalizedName,
      dueAmount: normalizedDueAmount,
      paymentAmount: normalizedPaymentAmount,
      paymentMethod: normalizedPaymentMethod,
      notes: normalizedNotes,
    });

    const confirmationUrl = `${baseUrl}/confirm-supplier-due/${token}`;

    const messageParts = [
      `প্রিয় ${normalizedName},`,
      `Dokan ERP থেকে আপনার বকেয়া পরিশোধের জন্য ৳${normalizedPaymentAmount} টাকা পাঠানো হচ্ছে। নিশ্চিত করতে নিচের লিংকে ক্লিক করুন:`,
      confirmationUrl,
      "",
      `বর্তমান বকেয়া: ৳${normalizedDueAmount}`,
      `পেমেন্ট পদ্ধতি: ${normalizedPaymentMethod}`,
      normalizedNotes.length === 0 ? "" : `বিবরণ:\n${normalizedNotes.map((item) => `• ${item}`).join("\n")}`,
      "",
      "এই লিংক ১০ মিনিট পর্যন্ত কার্যকর থাকবে।",
    ].filter(Boolean);
    const whatsappMessage = messageParts.join("\n");
    const whatsappNumber = normalizeWhatsAppNumber(normalizedPhone);
    const whatsappUrl = whatsappNumber
      ? `https://wa.me/${whatsappNumber}?text=${encodeURIComponent(whatsappMessage)}`
      : `https://wa.me/?text=${encodeURIComponent(whatsappMessage)}`;

    return { whatsappUrl, otp: code };
  }
}
