import { validatePasswordRules, validatePinRules } from "@domain/auth/auth.entity";
import { ConflictError, ForbiddenError, NotFoundError, PaymentRequiredError, ValidationError } from "@domain/shared/app-error";

import type { AuthRepository, SalesmanPermissions } from "../ports/auth-repository.port";
import { hashOtpCode } from "@domain/auth/auth.entity";
import { hashPassword } from "../../../auth/password";

export type RegisterSalesmanCommand = {
  ownerId: string;
  ownerShopIdFromSession: string | undefined;
  shopId: string | undefined;
  name: string | undefined;
  mobile: string | undefined;
  email: string | null | undefined;
  password: string | undefined;
  pin: string | undefined;
  permissions: Partial<SalesmanPermissions> | undefined;
};

export class RegisterSalesmanUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(command: RegisterSalesmanCommand) {
    const owner = await this.authRepository.findUserById(command.ownerId);

    if (!owner) {
      throw new NotFoundError("Owner account not found.");
    }

    const requestedShopIdentifier = command.shopId?.trim() || command.ownerShopIdFromSession || "";
    const name = command.name?.trim();
    const mobile = command.mobile?.trim();
    const email = command.email?.trim() || null;
    const password = command.password ?? "";
    const pin = command.pin?.trim() ?? "";
    const permissions: SalesmanPermissions = {
      canSell: command.permissions?.canSell ?? false,
      canViewStock: command.permissions?.canViewStock ?? false,
      canViewReports: command.permissions?.canViewReports ?? false,
      canChangePrice: command.permissions?.canChangePrice ?? false,
      canCollectDue: command.permissions?.canCollectDue ?? false,
    };

    if (!requestedShopIdentifier) {
      throw new ValidationError("shopId is required.");
    }
    if (!name) {
      throw new ValidationError("Salesman name is required.");
    }
    if (!mobile) {
      throw new ValidationError("Mobile number is required.");
    }
    if (!validatePasswordRules(password)) {
      throw new ValidationError("Password must be at least 4 characters long.");
    }
    if (pin && !validatePinRules(pin)) {
      throw new ValidationError("PIN must be exactly 4 digits.");
    }

    const requestedShop = await this.authRepository.resolveShopIdentifier(requestedShopIdentifier);

    if (!requestedShop) {
      throw new NotFoundError("Shop not found for the provided shopId/shopCode.");
    }

    const ownedShop = owner.ownedShops.find(
      (shop) => shop.id === requestedShop.id && shop.status !== "BLOCKED" && shop.status !== "SUSPENDED",
    );

    if (!ownedShop) {
      throw new ForbiddenError("You can only add salesmen to your own active shop.");
    }

    const { canAddSalesmanInCurrentTier } = await import("../../../subscription/access");
    const salesmanAccess = await canAddSalesmanInCurrentTier(ownedShop.id);

    if (!salesmanAccess.allowed) {
      const message = salesmanAccess.message ?? "Salesman limit reached for the current plan.";
      const details = { subscription: salesmanAccess.access };
      throw salesmanAccess.access?.tier === "BLOCKED"
        ? new PaymentRequiredError(message, details)
        : new ForbiddenError(message, details);
    }

    const [existingUserByPhone, existingUserByEmail] = await Promise.all([
      this.authRepository.findUserByPhone(mobile),
      email ? this.authRepository.findUserByEmail(email) : Promise.resolve(null),
    ]);

    if (existingUserByPhone) {
      throw new ConflictError("Mobile number is already in use.");
    }
    if (existingUserByEmail) {
      throw new ConflictError("Email is already in use.");
    }

    const user = await this.authRepository.createSalesman({
      name,
      mobile,
      email,
      passwordHash: await hashPassword(password),
      createdByUserId: command.ownerId,
      shopId: ownedShop.id,
      permissions,
      pinHash: pin ? hashOtpCode(pin) : null,
    });

    return {
      user,
      shop: { id: ownedShop.id, shopName: (ownedShop as any).shopName },
      role: "SALESMAN" as const,
      permissions,
      pinRequiredFromSettings: !pin,
    };
  }
}
