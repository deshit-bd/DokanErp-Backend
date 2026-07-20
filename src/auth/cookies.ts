import type { Request } from "express";

export function parseCookies(request: Request) {
  const cookieHeader = request.headers.cookie ?? "";

  return cookieHeader.split(";").reduce<Record<string, string>>((accumulator, part) => {
    const [rawName, ...rawValue] = part.trim().split("=");

    if (!rawName) {
      return accumulator;
    }

    accumulator[rawName] = decodeURIComponent(rawValue.join("="));
    return accumulator;
  }, {});
}
