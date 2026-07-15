import type { Request, Response } from "express";

import { AppError, NotFoundError, ServiceUnavailableError, UnauthorizedError } from "@domain/shared/app-error";
import {
  SupplierAccessForbiddenError,
  SupplierFinanceAccessForbiddenError,
  SupplierFinanceShopIdRequiredError,
  SupplierNameRequiredError,
  SupplierShopNotFoundError,
} from "@domain/supplier/supplier.errors";
import { CreateSupplierPaymentUseCase } from "@application/supplier/use-cases/create-supplier-payment.use-case";
import { CreateSupplierUseCase } from "@application/supplier/use-cases/create-supplier.use-case";
import { DeleteSupplierUseCase } from "@application/supplier/use-cases/delete-supplier.use-case";
import { GetSupplierDuesUseCase } from "@application/supplier/use-cases/get-supplier-dues.use-case";
import { GetSupplierLedgerUseCase } from "@application/supplier/use-cases/get-supplier-ledger.use-case";
import { GetSupplierUseCase } from "@application/supplier/use-cases/get-supplier.use-case";
import { ListSupplierPaymentsUseCase } from "@application/supplier/use-cases/list-supplier-payments.use-case";
import { ListSupplierPurchasesUseCase } from "@application/supplier/use-cases/list-supplier-purchases.use-case";
import { ListSuppliersUseCase } from "@application/supplier/use-cases/list-suppliers.use-case";
import { SendSupplierDueOtpUseCase } from "@application/supplier/use-cases/send-supplier-due-otp.use-case";
import { UpdateSupplierStatusUseCase } from "@application/supplier/use-cases/update-supplier-status.use-case";
import { UpdateSupplierUseCase } from "@application/supplier/use-cases/update-supplier.use-case";
import { VerifySupplierDueOtpUseCase } from "@application/supplier/use-cases/verify-supplier-due-otp.use-case";
import type { ShopScope, SupplierRepository } from "@application/supplier/ports/supplier-repository.port";

import { getAuthenticatedUser, isAuthError } from "../../../auth/current-user";
import { PrismaSupplierRepository } from "../../persistence/prisma/supplier.repository";
import { supplierDueOtpStore } from "../../storage/supplier-due-otp.store";

const supplierRepository: SupplierRepository = new PrismaSupplierRepository();

const listSuppliersUseCase = new ListSuppliersUseCase(supplierRepository);
const createSupplierUseCase = new CreateSupplierUseCase(supplierRepository);
const getSupplierUseCase = new GetSupplierUseCase(supplierRepository);
const updateSupplierUseCase = new UpdateSupplierUseCase(supplierRepository);
const deleteSupplierUseCase = new DeleteSupplierUseCase(supplierRepository);
const updateSupplierStatusUseCase = new UpdateSupplierStatusUseCase(supplierRepository);
const getSupplierDuesUseCase = new GetSupplierDuesUseCase(supplierRepository);
const getSupplierLedgerUseCase = new GetSupplierLedgerUseCase(supplierRepository);
const createSupplierPaymentUseCase = new CreateSupplierPaymentUseCase(supplierRepository);
const listSupplierPaymentsUseCase = new ListSupplierPaymentsUseCase(supplierRepository);
const listSupplierPurchasesUseCase = new ListSupplierPurchasesUseCase(supplierRepository);
const sendSupplierDueOtpUseCase = new SendSupplierDueOtpUseCase(supplierDueOtpStore);
const verifySupplierDueOtpUseCase = new VerifySupplierDueOtpUseCase(supplierDueOtpStore);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

/**
 * This module bridges directly to the legacy `auth/current-user.ts` session
 * resolution (like `auth.middleware.ts` itself does) rather than using
 * `authMiddleware`/`request.context`, because its endpoints have
 * heterogeneous, sometimes-conditional auth requirements that don't fit the
 * uniform "always authenticate up front" shape: `GET /`, `POST /`, and
 * `GET /:id` only require auth when no explicit `shopId` is supplied (see
 * `resolveRequestedShopIdentifier`), and `/send-due-otp` / `/verify-due-otp`
 * require **no authentication at all** in the original (a real, preserved
 * gap — see CLAUDE.md's suppliers migration notes). Applying `authMiddleware`
 * router-wide would silently add an auth requirement that never existed.
 */
