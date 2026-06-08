import { proxyToBackend } from "@/lib/server/backend-proxy";

export async function GET(request: Request) {
  return proxyToBackend(request, "/api/money-boxes");
}

export async function POST(request: Request) {
  return proxyToBackend(request, "/api/money-boxes");
}
