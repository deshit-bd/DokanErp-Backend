import type { Request, Response } from "express";

import { AppError, InternalError, NotFoundError, ServiceUnavailableError, UnauthorizedError } from "@domain/shared/app-error";
import { CustomerAccessForbiddenError } from "@domain/customer/customer.errors";
import { CancelSaleUseCase } from "@application/customer/use-cases/cancel-sale.use-case";
import { CreateCustomerPaymentUseCase } from "@application/customer/use-cases/create-customer-payment.use-case";
import { CreateCustomerUseCase } from "@application/customer/use-cases/create-customer.use-case";
import { CreateSaleUseCase } from "@application/customer/use-cases/create-sale.use-case";
import { GetCustomerLedgerUseCase } from "@application/customer/use-cases/get-customer-ledger.use-case";
import { GetCustomerUseCase } from "@application/customer/use-cases/get-customer.use-case";
import { GetSaleUseCase } from "@application/customer/use-cases/get-sale.use-case";
import { GetSalesClosingSummaryUseCase } from "@application/customer/use-cases/get-sales-closing-summary.use-case";
import { ListCustomerSalesUseCase } from "@application/customer/use-cases/list-customer-sales.use-case";
import { ListCustomersUseCase } from "@application/customer/use-cases/list-customers.use-case";
import { ListShopSalesUseCase } from "@application/customer/use-cases/list-shop-sales.use-case";
import { ResolveCustomerFinanceShopUseCase } from "@application/customer/use-cases/resolve-customer-finance-shop.use-case";
import { SendCustomerDueOtpUseCase } from "@application/customer/use-cases/send-customer-due-otp.use-case";
import { VerifyCustomerDueOtpUseCase } from "@application/customer/use-cases/verify-customer-due-otp.use-case";
import type { CustomerRepository, ShopScope } from "@application/customer/ports/customer-repository.port";

import { getAuthenticatedUser, isAuthError } from "../../../auth/current-user";
import { createNotification } from "./notification.controller";
import { PrismaCustomerRepository } from "../../persistence/prisma/customer.repository";
import { customerDueOtpStore } from "../../storage/customer-due-otp.store";

const customerRepository: CustomerRepository = new PrismaCustomerRepository();

const resolveCustomerFinanceShopUseCase = new ResolveCustomerFinanceShopUseCase(customerRepository);
const listCustomersUseCase = new ListCustomersUseCase(customerRepository);
const createCustomerUseCase = new CreateCustomerUseCase(customerRepository);
const getCustomerUseCase = new GetCustomerUseCase(customerRepository);
const listShopSalesUseCase = new ListShopSalesUseCase(customerRepository);
const getSalesClosingSummaryUseCase = new GetSalesClosingSummaryUseCase(customerRepository);
const getSaleUseCase = new GetSaleUseCase(customerRepository);
const cancelSaleUseCase = new CancelSaleUseCase(customerRepository);
const createSaleUseCase = new CreateSaleUseCase(customerRepository);
const listCustomerSalesUseCase = new ListCustomerSalesUseCase(customerRepository);
const createCustomerPaymentUseCase = new CreateCustomerPaymentUseCase(customerRepository);
const getCustomerLedgerUseCase = new GetCustomerLedgerUseCase(customerRepository);
const sendCustomerDueOtpUseCase = new SendCustomerDueOtpUseCase(customerDueOtpStore);
const verifyCustomerDueOtpUseCase = new VerifyCustomerDueOtpUseCase(customerDueOtpStore);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

/**
 * Bridges directly to `auth/current-user.ts` rather than `authMiddleware`,
 * mirroring `supplier.controller.ts` — this module's `GET /` and `GET /:id`
 * are dual-mode (an explicit `shopId` routes to a shop-finance view; its
 * absence falls back to a plain view that still requires
 * SUPER_ADMIN/ADMIN/SHOP_OWNER/SALESMAN, unlike suppliers' platform-admin-only
 * fallback), and `/send-due-otp` / `/verify-due-otp` require no
 * authentication at all in the original.
 */
