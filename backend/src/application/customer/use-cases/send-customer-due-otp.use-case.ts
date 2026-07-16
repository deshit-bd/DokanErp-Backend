import crypto from "node:crypto";

import { normalizeText, normalizeWhatsAppNumber } from "@domain/customer/customer.entity";
import { DueOtpMobileRequiredError } from "@domain/customer/customer.errors";

import type { CustomerDueOtpStore } from "../ports/customer-due-otp-store.port";

export class SendCustomerDueOtpUseCase {
  constructor(private readonly otpStore: CustomerDueOtpStore) {}

  execute(body: { phone: string; customerName: string; dueAmount: number; products: string[] }, baseUrl: string) {
    const normalizedPhone = normalizeText(body.phone);
    const normalizedName = normalizeText(body.customerName) || "গ্রাহক";
    const normalizedDueAmount = Number(body.dueAmount ?? 0);
    const normalizedProducts = Array.isArray(body.products) ? body.products.map((item) => normalizeText(item)).filter(Boolean) : [];

    if (!normalizedPhone) {
      throw new DueOtpMobileRequiredError();
    }

    const code = Math.floor(1000 + Math.random() * 9000).toString();
    const token = crypto.randomBytes(16).toString("hex");

    this.otpStore.set(normalizedPhone, {
      token,
      code,
      expiresAt: Date.now() + 10 * 60 * 1000,
      status: "PENDING",
      customerName: normalizedName,
      dueAmount: normalizedDueAmount,
      products: normalizedProducts,
    });

    const confirmationUrl = `${baseUrl}/confirm-due/${token}`;

    const messageParts = [
      `প্রিয় ${normalizedName},`,
      `Dokan ERP-তে আপনার ৳${normalizedDueAmount} বকেয়া (Due) অনুমোদনের জন্য নিচের লিংকে ক্লিক করুন:`,
      confirmationUrl,
      "",
      normalizedProducts.length === 0 ? "" : `পণ্যসমূহ:\n${normalizedProducts.map((p) => `• ${p}`).join("\n")}`,
      "",
      "এই লিংক ১০ মিনিট পর্যন্ত কার্যকর থাকবে।",
    ].filter(Boolean);
    const whatsappMessage = messageParts.join("\n");
    const whatsappNumber = normalizeWhatsAppNumber(normalizedPhone);
    const whatsappUrl = whatsappNumber
      ? `https://wa.me/${whatsappNumber}?text=${encodeURIComponent(whatsappMessage)}`
      : `https://wa.me/?text=${encodeURIComponent(whatsappMessage)}`;

    console.log("=========================================");
    console.log(`[DUE CONFIRMATION READY FOR WHATSAPP ${normalizedPhone}]`);
    console.log(whatsappMessage);
    console.log("=========================================");

    return { whatsappUrl, otp: code };
  }
}
