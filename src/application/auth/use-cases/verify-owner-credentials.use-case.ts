import { buildPhoneVariations, normalizeMobile, resolveAuthContext, type AuthContext } from "@domain/auth/auth.entity";
import { InvalidCredentialsError } from "@domain/auth/auth.errors";
import { ForbiddenError, ValidationError } from "@domain/shared/app-error";

import type { AuthRepository, FullUser } from "../ports/auth-repository.port";
import { verifyPassword } from "../../../auth/password";

export type VerifiedOwnerCredentials = { mobile: string; user: FullUser; authContext: AuthContext };

export class VerifyOwnerCredentialsUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(rawMobile: string | undefined, rawPassword: string | undefined): Promise<VerifiedOwnerCredentials> {
    const mobile = normalizeMobile(rawMobile);
    const password = rawPassword?.trim() ?? "";

    if (!mobile || !password) {
      throw new ValidationError("Mobile number and password are required.");
    }

    const user = await this.authRepository.findUserByIdentity(mobile, buildPhoneVariations(mobile));

    const isPhoneMatch = user?.phone ? normalizeMobile(user.phone) === normalizeMobile(mobile) : false;
    const isEmailMatch = user?.email ? user.email.toLowerCase() === mobile.toLowerCase() : false;
    const isPasswordMatch = user ? await verifyPassword(password, user.passwordHash) : false;

    if (!user || (!isPhoneMatch && !isEmailMatch) || user.status !== "ACTIVE" || !isPasswordMatch) {
      throw new InvalidCredentialsError("Invalid mobile number or password.");
    }

    const authContext = resolveAuthContext(user, "MOBILE");

    if (!authContext || authContext.role !== "SHOP_OWNER") {
      throw new ForbiddenError("Only shop owners can use this login flow.");
    }

    return { mobile, user, authContext };
  }
}