function throwIfAuthError(auth: unknown): asserts auth is Exclude<Awaited<ReturnType<typeof getAuthenticatedUser>>, { status: number; body: any }> {
  if (isAuthError(auth as any)) {
    const authError = auth as { status: number; body: { message: string } };
    throw authError.status === 404 ? new NotFoundError(authError.body.message) : new UnauthorizedError(authError.body.message);
  }
}

async function requireCustomerAccess(request: Request) {
  const auth = await getAuthenticatedUser(request);
  throwIfAuthError(auth);

  if (!["SUPER_ADMIN", "ADMIN", "SHOP_OWNER", "SALESMAN"].includes(auth.payload.role)) {
    throw new CustomerAccessForbiddenError();
  }

  return auth;
}

async function resolveFinanceShop(request: Request): Promise<{ auth: Awaited<ReturnType<typeof requireCustomerAccess>>; shop: ShopScope }> {
  const auth = await requireCustomerAccess(request);

  const queryShopId = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";
  const bodyShopId = (request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "";

  const shop = await resolveCustomerFinanceShopUseCase.execute({
    role: auth.payload.role,
    authShopId: auth.payload.shopId,
    queryShopId,
    bodyShopId,
  });

  return { auth, shop };
}

function requestBaseUrl(request: Request): string {
  const envBaseUrl = process.env.BASE_URL;
  if (envBaseUrl && envBaseUrl.trim() !== "") {
    return envBaseUrl.trim().replace(/\/$/, "");
  }
  return `${request.protocol}://${request.get("host")}`;
}

export const customerController = {
  async list(request: Request, response: Response) {
    try {
      const requestedShopIdentifier = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";

      if (requestedShopIdentifier) {
        const { shop } = await resolveFinanceShop(request);
        const result = await listCustomersUseCase.executeFinance(shop, request.query);
        response.json({ shop, stats: result.stats, customers: result.customers });
        return;
      }

      await requireCustomerAccess(request);
      const result = await listCustomersUseCase.executePlain(request.query);
      response.json(result);
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError("Customers are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push."),
      );
    }
  },

  async create(request: Request, response: Response) {
    try {
      const { shop } = await resolveFinanceShop(request);
      const result = await createCustomerUseCase.execute(shop, request.body);

      if (result.linkedExisting) {
        response.status(200).json({ message: "Existing global customer linked to this shop successfully.", customer: result.customer });
        return;
      }

      await createNotification(shop.id, "GENERAL", "নতুন গ্রাহক যুক্ত হয়েছে", `গ্রাহক ${result.customerName} আপনার কাস্টমার তালিকায় সফলভাবে যুক্ত হয়েছে।`);

      response.status(201).json({ message: "Customer created successfully.", customer: result.customer });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError("Customer could not be created because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push."),
      );
    }
  },

  async getOne(request: Request, response: Response) {
    try {
      const requestedShopIdentifier = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";

      if (requestedShopIdentifier) {
        const { shop } = await resolveFinanceShop(request);
        const result = await getCustomerUseCase.executeFinance(shop, String(request.params.id));
        response.json({
          shop: { id: shop.id, shopCode: shop.shopCode, shopName: shop.shopName, phone: shop.phone, address: shop.address, area: shop.area, district: shop.district, status: shop.status },
          customer: result.customer,
        });
        return;
      }

      await requireCustomerAccess(request);
      const result = await getCustomerUseCase.executePlain(String(request.params.id));
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Customer could not be loaded right now."));
    }
  },

  async listShopSales(request: Request, response: Response) {
    try {
      const { shop } = await resolveFinanceShop(request);
      const result = await listShopSalesUseCase.execute(shop, request.query);
      response.json({ shop: { id: shop.id, shopCode: shop.shopCode, shopName: shop.shopName }, summary: result.summary, sales: result.sales });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Sales history could not be loaded right now."));
    }
  },

  async getSalesClosingSummary(request: Request, response: Response) {
    try {
      const { shop } = await resolveFinanceShop(request);
      const result = await getSalesClosingSummaryUseCase.execute(shop, request.query);
      response.json({
        shop: { id: shop.id, shopCode: shop.shopCode, shopName: shop.shopName },
        date: result.date,
        summary: result.summary,
        paymentBreakdown: result.paymentBreakdown,
        topProducts: result.topProducts,
        sales: result.sales,
      });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Daily closing summary could not be loaded right now."));
    }
  },

  async getSale(request: Request, response: Response) {
    try {
      const { shop } = await resolveFinanceShop(request);
      const result = await getSaleUseCase.execute(shop, String(request.params.saleId));
      response.json({
        shop: { id: shop.id, shopCode: shop.shopCode, shopName: shop.shopName, phone: shop.phone, address: shop.address },
        sale: result.sale,
      });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Sale details could not be loaded right now."));
    }
  },

  async cancelSale(request: Request, response: Response) {
    try {
      const { auth, shop } = await resolveFinanceShop(request);
      const sale = await cancelSaleUseCase.execute(shop, String(request.params.saleId), auth.user.id, request.body ?? {});
      response.json({ message: "Sale cancelled successfully.", sale });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Sale could not be cancelled right now."));
    }
  },

  async createSale(request: Request, response: Response) {
    try {
      const { auth, shop } = await resolveFinanceShop(request);
      const result = await createSaleUseCase.execute({ shop, createdByUserId: auth.user.id, body: request.body });

      await createNotification(
        shop.id,
        "SALE",
        "নতুন বিক্রয় হয়েছে",
        `রসিদ নং ${result.sale.invoiceNo || result.sale.id} | মোট বিক্রয় ৳${result.sale.totalAmount} | কাস্টমার: ${result.customer.name}`,
      );

      response.status(201).json({ message: "Customer sale created successfully.", sale: result.sale, payment: result.payment });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Customer sale could not be created right now."));
    }
  },

  async listCustomerSales(request: Request, response: Response) {
    try {
      const { shop } = await resolveFinanceShop(request);
      const result = await listCustomerSalesUseCase.execute(shop, String(request.params.id));
      response.json({ shop: { id: shop.id, shopCode: shop.shopCode, shopName: shop.shopName }, customer: result.customer, sales: result.sales });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Customer sales could not be loaded right now."));
    }
  },

  async createPayment(request: Request, response: Response) {
    try {
      const { shop } = await resolveFinanceShop(request);
      const body = request.body as {
        amount?: number | string | null;
        paymentMethod?: string | null;
        paymentDetails?: any;
        moneyBoxId?: string | null;
        referenceNo?: string | null;
        notes?: string | null;
        paidAt?: string | null;
      };

      const result = await createCustomerPaymentUseCase.execute({
        shop,
        customerIdentifier: String(request.params.id),
        amount: body.amount,
        paymentMethod: body.paymentMethod,
        paymentDetails: body.paymentDetails,
        moneyBoxId: body.moneyBoxId,
        referenceNo: body.referenceNo,
        notes: body.notes,
        paidAt: body.paidAt,
      });

      await createNotification(shop.id, "SALE", "পেমেন্ট গ্রহণ হয়েছে", `গ্রাহক ${result.customer.name} এর কাছ থেকে সফলভাবে ৳${result.payment.amount} আদায় করা হয়েছে।`);

      response.status(201).json({ message: "Customer payment recorded successfully.", payment: result.payment, dueBeforePayment: result.dueBeforePayment, dueAfterPayment: result.dueAfterPayment });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Customer payment could not be recorded right now."));
    }
  },

  async getLedger(request: Request, response: Response) {
    try {
      const { shop } = await resolveFinanceShop(request);
      const result = await getCustomerLedgerUseCase.execute(shop, String(request.params.id));
      response.json({ shop: { id: shop.id, shopCode: shop.shopCode, shopName: shop.shopName }, customer: result.customer, ledger: result.ledger, due: result.due });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Customer ledger could not be loaded right now."));
    }
  },

  async sendDueOtp(request: Request, response: Response) {
    try {
      const result = sendCustomerDueOtpUseCase.execute(request.body, requestBaseUrl(request));
      response.json({ message: "Confirmation prepared successfully for WhatsApp.", channel: "WHATSAPP", ...result });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to send confirmation request."));
    }
  },

  async verifyDueOtp(request: Request, response: Response) {
    try {
      const result = verifyCustomerDueOtpUseCase.execute(request.body);
      response.json(result);
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to verify confirmation request."));
    }
  },
};

