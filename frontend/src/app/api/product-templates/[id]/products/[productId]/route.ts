import { proxyToBackend } from "@/lib/server/backend-proxy";

export async function DELETE(
  request: Request,
  context: { params: Promise<{ id: string; productId: string }> },
) {
  const { id, productId } = await context.params;
  return proxyToBackend(request, `/api/product-templates/${id}/products/${productId}`);
}