function throwIfAuthError(auth: unknown): asserts auth is Exclude<Awaited<ReturnType<typeof getAuthenticatedUser>>, { status: number; body: any }> {
  if (isAuthError(auth as any)) {
    const authError = auth as { status: number; body: { message: string } };
    throw authError.status === 404 ? new NotFoundError(authError.body.message) : new UnauthorizedError(authError.body.message);
  }
}

async function requirePlatformUser(request: Request) {
  const auth = await getAuthenticatedUser(request);
  throwIfAuthError(auth);

  if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
    throw new SupplierAccessForbiddenError();
  }

  return auth;
}

async function requireFinanceContext(request: Request) {
  const auth = await getAuthenticatedUser(request);
  throwIfAuthError(auth);

  if (auth.payload.role !== "SHOP_OWNER") {
    throw new SupplierFinanceAccessForbiddenError();
  }

  const rawShopId =
    auth.payload.shopId ??
    (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") ??
    ((request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "");

  if (!rawShopId) {
    throw new SupplierFinanceShopIdRequiredError();
  }

  return { auth, shopId: rawShopId };
}

async function resolveFinanceShop(request: Request): Promise<ShopScope> {
  const { shopId } = await requireFinanceContext(request);
  const shop = await supplierRepository.resolveShopIdentifier(shopId);

  if (!shop) {
    throw new SupplierShopNotFoundError();
  }

  return shop;
}

async function resolveRequestedShopIdentifier(request: Request): Promise<string> {
  const explicit =
    (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") ||
    ((request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "");

  if (explicit) {
    return explicit;
  }

  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return "";
  }

  if (auth.payload.appType === "MOBILE" && auth.payload.shopId) {
    return auth.payload.shopId;
  }

  return "";
}

function requestBaseUrl(request: Request): string {
  const envBaseUrl = process.env.BASE_URL;
  if (envBaseUrl && envBaseUrl.trim() !== "") {
    return envBaseUrl.trim().replace(/\/$/, "");
  }
  return `${request.protocol}://${request.get("host")}`;
}

export const supplierController = {
  async list(request: Request, response: Response) {
    try {
      const requestedShopIdentifier = await resolveRequestedShopIdentifier(request);

      if (requestedShopIdentifier) {
        const shop = await resolveFinanceShop(request);
        const result = await listSuppliersUseCase.executeFinance(shop, request.query);
        response.json({
          shop: { id: shop.id, shopCode: shop.shopCode, shopName: shop.shopName, phone: shop.phone, address: shop.address, area: shop.area, district: shop.district, status: shop.status },
          stats: result.stats,
          suppliers: result.suppliers,
        });
        return;
      }

      await requirePlatformUser(request);
      const result = await listSuppliersUseCase.executePlatform(request.query);
      response.json(result);
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Suppliers are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async create(request: Request, response: Response) {
    try {
      // NOTE: the original checks "Supplier name is required." before any
      // auth/shop resolution — an unauthenticated request with a missing
      // name gets 400 before a 401/403. Preserved by validating here first.
      const body = request.body as { name?: string; companyOrPersonName?: string };
      const name = body.name?.trim() || body.companyOrPersonName?.trim();
      if (!name) {
        throw new SupplierNameRequiredError();
      }

      const requestedShopIdentifier = await resolveRequestedShopIdentifier(request);

      if (requestedShopIdentifier) {
        const shop = await resolveFinanceShop(request);
        const result = await createSupplierUseCase.executeFinance(shop, request.body);
        response.status(result.linkedExisting ? 200 : 201).json({
          message: result.linkedExisting ? "Existing global supplier linked to this shop successfully." : "Supplier created successfully.",
          shop: result.shop,
          supplier: result.supplier,
          openingDue: result.openingDue,
          sendWhatsAppInvite: result.sendWhatsAppInvite,
        });
        return;
      }

      await requirePlatformUser(request);
      const supplier = await createSupplierUseCase.executePlatform(request.body);
      response.status(201).json({ message: "Supplier created successfully.", supplier });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Supplier could not be created because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async getOne(request: Request, response: Response) {
    try {
      const requestedShopIdentifier = await resolveRequestedShopIdentifier(request);

      if (requestedShopIdentifier) {
        const shop = await resolveFinanceShop(request);
        const result = await getSupplierUseCase.executeFinance(shop, String(request.params.id));
        response.json({ shop: { id: shop.id, shopCode: shop.shopCode, shopName: shop.shopName }, supplier: result.supplier });
        return;
      }

      await requirePlatformUser(request);
      const result = await getSupplierUseCase.executePlatform(String(request.params.id));
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Supplier could not be loaded right now."));
    }
  },

  async update(request: Request, response: Response) {
    try {
      await requirePlatformUser(request);
      const supplier = await updateSupplierUseCase.execute(String(request.params.id), request.body);
      response.json({ message: "Supplier updated successfully.", supplier });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Supplier could not be updated right now."));
    }
  },

  async remove(request: Request, response: Response) {
    try {
      await requirePlatformUser(request);
      await deleteSupplierUseCase.execute(String(request.params.id));
      response.json({ message: "Supplier deleted successfully." });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Supplier could not be deleted right now."));
    }
  },

  async updateStatus(request: Request, response: Response) {
    try {
      await requirePlatformUser(request);
      const status = (request.body as { status?: string } | undefined)?.status;
      const supplier = await updateSupplierStatusUseCase.execute(String(request.params.id), status);
      response.json({ message: "Supplier status updated successfully.", supplier });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Supplier status could not be updated right now."));
    }
  },

  async getDues(request: Request, response: Response) {
    try {
      const shop = await resolveFinanceShop(request);
      const result = await getSupplierDuesUseCase.execute(shop, String(request.params.id));
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Supplier dues could not be loaded right now."));
    }
  },

  async getLedger(request: Request, response: Response) {
    try {
      const shop = await resolveFinanceShop(request);
      const result = await getSupplierLedgerUseCase.execute(shop, String(request.params.id));
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Supplier ledger could not be loaded right now."));
    }
  },

  async createPayment(request: Request, response: Response) {
    try {
      const shop = await resolveFinanceShop(request);
      const payment = await createSupplierPaymentUseCase.execute(shop, String(request.params.id), request.body);
      response.status(201).json({ message: "Supplier payment created successfully.", payment });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Supplier payment could not be saved right now."));
    }
  },

  async listPayments(request: Request, response: Response) {
    try {
      const shop = await resolveFinanceShop(request);
      const result = await listSupplierPaymentsUseCase.execute(shop, String(request.params.id));
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Supplier payments could not be loaded right now."));
    }
  },

  async listPurchases(request: Request, response: Response) {
    try {
      const shop = await resolveFinanceShop(request);
      const result = await listSupplierPurchasesUseCase.execute(shop, String(request.params.id));
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Supplier purchases could not be loaded right now."));
    }
  },

  async sendDueOtp(request: Request, response: Response) {
    try {
      const result = sendSupplierDueOtpUseCase.execute(request.body, requestBaseUrl(request));
      response.json({ message: "Supplier confirmation prepared successfully for WhatsApp.", channel: "WHATSAPP", ...result });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Failed to send supplier confirmation request."));
    }
  },

  async verifyDueOtp(request: Request, response: Response) {
    try {
      const result = verifySupplierDueOtpUseCase.execute(request.body);
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Failed to verify supplier confirmation request."));
    }
  },
};

// Standalone HTML handlers for the WhatsApp supplier-due-confirmation link,
// mounted at the top level (`/confirm-supplier-due/:token`, outside `/api`)
// in infrastructure/http/app.ts — same pattern as the original
// `routes/suppliers.ts` exports. Shares `supplierDueOtpStore` with the API
// handlers above.
export async function handleGetConfirmSupplierDue(request: Request, response: Response) {
  try {
    const token = request.params.token;
    if (typeof token !== "string") {
      response.status(400).send("Invalid token");
      return;
    }

    const found = supplierDueOtpStore.findByToken(token);
    if (!found || Date.now() > found.record.expiresAt) {
      response.status(400).send("Invalid link or link has expired.");
      return;
    }

    const { phone, record } = found;
    const notesHtml =
      record.notes.length > 0
        ? `
          <div class="details-title">পেমেন্ট বিবরণ:</div>
          <ul>${record.notes.map((item) => `<li>${item}</li>`).join("")}</ul>
        `
        : "";
    const statusHtml = record.status === "CONFIRMED" ? `<div class="success-banner">আপনি এই পেমেন্ট নিশ্চিত করেছেন।</div>` : "";

    response.send(`
      <!doctype html>
      <html lang="bn">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Supplier Due Confirmation</title>
        <style>
          body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: linear-gradient(180deg, #eefbf8 0%, #f7faf9 100%);
            color: #163732;
          }
          .card {
            max-width: 520px;
            margin: 32px auto;
            background: white;
            border-radius: 24px;
            padding: 28px;
            box-shadow: 0 16px 40px rgba(12, 140, 103, 0.08);
          }
          .header {
            text-align: center;
            margin-bottom: 24px;
          }
          .logo {
            font-size: 24px;
            font-weight: 800;
            color: #0c8c67;
          }
          .subtitle {
            color: #5f6a66;
            font-size: 15px;
            margin-top: 8px;
          }
          .amount-section {
            background: #f7faf9;
            border: 1px solid #d9e5e1;
            border-radius: 18px;
            padding: 20px;
            text-align: center;
            margin-bottom: 18px;
          }
          .amount-label {
            color: #5f6a66;
            font-size: 14px;
            margin-bottom: 8px;
          }
          .amount-value {
            color: #b3261e;
            font-size: 32px;
            font-weight: 800;
          }
          .detail-card {
            border: 1px solid #d9e5e1;
            border-radius: 18px;
            padding: 18px;
            margin-bottom: 18px;
          }
          .detail-row {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 10px;
            font-size: 15px;
          }
          .detail-label {
            color: #5f6a66;
            font-weight: 700;
          }
          .details-title {
            color: #163732;
            font-size: 15px;
            font-weight: 800;
            margin: 18px 0 10px;
          }
          ul {
            margin: 0;
            padding-left: 20px;
          }
          li {
            margin-bottom: 8px;
          }
          .btn-confirm {
            display: block;
            width: 100%;
            background-color: #0c8c67;
            color: white;
            border: none;
            padding: 15px;
            font-size: 17px;
            font-weight: 700;
            border-radius: 12px;
            cursor: pointer;
            text-align: center;
            box-shadow: 0 4px 12px rgba(12,140,103,0.15);
          }
          .success-banner {
            background: #e7f5ef;
            color: #0c8c67;
            border: 1px solid #b6dfd1;
            border-radius: 14px;
            padding: 12px 14px;
            margin-bottom: 16px;
            font-weight: 700;
            text-align: center;
          }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="header">
            <div class="logo">Dokan ERP</div>
            <div class="subtitle">সরবরাহকারী বকেয়া পেমেন্ট অনুমোদন</div>
          </div>

          ${statusHtml}

          <div class="amount-section">
            <div class="amount-label">পরিশোধের পরিমাণ</div>
            <div class="amount-value">৳${record.paymentAmount}</div>
          </div>

          <div class="detail-card">
            <div class="detail-row">
              <span class="detail-label">সরবরাহকারীর নাম:</span>
              <span>${record.supplierName}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">মোবাইল নম্বর:</span>
              <span>${phone}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">বর্তমান বকেয়া:</span>
              <span>৳${record.dueAmount}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">পেমেন্ট পদ্ধতি:</span>
              <span>${record.paymentMethod}</span>
            </div>
            ${notesHtml}
          </div>

          <form method="POST" action="/confirm-supplier-due/${token}">
            <button type="submit" class="btn-confirm">আমি এই পেমেন্ট নিশ্চিত করছি</button>
          </form>
        </div>
      </body>
      </html>
    `);
  } catch (error) {
    console.error(error);
    response.status(500).send("Internal Server Error");
  }
}

export async function handlePostConfirmSupplierDue(request: Request, response: Response) {
  try {
    const token = request.params.token;
    if (typeof token !== "string") {
      response.status(400).send("Invalid token");
      return;
    }

    const found = supplierDueOtpStore.findByToken(token);
    if (!found || Date.now() > found.record.expiresAt) {
      response.status(400).send("Invalid link or link has expired.");
      return;
    }

    found.record.status = "CONFIRMED";
    supplierDueOtpStore.set(found.phone, found.record);

    response.redirect(`/confirm-supplier-due/${token}`);
  } catch (error) {
    console.error(error);
    response.status(500).send("Internal Server Error");
  }
}
