import { proxyToBackend } from "@/lib/server/backend-proxy";

export async function PUT(
  request: Request,
  { params }: { params: Promise<{ id: string }> },
) {
  const { id } = await params;
  return proxyToBackend(request, `/api/bank-accounts/${id}`);
}
