import crypto from "node:crypto";

import { prisma } from "../prisma/client";

const OTP_RENEW_INTERVAL_MS = 30 * 1000;
const OTP_EXPIRES_IN_MS = 2 * 60 * 1000;

function hashValue(value: string) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

function generateOtpCode() {
  return String(Math.floor(1000 + Math.random() * 9000));
}

let renewalJobStarted = false;

async function renewExpiredRegistrationOtps() {
  const now = new Date();

  const drafts = await (prisma as any).ownerRegistrationDraft.findMany({
    where: {
      status: "OTP_SENT",
      completedAt: null,
      otpVerifiedAt: null,
      expiresAt: {
        gt: now,
      },
      otpVerification: {
        is: {
          status: "PENDING",
          expiresAt: {
            lte: now,
          },
        },
      },
    },
    include: {
      otpVerification: true,
    },
  });

  for (const draft of drafts) {
    const currentOtp = draft.otpVerification;

    if (!currentOtp) {
      continue;
    }

    const code = generateOtpCode();
    const renewedOtp = await prisma.$transaction(async (transaction) => {
      const tx = transaction as any;

      await tx.otpVerification.update({
        where: { id: currentOtp.id },
        data: {
          status: "EXPIRED",
        },
      });

      const createdOtp = await tx.otpVerification.create({
        data: {
          appType: "MOBILE",
          purpose: "REGISTRATION",
          channel: "SMS",
          recipient: draft.mobile,
          codeHash: hashValue(code),
          expiresAt: new Date(Date.now() + OTP_EXPIRES_IN_MS),
          status: "PENDING",
        },
        select: {
          id: true,
          expiresAt: true,
        },
      });

      await tx.ownerRegistrationDraft.update({
        where: { id: draft.id },
        data: {
          otpVerificationId: createdOtp.id,
          status: "OTP_SENT",
        },
      });

      return createdOtp;
    });

    console.log(`[auth] OTP auto-renewed for ${draft.mobile} (${draft.id}): ${code}`);
    console.log(`[auth] Renewed OTP expires at ${renewedOtp.expiresAt.toISOString()}`);
  }
}

export function startOtpAutoRenewalJob() {
  if (renewalJobStarted) {
    return;
  }

  renewalJobStarted = true;

  setInterval(() => {
    renewExpiredRegistrationOtps().catch((error) => {
      console.error("OTP auto-renew job failed:", error);
    });
  }, OTP_RENEW_INTERVAL_MS);
}
