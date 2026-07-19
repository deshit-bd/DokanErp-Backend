import { buildPhoneVariations, normalizeMobile, resolveAuthContext, type AuthContext } from "@domain/auth/auth.entity";
import { InvalidCredentialsError } from "@domain/auth/auth.errors";
import { ForbiddenError, NotFoundError, ValidationError } from "@domain/shared/app-error";

import type { AuthRepository, FullUser } from "../ports/auth-repository.port";
import { verifyPassword } from "../../../auth/password";

export type VerifiedSalesmanCredentials = { mobile: string; shopId: string; user: FullUser; authContext: AuthContext };

export class VerifySalesmanCredentialsUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(
    rawMobile: string | undefined,
    rawPassword: string | undefined,
    rawShopIdentifier: string | undefined,
  ): Promise<VerifiedSalesmanCredentials> {
    const mobile = normalizeMobile(rawMobile);
    const password = rawPassword?.trim() ?? "";
    const shopIdentifier = rawShopIdentifier?.trim() ?? "";

    if (!mobile || !password || !shopIdentifier) {
      throw new ValidationError("Mobile number, password, and shopId are required.");
    }

    const shop = await this.authRepository.resolveShopIdentifier(shopIdentifier);

    if (!shop) {
      throw new NotFoundError("Shop not found for the provided shopId/shopCode.");
    }

    const user = await this.authRepository.findUserByIdentity(mobile, buildPhoneVariations(mobile));

    const isPhoneMatch = user?.phone ? normalizeMobile(user.phone) === normalizeMobile(mobile) : false;
    const isEmailMatch = user?.email ? user.email.toLowerCase() === mobile.toLowerCase() : false;
    const isPasswordMatch = user ? await verifyPassword(password, user.passwordHash) : false;

    if (!user || (!isPhoneMatch && !isEmailMatch) || user.status !== "ACTIVE" || !isPasswordMatch) {
      throw new InvalidCredentialsError("Invalid mobile number or password.");
    }

    const authContext = resolveAuthContext(user, "MOBILE", shop.id);

    if (!authContext || authContext.role !== "SALESMAN" || authContext.shopId !== shop.id) {
      throw new ForbiddenError("This salesman account is not allowed for the selected shop.");
    }

    return { mobile, shopId: shop.id, user, authContext };
  }
}
