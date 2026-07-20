import type { ProductRepository } from "../ports/product-repository.port";

export class RejectApprovalRequestUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(requestId: string, userId: string, reason: unknown) {
    const normalizedReason = typeof reason === "string" ? reason.trim() || null : null;
    const approvalRequest = await this.productRepository.rejectApprovalRequest(requestId, userId, normalizedReason);

    return { id: approvalRequest.id, status: approvalRequest.status, rejectionReason: approvalRequest.rejectionReason };
  }
}
