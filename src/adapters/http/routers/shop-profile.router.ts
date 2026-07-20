import { Router } from "express";

import { shopProfileController } from "../controllers/shop-profile.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware);

router.get("/", asyncHandler(shopProfileController.list));
router.get("/me/settings", asyncHandler(shopProfileController.getSettings));
router.get("/me/finance-sources", asyncHandler(shopProfileController.getFinanceSources));
router.post("/me/money-boxes", asyncHandler(shopProfileController.createMoneyBox));
router.put("/me/money-boxes/:id", asyncHandler(shopProfileController.updateMoneyBox));
router.post("/me/bank-accounts", asyncHandler(shopProfileController.createBankAccount));
router.put("/me/bank-accounts/:id", asyncHandler(shopProfileController.updateBankAccount));
router.patch("/me/settings", asyncHandler(shopProfileController.updateSettings));
router.get("/me/inventory-settings", asyncHandler(shopProfileController.getInventorySettings));
router.patch("/me/inventory-settings", asyncHandler(shopProfileController.updateInventorySettings));
router.patch("/me/logo", asyncHandler(shopProfileController.updateLogo));
router.get("/quick-setup/catalog", asyncHandler(shopProfileController.getQuickSetupCatalog));
router.get("/products", asyncHandler(shopProfileController.listProducts));
router.post("/products/local", asyncHandler(shopProfileController.createLocalProduct));
router.post("/quick-setup/catalog/select", asyncHandler(shopProfileController.selectQuickSetupProducts));
router.patch("/quick-setup/catalog/pricing", asyncHandler(shopProfileController.saveQuickSetupPricing));
router.patch("/products/:shopProductId", asyncHandler(shopProfileController.updateProduct));
router.get("/me/taxes-charges", asyncHandler(shopProfileController.getTaxesCharges));
router.post("/me/taxes", asyncHandler(shopProfileController.createTax));
router.post("/me/charges", asyncHandler(shopProfileController.createCharge));
router.patch("/me/taxes/:id", asyncHandler(shopProfileController.updateTax));
router.patch("/me/charges/:id", asyncHandler(shopProfileController.updateCharge));
router.delete("/me/taxes/:id", asyncHandler(shopProfileController.deleteTax));
router.delete("/me/charges/:id", asyncHandler(shopProfileController.deleteCharge));

export default router;
