#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const repoRoot = path.resolve(__dirname, "..");
const backendRoot = path.join(repoRoot, "backend", "src");
const frontendApiRoot = path.join(repoRoot, "frontend", "src", "app", "api");
const reportsDir = path.join(repoRoot, "reports");

function read(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function titleCase(slug) {
  return slug
    .split(/[-/]/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function routePathFromFile(filePath) {
  const relative = path.relative(frontendApiRoot, filePath).replace(/\\/g, "/");
  return `/api/${relative.replace(/\/route\.ts$/, "").replace(/\[([^\]]+)\]/g, ":$1")}`;
}

function loadBackendMounts() {
  const appSource = read(path.join(backendRoot, "app.ts"));
  const importMatches = [...appSource.matchAll(/import\s+(\w+)(?:,\s*\{[^}]+\})?\s+from\s+"\.\/routes\/([^"]+)";/g)];
  const importMap = new Map(importMatches.map((match) => [match[1], match[2]]));
  const mountMatches = [...appSource.matchAll(/scopedRouter\.use\("([^"]+)",\s*(\w+)\);/g)];
  const mounts = new Map();

  for (const [, mountPath, importName] of mountMatches) {
    const routeFile = importMap.get(importName);
    if (!routeFile) {
      continue;
    }

    const existing = mounts.get(routeFile) || [];
    existing.push(mountPath);
    mounts.set(routeFile, existing);
  }

  return mounts;
}

function summarizeBackendRoute(routeFile) {
  const source = read(path.join(backendRoot, "routes", `${routeFile}.ts`));
  const methodMatches = [
    ...source.matchAll(/router\.(get|post|put|patch|delete)\("([^"]+)"(?:,|\))/g),
  ];

  return methodMatches.map((match) => {
    const method = match[1].toUpperCase();
    const subPath = match[2];
    return {
      method,
      subPath,
      fullPathSuffix: subPath === "/" ? "" : subPath,
    };
  });
}

function collectBackendDocs() {
  const mounts = loadBackendMounts();
  const routeFiles = fs
    .readdirSync(path.join(backendRoot, "routes"))
    .filter((name) => name.endsWith(".ts"))
    .map((name) => name.replace(/\.ts$/, ""))
    .sort();

  const groups = routeFiles.map((routeFile) => {
    const mountPaths = mounts.get(routeFile) || [];
    const endpoints = summarizeBackendRoute(routeFile);

    return {
      routeFile,
      label: titleCase(routeFile),
      mountPaths,
      endpoints,
    };
  });

  const publicEndpoints = [
    { method: "GET", path: "/health", note: "Service health check." },
    { method: "GET", path: "/confirm-due/:token", note: "Public due confirmation page handler." },
    { method: "POST", path: "/confirm-due/:token", note: "Public due confirmation submit handler." },
  ];

  return { groups, publicEndpoints };
}

function collectFrontendDocs() {
  const files = [];

  function walk(dirPath) {
    for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
      const fullPath = path.join(dirPath, entry.name);
      if (entry.isDirectory()) {
        walk(fullPath);
      } else if (entry.isFile() && entry.name === "route.ts") {
        files.push(fullPath);
      }
    }
  }

  if (fs.existsSync(frontendApiRoot)) {
    walk(frontendApiRoot);
  }

  return files
    .sort()
    .map((filePath) => {
      const source = read(filePath);
      const methods = [...source.matchAll(/export\s+async\s+function\s+(GET|POST|PUT|PATCH|DELETE)\b/g)].map(
        (match) => match[1],
      );
      const proxyTarget = source.match(/proxyToBackend\(request,\s*`?("([^"]+)"|`([^`]+)`)/);
      const directTarget = proxyTarget ? proxyTarget[2] || proxyTarget[3] : null;
      const isCustom = !source.includes("proxyToBackend(request,") || source.includes("buildBackendUrl(");
      const note = filePath.endsWith(path.join("auth", "me", "avatar", "route.ts"))
        ? "Uploads the image into the Next.js public folder, then patches the backend profile avatar."
        : filePath.endsWith(path.join("bulk-upload", "route.ts"))
          ? "Custom Next.js import/export helper with local log storage and multiple upstream backend calls."
          : directTarget
            ? `Thin proxy to backend ${directTarget}.`
            : "Custom Next.js route.";

      return {
        filePath,
        path: routePathFromFile(filePath),
        methods,
        target: directTarget,
        kind: isCustom ? "custom" : "proxy",
        note,
      };
    });
}

function buildMarkdown(data) {
  const today = new Date().toISOString().slice(0, 10);
  const backendEndpointCount = data.backend.groups.reduce((sum, group) => sum + group.endpoints.length, 0);
  const frontendEndpointCount = data.frontend.reduce((sum, route) => sum + route.methods.length, 0);
  const mountedGroupCount = data.backend.groups.filter((group) => group.mountPaths.length > 0).length;
  const lines = [];

  lines.push("# Dokan-ERP Project Analysis and API Documentation");
  lines.push("");
  lines.push(`Generated from the current repository source on ${today}.`);
  lines.push("");
  lines.push("## Project Analysis");
  lines.push("");
  lines.push("- Workspace layout: `backend/` Express + Prisma API, `frontend/` Next.js App Router web app, `mobile/` Flutter mobile app.");
  lines.push("- Backend entrypoint: `backend/src/app.ts`, mounted under both `/web/api` and `/app/api` plus public `/health` and `/confirm-due/:token` endpoints.");
  lines.push("- Frontend API layer: `frontend/src/app/api/**`, mostly thin proxies to backend `/web/api/*` through `frontend/src/lib/server/backend-proxy.ts`.");
  lines.push("- Mobile API layer: callers are expected to use `/app/api/*`; mobile README requires `DOKAN_API_BASE_URL=http://YOUR_SERVER_IP:4000`.");
  lines.push(`- Current API surface found in code: ${backendEndpointCount} backend route handlers across ${mountedGroupCount} mounted route groups, plus ${frontendEndpointCount} frontend API handlers.`);
  lines.push("");
  lines.push("## API Topology");
  lines.push("");
  lines.push("- Web clients normally hit `http://localhost:4000/web/api/*` directly or `http://localhost:3000/api/*` through Next.js proxy routes.");
  lines.push("- Mobile clients hit `http://localhost:4000/app/api/*`.");
  lines.push("- Authentication is resolved from the access-token cookie or an `Authorization: Bearer <token>` header.");
  lines.push("- The mobile `/app/api/*` scope has a subscription-access gate in `backend/src/app.ts`; `/auth` and `/subscriptions` are exempt from that global check.");
  lines.push("");
  lines.push("## Public Backend Endpoints");
  lines.push("");

  for (const endpoint of data.backend.publicEndpoints) {
    lines.push(`- \`${endpoint.method} ${endpoint.path}\` - ${endpoint.note}`);
  }

  lines.push("");
  lines.push("## Backend Route Groups");
  lines.push("");

  for (const group of data.backend.groups) {
    if (group.mountPaths.length === 0) {
      continue;
    }

    lines.push(`### ${group.label}`);
    lines.push("");
    lines.push(`Source file: \`backend/src/routes/${group.routeFile}.ts\``);
    lines.push("");
    lines.push(`Mounted as: ${group.mountPaths.map((mount) => `\`${mount}\``).join(", ")}`);
    lines.push("");

    for (const endpoint of group.endpoints) {
      const renderedPaths = group.mountPaths
        .map((mountPath) => {
          const suffix = endpoint.subPath === "/" ? "" : endpoint.subPath;
          return `\`${endpoint.method} /web/api${mountPath}${suffix}\` and \`${endpoint.method} /app/api${mountPath}${suffix}\``;
        })
        .join("; ");
      lines.push(`- ${renderedPaths}`);
    }

    lines.push("");
  }

  lines.push("## Frontend API Routes");
  lines.push("");
  lines.push("These are the active Next.js routes under `frontend/src/app/api/**`. Most forward to backend `/web/api/*`; custom handlers are called out explicitly.");
  lines.push("");

  for (const route of data.frontend) {
    const methodList = route.methods.length ? route.methods.join(", ") : "Unknown";
    lines.push(`- \`${methodList} ${route.path}\` - ${route.note}`);
  }

  lines.push("");
  lines.push("## Notes");
  lines.push("");
  lines.push("- `frontend/src/app/api/bulk-upload/route.ts` is not a single-pass proxy; it parses spreadsheets, keeps local import/export logs, and calls multiple backend routes.");
  lines.push("- `frontend/src/app/api/auth/me/avatar/route.ts` stores the uploaded file in `frontend/public/uploads/profiles/` before updating the backend user profile.");
  lines.push("- The older root file `dokan-erp-app api list.txt` exists, but this document is generated from the current codebase and should be treated as the fresher source of truth.");
  lines.push("");

  return lines.join("\n");
}