// Standalone HTML handlers for the customer WhatsApp due-confirmation link,
// mounted at the top level (`/confirm-due/:token`, outside `/api`) in
// infrastructure/http/app.ts — same pattern as the original
// `routes/customers.ts` exports. Shares `customerDueOtpStore` with the API
// handlers above.
export async function handleGetConfirmDue(request: Request, response: Response) {
  try {
    const token = request.params.token;
    if (typeof token !== "string") {
      response.status(400).send("Invalid token");
      return;
    }
    const found = customerDueOtpStore.findByToken(token);

    if (!found || Date.now() > found.record.expiresAt) {
      response.send(`
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>অনুমোদন ব্যর্থ - Dokan ERP</title>
          <link href="https://fonts.googleapis.com/css2?family=Hind+Siliguri:wght@400;600;700&display=swap" rel="stylesheet">
          <style>
            body {
              font-family: 'Hind Siliguri', sans-serif;
              background-color: #f4f6f5;
              display: flex;
              justify-content: center;
              align-items: center;
              height: 100vh;
              margin: 0;
              padding: 20px;
            }
            .card {
              background-color: white;
              border-radius: 16px;
              box-shadow: 0 4px 20px rgba(0,0,0,0.08);
              padding: 30px;
              max-width: 400px;
              width: 100%;
              text-align: center;
            }
            h2 { color: #d32f2f; margin-bottom: 10px; }
            p { color: #555; font-size: 16px; line-height: 1.6; }
            .icon { font-size: 48px; margin-bottom: 20px; }
          </style>
        </head>
        <body>
          <div class="card">
            <div class="icon">❌</div>
            <h2>লিংকটি মেয়াদোত্তীর্ণ বা অবৈধ</h2>
            <p>দুঃখিত, বকেয়া অনুমোদনের এই লিংকটি অবৈধ অথবা এর ১০ মিনিটের মেয়াদ শেষ হয়ে গেছে। অনুগ্রহ করে আবার চেষ্টা করুন।</p>
          </div>
        </body>
        </html>
      `);
      return;
    }

    const { phone, record } = found;

    if (record.status === "CONFIRMED") {
      response.send(`
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>বকেয়া নিশ্চিতকরণ - Dokan ERP</title>
          <link href="https://fonts.googleapis.com/css2?family=Hind+Siliguri:wght@400;600;700&display=swap" rel="stylesheet">
          <style>
            body {
              font-family: 'Hind Siliguri', sans-serif;
              background-color: #f4f6f5;
              display: flex;
              justify-content: center;
              align-items: center;
              height: 100vh;
              margin: 0;
              padding: 20px;
            }
            .card {
              background-color: white;
              border-radius: 16px;
              box-shadow: 0 4px 20px rgba(0,0,0,0.08);
              padding: 30px;
              max-width: 400px;
              width: 100%;
              text-align: center;
            }
            h2 { color: #2e7d32; margin-bottom: 10px; }
            p { color: #555; font-size: 16px; line-height: 1.6; }
            .icon { font-size: 48px; margin-bottom: 20px; }
          </style>
        </head>
        <body>
          <div class="card">
            <div class="icon">✅</div>
            <h2>বকেয়া নিশ্চিত করা হয়েছে!</h2>
            <p>ধন্যবাদ, আপনার ৳${record.dueAmount} টাকার বকেয়া লেনদেনটি সফলভাবে নিশ্চিত করা হয়েছে। দোকানির চূড়ান্ত অনুমোদনের জন্য অপেক্ষা করা হচ্ছে।</p>
          </div>
        </body>
        </html>
      `);
      return;
    }

    const productListHtml = record.products.map((p) => `<li>${p}</li>`).join("");

    response.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>বকেয়া অনুমোদন - Dokan ERP</title>
        <link href="https://fonts.googleapis.com/css2?family=Hind+Siliguri:wght@400;600;700&display=swap" rel="stylesheet">
        <style>
          body {
            font-family: 'Hind Siliguri', sans-serif;
            background-color: #eaf2f0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
            box-sizing: border-box;
          }
          .card {
            background-color: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,107,83,0.06);
            padding: 30px;
            max-width: 450px;
            width: 100%;
            border: 1px solid #d7e5e0;
          }
          .header {
            text-align: center;
            margin-bottom: 25px;
          }
          .logo {
            font-size: 24px;
            font-weight: 700;
            color: #006b53;
            margin-bottom: 5px;
          }
          .subtitle {
            color: #666;
            font-size: 14px;
          }
          .amount-section {
            background-color: #f0f7f5;
            border-radius: 14px;
            padding: 20px;
            text-align: center;
            margin-bottom: 20px;
            border: 1px solid #e1e9e7;
          }
          .amount-label {
            font-size: 14px;
            color: #555;
            margin-bottom: 5px;
          }
          .amount-value {
            font-size: 32px;
            font-weight: 700;
            color: #b3261e;
          }
          .detail-card {
            margin-bottom: 25px;
          }
          .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            font-size: 15px;
            color: #444;
          }
          .detail-label {
            font-weight: 600;
            color: #5f6a66;
          }
          .products-title {
            font-weight: 700;
            margin-top: 15px;
            margin-bottom: 8px;
            color: #333;
          }
          ul {
            padding-left: 20px;
            margin: 0;
            color: #555;
            font-size: 14px;
          }
          li {
            margin-bottom: 6px;
          }
          .btn-confirm {
            display: block;
            width: 100%;
            background-color: #006b53;
            color: white;
            border: none;
            padding: 15px;
            font-size: 17px;
            font-weight: 700;
            border-radius: 12px;
            cursor: pointer;
            transition: background-color 0.2s;
            text-align: center;
            text-decoration: none;
            box-shadow: 0 4px 12px rgba(0,107,83,0.15);
          }
          .btn-confirm:hover {
            background-color: #00523f;
          }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="header">
            <div class="logo">Dokan ERP</div>
            <div class="subtitle">বকেয়া লেনদেন অনুমোদন</div>
          </div>

          <div class="amount-section">
            <div class="amount-label">বাকির পরিমাণ (Due Amount)</div>
            <div class="amount-value">৳${record.dueAmount}</div>
          </div>

          <div class="detail-card">
            <div class="detail-row">
              <span class="detail-label">ক্রেতার নাম:</span>
              <span>${record.customerName}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">মোবাইল নম্বর:</span>
              <span>${phone}</span>
            </div>

            ${record.products.length > 0 ? `
              <div class="products-title">ক্রয়কৃত পণ্যসমূহ:</div>
              <ul>${productListHtml}</ul>
            ` : ""}
          </div>

          <form method="POST" action="/confirm-due/${token}">
            <button type="submit" class="btn-confirm">আমি নিশ্চিত করছি</button>
          </form>
        </div>
      </body>
      </html>
    `);
  } catch (err) {
    console.error(err);
    response.status(500).send("Internal Server Error");
  }
}

export async function handlePostConfirmDue(request: Request, response: Response) {
  try {
    const token = request.params.token;
    if (typeof token !== "string") {
      response.status(400).send("Invalid token");
      return;
    }
    const found = customerDueOtpStore.findByToken(token);

    if (!found || Date.now() > found.record.expiresAt) {
      response.status(400).send("Invalid link or link has expired.");
      return;
    }

    found.record.status = "CONFIRMED";
    customerDueOtpStore.set(found.phone, found.record);

    response.redirect(`/confirm-due/${token}`);
  } catch (err) {
    console.error(err);
    response.status(500).send("Internal Server Error");
  }
}
