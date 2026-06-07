import { proxyToBackend } from "@/lib/server/backend-proxy";

export async function PATCH(
  request: Request,
  context: { params: Promise<{ id: string }> },
) {
  const { id } = await context.params;
  return proxyToBackend(request, `/api/products/${id}/status`);
}