function markdownToHtml(markdown) {
  const lines = markdown.split("\n");
  const html = [];
  let inList = false;

  function closeList() {
    if (inList) {
      html.push("</ul>");
      inList = false;
    }
  }

  for (const line of lines) {
    if (!line.trim()) {
      closeList();
      continue;
    }

    if (line.startsWith("### ")) {
      closeList();
      html.push(`<h3>${inlineMarkdown(line.slice(4))}</h3>`);
      continue;
    }

    if (line.startsWith("## ")) {
      closeList();
      html.push(`<h2>${inlineMarkdown(line.slice(3))}</h2>`);
      continue;
    }

    if (line.startsWith("# ")) {
      closeList();
      html.push(`<h1>${inlineMarkdown(line.slice(2))}</h1>`);
      continue;
    }

    if (line.startsWith("- ")) {
      if (!inList) {
        html.push("<ul>");
        inList = true;
      }
      html.push(`<li>${inlineMarkdown(line.slice(2))}</li>`);
      continue;
    }

    closeList();
    html.push(`<p>${inlineMarkdown(line)}</p>`);
  }

  closeList();

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Dokan-ERP API Documentation</title>
  <style>
    :root {
      --text: #1f2937;
      --muted: #475569;
      --border: #d7dde7;
      --accent: #0f766e;
      --paper: #ffffff;
      --bg: #f5f7fb;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: linear-gradient(180deg, #eff6ff 0%, var(--bg) 100%);
      color: var(--text);
      font-family: "DejaVu Sans", Arial, sans-serif;
      line-height: 1.45;
    }
    main {
      width: 900px;
      margin: 32px auto;
      background: var(--paper);
      padding: 40px 52px;
      border: 1px solid var(--border);
      box-shadow: 0 18px 60px rgba(15, 23, 42, 0.08);
    }
    h1, h2, h3 {
      margin: 0 0 12px;
      color: #0f172a;
      line-height: 1.2;
    }
    h1 {
      font-size: 28px;
      padding-bottom: 12px;
      border-bottom: 3px solid var(--accent);
    }
    h2 {
      font-size: 20px;
      margin-top: 28px;
      padding-top: 12px;
      border-top: 1px solid var(--border);
    }
    h3 {
      font-size: 16px;
      margin-top: 22px;
      color: var(--accent);
    }
    p, li {
      font-size: 12.5px;
      color: var(--text);
    }
    p {
      margin: 0 0 10px;
    }
    ul {
      margin: 0 0 12px 18px;
      padding: 0;
    }
    li {
      margin: 0 0 6px;
    }
    code {
      font-family: "DejaVu Sans Mono", "Courier New", monospace;
      font-size: 11.5px;
      background: #ecfeff;
      color: #134e4a;
      padding: 1px 4px;
      border-radius: 4px;
    }
    @page {
      size: A4;
      margin: 18mm 14mm;
    }
  </style>
</head>
<body>
  <main>
    ${html.join("\n")}
  </main>
</body>
</html>`;
}

function inlineMarkdown(value) {
  let rendered = escapeHtml(value);
  rendered = rendered.replace(/`([^`]+)`/g, "<code>$1</code>");
  return rendered;
}

function wrapText(line, width = 92) {
  if (!line.trim()) {
    return [""];
  }

  const indentMatch = line.match(/^(\s*[-]*\s*)/);
  const indent = indentMatch ? indentMatch[1] : "";
  const words = line.trim().split(/\s+/);
  const wrapped = [];
  let current = indent;

  for (const word of words) {
    const candidate = current.trim() ? `${current}${current.trim() === indent.trim() ? "" : " "}${word}` : `${indent}${word}`;
    if (candidate.length <= width) {
      current = candidate;
      continue;
    }

    if (current.trim()) {
      wrapped.push(current);
    }

    current = `${indent}${word}`;
  }

  if (current.trim()) {
    wrapped.push(current);
  }

  return wrapped.length ? wrapped : [line];
}

function escapePdfText(value) {
  return value.replace(/\\/g, "\\\\").replace(/\(/g, "\\(").replace(/\)/g, "\\)");
}

function writeSimplePdf(markdown, outputPath) {
  const lines = markdown
    .split("\n")
    .flatMap((line) => wrapText(line))
    .map((line) => line.replace(/^###\s*/, "").replace(/^##\s*/, "").replace(/^#\s*/, ""))
    .map((line) => line.replace(/`/g, ""));

  const linesPerPage = 48;
  const pages = [];

  for (let index = 0; index < lines.length; index += linesPerPage) {
    pages.push(lines.slice(index, index + linesPerPage));
  }

  const objects = [];

  function addObject(body) {
    objects.push(body);
    return objects.length;
  }

  const fontObjectId = addObject("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");
  const pageObjectIds = [];
  const contentObjectIds = [];
  const pagesObjectId = 2;

  addObject("__PAGES_PLACEHOLDER__");

  for (const pageLines of pages) {
    const commands = ["BT", "/F1 10 Tf", "50 760 Td", "14 TL"];

    for (const line of pageLines) {
      commands.push(`(${escapePdfText(line)}) Tj`);
      commands.push("T*");
    }

    commands.push("ET");
    const stream = commands.join("\n");
    const contentObjectId = addObject(`<< /Length ${Buffer.byteLength(stream, "utf8")} >>\nstream\n${stream}\nendstream`);
    const pageObjectId = addObject(
      `<< /Type /Page /Parent ${pagesObjectId} 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 ${fontObjectId} 0 R >> >> /Contents ${contentObjectId} 0 R >>`,
    );
    contentObjectIds.push(contentObjectId);
    pageObjectIds.push(pageObjectId);
  }

  objects[pagesObjectId - 1] = `<< /Type /Pages /Kids [${pageObjectIds.map((id) => `${id} 0 R`).join(" ")}] /Count ${pageObjectIds.length} >>`;
  const catalogObjectId = addObject(`<< /Type /Catalog /Pages ${pagesObjectId} 0 R >>`);

  let pdf = "%PDF-1.4\n";
  const offsets = [0];

  for (let index = 0; index < objects.length; index += 1) {
    offsets.push(Buffer.byteLength(pdf, "utf8"));
    pdf += `${index + 1} 0 obj\n${objects[index]}\nendobj\n`;
  }

  const xrefOffset = Buffer.byteLength(pdf, "utf8");
  pdf += `xref\n0 ${objects.length + 1}\n`;
  pdf += "0000000000 65535 f \n";

  for (let index = 1; index < offsets.length; index += 1) {
    pdf += `${String(offsets[index]).padStart(10, "0")} 00000 n \n`;
  }

  pdf += `trailer\n<< /Size ${objects.length + 1} /Root ${catalogObjectId} 0 R >>\nstartxref\n${xrefOffset}\n%%EOF`;
  fs.writeFileSync(outputPath, pdf, "utf8");
}

function main() {
  ensureDir(reportsDir);
  const backend = collectBackendDocs();
  const frontend = collectFrontendDocs();
  const markdown = buildMarkdown({ backend, frontend });
  const html = markdownToHtml(markdown);

  const markdownPath = path.join(reportsDir, "dokan-erp-api-documentation.md");
  const htmlPath = path.join(reportsDir, "dokan-erp-api-documentation.html");
  const pdfPath = path.join(reportsDir, "dokan-erp-api-documentation.pdf");

  fs.writeFileSync(markdownPath, `${markdown}\n`, "utf8");
  fs.writeFileSync(htmlPath, html, "utf8");
  writeSimplePdf(markdown, pdfPath);

  console.log(
    JSON.stringify(
      {
        markdownPath,
        htmlPath,
        pdfPath,
        backendGroups: backend.groups.filter((group) => group.mountPaths.length > 0).length,
        backendEndpoints: backend.groups.reduce((sum, group) => sum + group.endpoints.length, 0),
        frontendRoutes: frontend.length,
      },
      null,
      2,
    ),
  );
}

main();
