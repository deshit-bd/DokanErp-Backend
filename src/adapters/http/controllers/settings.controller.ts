import type { Request, Response } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../../../auth/current-user";
import { GetStoreSettingsUseCase } from "../../../application/settings/use-cases/get-store-settings.use-case";
import { UpdateStoreSettingsUseCase } from "../../../application/settings/use-cases/update-store-settings.use-case";
import { UploadStoreDocumentUseCase } from "../../../application/settings/use-cases/upload-store-document.use-case";
import { GetInventorySettingsUseCase } from "../../../application/settings/use-cases/get-inventory-settings.use-case";
import { UpdateInventorySettingsUseCase } from "../../../application/settings/use-cases/update-inventory-settings.use-case";
import type { StoreDocumentKind } from "../../../utils/store-document-upload";

const getStoreSettingsUseCase = new GetStoreSettingsUseCase();
const updateStoreSettingsUseCase = new UpdateStoreSettingsUseCase();
const uploadStoreDocumentUseCase = new UploadStoreDocumentUseCase();
const getInventorySettingsUseCase = new GetInventorySettingsUseCase();
const updateInventorySettingsUseCase = new UpdateInventorySettingsUseCase();

async function resolveShopContext(request: Request) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (auth.payload.appType !== "MOBILE" || !auth.payload.shopId) {
    return {
      status: 403,
      body: { message: "Invalid application scope." },
    };
  }

  return { auth, shopId: auth.payload.shopId, ownerUserId: auth.user.id };
}

export const settingsController = {
  async getStoreSettings(request: Request, response: Response): Promise<void> {
    try {
      const context = await resolveShopContext(request);
      if (isAuthError(context as any)) {
        sendAuthError(response, context as any);
        return;
      }
      if ("status" in context) {
        response.status((context as any).status).json((context as any).body);
        return;
      }

      const result = await getStoreSettingsUseCase.execute((context as any).shopId);
      response.json(result);
    } catch (error) {
      console.error("Failed to load store settings.", error);
      response.status(503).json({
        message: "Store settings could not be loaded right now.",
      });
    }
  },

  async updateStoreSettings(request: Request, response: Response): Promise<void> {
    try {
      const context = await resolveShopContext(request);
      if (isAuthError(context as any)) {
        sendAuthError(response, context as any);
        return;
      }
      if ("status" in context) {
        response.status((context as any).status).json((context as any).body);
        return;
      }

      const result = await updateStoreSettingsUseCase.execute((context as any).shopId, (context as any).ownerUserId, request.body);
      response.json(result);
    } catch (error) {
      console.error("Failed to save store settings.", error);
      response.status(503).json({
        message: "Store settings could not be saved right now.",
      });
    }
  },

  async uploadStoreDocument(request: Request, response: Response): Promise<void> {
    try {
      const context = await resolveShopContext(request);
      if (isAuthError(context as any)) {
        sendAuthError(response, context as any);
        return;
      }
      if ("status" in context) {
        response.status((context as any).status).json((context as any).body);
        return;
      }

      const type = request.params.type as StoreDocumentKind;
      const result = await uploadStoreDocumentUseCase.execute((context as any).shopId, (context as any).ownerUserId, type, request.body, request);
      response.json(result);
    } catch (error) {
      console.error("Failed to upload store document.", error);
      response.status(503).json({
        message: error instanceof Error ? error.message : "Store document could not be uploaded right now.",
      });
    }
  },

  async getInventorySettings(request: Request, response: Response): Promise<void> {
    try {
      const context = await resolveShopContext(request);
      if (isAuthError(context as any)) {
        sendAuthError(response, context as any);
        return;
      }
      if ("status" in context) {
        response.status((context as any).status).json((context as any).body);
        return;
      }

      const result = await getInventorySettingsUseCase.execute((context as any).shopId);
      response.json(result);
    } catch (error) {
      console.error("Failed to load inventory settings.", error);
      response.status(503).json({
        message: "Inventory settings could not be loaded right now.",
      });
    }
  },

  async updateInventorySettings(request: Request, response: Response): Promise<void> {
    try {
      const context = await resolveShopContext(request);
      if (isAuthError(context as any)) {
        sendAuthError(response, context as any);
        return;
      }
      if ("status" in context) {
        response.status((context as any).status).json((context as any).body);
        return;
      }

      const result = await updateInventorySettingsUseCase.execute((context as any).shopId, request.body);
      response.json(result);
    } catch (error) {
      console.error("Failed to save inventory settings.", error);
      response.status(503).json({
        message: "Inventory settings could not be saved right now.",
      });
    }
  },

  async getSupportContact(request: Request, response: Response): Promise<void> {
    try {
      response.json({
        whatsapp: "8801700000000",
        email: "support@dokanerp.com",
        phone: "+8801700000000",
      });
    } catch (error) {
      response.status(500).json({ message: "Failed to fetch support contact details." });
    }
  },
};
