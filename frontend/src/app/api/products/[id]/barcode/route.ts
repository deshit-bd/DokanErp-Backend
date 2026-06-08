import { proxyToBackend } from "@/lib/server/backend-proxy";

export async function GET(
  request: Request,
  context: { params: Promise<{ id: string }> },
) {
  const { id } = await context.params;
  const requestUrl = new URL(request.url);
  const queryString = requestUrl.search;

  return proxyToBackend(request, `/api/products/${id}/barcode.svg${queryString}`);
}
