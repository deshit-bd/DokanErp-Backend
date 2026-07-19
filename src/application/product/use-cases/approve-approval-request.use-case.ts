import { toProductResponse } from "@domain/product/product.entity";
import { ApprovalRequestNotFoundError } from "@domain/product/product.errors";

import type { ProductRepository } from "../ports/product-repository.port";

export class ApproveApprovalRequestUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(requestId: string, userId: string) {
    const approvalRequest = await this.productRepository.findApprovalRequestById(requestId);

    if (!approvalRequest) {
      throw new ApprovalRequestNotFoundError();
    }

    if (approvalRequest.status === "APPROVED" && approvalRequest.masterProductId) {
      const existingProduct = await this.productRepository.loadProductById(approvalRequest.masterProductId);
      return { alreadyApproved: true, product: existingProduct ? toProductResponse(existingProduct) : null };
    }

    const result = await this.productRepository.approveApprovalRequest(approvalRequest, userId);

    return { alreadyApproved: false, product: result ? toProductResponse(result) : null };
  }
}
