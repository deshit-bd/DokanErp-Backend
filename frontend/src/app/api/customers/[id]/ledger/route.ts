import { proxyToBackend } from "@/lib/server/backend-proxy";

type RouteContext = {
  params: Promise<{
    id: string;
  }>;
};

export async function GET(request: Request, context: RouteContext) {
  const { id } = await context.params;
  return proxyToBackend(request, `/api/customers/${id}/ledger`);
}
