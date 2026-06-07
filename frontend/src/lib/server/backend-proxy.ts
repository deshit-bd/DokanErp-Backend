import { NextResponse } from "next/server";

function getBackendBaseUrl() {
  return process.env.BACKEND_URL || process.env.API_BASE_URL || "http://localhost:4000";
}

function buildBackendUrl(pathname: string) {
  return new URL(pathname, getBackendBaseUrl()).toString();
}

function copyUpstreamHeaders(upstream: Response) {
  const headers = new Headers();

  upstream.headers.forEach((value, key) => {
    if (key.toLowerCase() === "set-cookie") {
      return;
    }

    headers.append(key, value);
  });

  const cookieHeaders =
    "getSetCookie" in upstream.headers && typeof upstream.headers.getSetCookie === "function"
      ? upstream.headers.getSetCookie()
      : (() => {
          const cookie = upstream.headers.get("set-cookie");
          return cookie ? [cookie] : [];
        })();

  for (const cookie of cookieHeaders) {
    headers.append("set-cookie", cookie);
  }

  return headers;
}

export async function proxyToBackend(request: Request, pathname: string) {
  const headers = new Headers(request.headers);
  headers.delete("host");
  headers.delete("content-length");

  const upstream = await fetch(buildBackendUrl(pathname), {
    method: request.method,
    headers,
    body: request.method === "GET" || request.method === "HEAD" ? undefined : await request.arrayBuffer(),
    redirect: "manual",
  });

  return new NextResponse(await upstream.arrayBuffer(), {
    status: upstream.status,
    headers: copyUpstreamHeaders(upstream),
  });
}

export async function patchAvatarInBackend(request: Request, profileImageUrl: string) {
  const headers = new Headers(request.headers);
  headers.set("content-type", "application/json");
  headers.delete("host");
  headers.delete("content-length");

  const upstream = await fetch(buildBackendUrl("/api/auth/me/avatar"), {
    method: "PATCH",
    headers,
    body: JSON.stringify({ profileImageUrl }),
    redirect: "manual",
  });

  return new NextResponse(await upstream.arrayBuffer(), {
    status: upstream.status,
    headers: copyUpstreamHeaders(upstream),
  });
}
