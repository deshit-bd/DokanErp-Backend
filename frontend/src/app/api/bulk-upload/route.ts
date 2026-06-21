import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { NextResponse } from "next/server";
import * as XLSX from "xlsx";

export const runtime = "nodejs";

type DuplicateHandling = "SKIP_DUPLICATE" | "UPDATE_EXISTING" | "STOP_IMPORT";
type ErrorHandling = "SKIP_ERROR_ROWS" | "STOP_ON_FIRST_ERROR" | "IMPORT_VALID_ROWS_ONLY";
type ImportModule =
  | "product-catalog"
  | "product-category"
  | "brand"
  | "unit"
  | "supplier-data"
  | "barcode-database"
  | "bank-account"
  | "money-box"
  | "product-template";

type ImportErrorItem = {
  row: number;
  message: string;
};

type ImportLogRecord = {
  id: string;
  fileName: string;
  module: string;
  importedBy: string;
  totalRecords: number;
  success: number;
  failed: number;
  status: "Completed" | "Partial" | "Failed";
  date: string;
  createdAt: string;
  duplicateHandling: DuplicateHandling;
  errorHandling: ErrorHandling;
  notes: string | null;
  summary: {
    totalRows: number;
    created: number;
    updated: number;
    skipped: number;
    failed: number;
    stoppedEarly: boolean;
    errors: ImportErrorItem[];
  };
};

type ExportLogRecord = {
  id: string;
  fileName: string;
  module: string;
  exportedBy: string;
  records: number;
  format: string;
  date: string;
  createdAt: string;
};

type ImportExportLogStore = {
  imports: ImportLogRecord[];
  exports: ExportLogRecord[];
};

type ProductFiltersPayload = {
  filters?: {
    categories?: Array<{ id: string; name: string }>;
    brands?: Array<{ id: string; name: string; logoUrl?: string | null }>;
    units?: Array<{ id: string; name: string; shortName: string }>;
  };
  products?: Array<{
    id: string;
    sku: string;
    name: string;
    note?: string | null;
    categoryId?: string | null;
    brandId?: string | null;
    unitId?: string | null;
    price?: number | null;
    suggestedPrice?: number | null;
    packageSize?: string | null;
    pictureUrl?: string | null;
    barcode?: string | null;
  }>;
};

function getBackendBaseUrl() {
  return process.env.BACKEND_URL || process.env.API_BASE_URL || "http://localhost:4000";
}

function getLogStorePath() {
  return path.join(process.cwd(), ".data", "import-export-logs.json");
}

function buildBackendUrl(pathname: string) {
  return new URL(`/web${pathname}`, getBackendBaseUrl()).toString();
}

function normalizeText(value: unknown) {
  return String(value ?? "").trim();
}

function normalizeKey(value: unknown) {
  return normalizeText(value).toLowerCase();
}

function normalizeOptionalText(value: unknown) {
  const text = normalizeText(value);
  return text || null;
}

function normalizeNumber(value: unknown) {
  if (value == null || value === "") {
    return null;
  }

  const parsed = Number(value);
  return Number.isNaN(parsed) ? null : parsed;
}

function findValue(row: Record<string, unknown>, aliases: string[]) {
  for (const alias of aliases) {
    for (const [key, value] of Object.entries(row)) {
      if (normalizeKey(key) === normalizeKey(alias)) {
        return value;
      }
    }
  }

  return undefined;
}

async function parseUpstream(upstream: Response) {
  const rawBody = await upstream.text();

  try {
    return {
      ok: upstream.ok,
      status: upstream.status,
      body: JSON.parse(rawBody) as Record<string, any>,
    };
  } catch {
    return {
      ok: upstream.ok,
      status: upstream.status,
      body: { message: rawBody || "Unexpected upstream response." },
    };
  }
}

function buildJsonHeaders(request: Request) {
  const headers = new Headers(request.headers);
  headers.set("content-type", "application/json");
  headers.delete("host");
  headers.delete("content-length");
  return headers;
}

async function backendRequest(
  request: Request,
  pathname: string,
  init?: { method?: string; body?: Record<string, unknown> | null },
) {
  const upstream = await fetch(buildBackendUrl(pathname), {
    method: init?.method ?? "GET",
    headers: buildJsonHeaders(request),
    body: init?.body ? JSON.stringify(init.body) : undefined,
    redirect: "manual",
  });

  return parseUpstream(upstream);
}

async function fetchCollection<T>(request: Request, pathname: string) {
  const response = await backendRequest(request, pathname);

  if (!response.ok) {
    throw new Error(response.body.message ?? `Failed to load ${pathname}.`);
  }

  return response.body as T;
}

async function ensureLogDirectory() {
  await mkdir(path.dirname(getLogStorePath()), { recursive: true });
}

async function readLogStore(): Promise<ImportExportLogStore> {
  await ensureLogDirectory();

  try {
    const raw = await readFile(getLogStorePath(), "utf8");
    const parsed = JSON.parse(raw) as Partial<ImportExportLogStore>;

    return {
      imports: Array.isArray(parsed.imports) ? parsed.imports : [],
      exports: Array.isArray(parsed.exports) ? parsed.exports : [],
    };
  } catch {
    return {
      imports: [],
      exports: [],
    };
  }
}

async function writeLogStore(store: ImportExportLogStore) {
  await ensureLogDirectory();
  await writeFile(getLogStorePath(), JSON.stringify(store, null, 2), "utf8");
}

function formatDisplayDate(value: Date) {
  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  }).format(value);
}

function deriveImportStatus(summary: Awaited<ReturnType<typeof processRows>>): "Completed" | "Partial" | "Failed" {
  const success = summary.created + summary.updated;

  if (success === 0 && summary.failed > 0) {
    return "Failed";
  }

  if (summary.failed > 0 || summary.skipped > 0 || summary.stoppedEarly) {
    return "Partial";
  }

  return "Completed";
}

async function appendImportLog(params: {
  request: Request;
  fileName: string;
  moduleLabel: string;
  duplicateHandling: DuplicateHandling;
  errorHandling: ErrorHandling;
  notes: string | null;
  summary: Awaited<ReturnType<typeof processRows>>;
}) {
  const [store, authMe] = await Promise.all([
    readLogStore(),
    backendRequest(params.request, "/api/auth/me"),
  ]);

  const createdAt = new Date();
  const importedBy =
    authMe.ok && authMe.body?.user?.name
      ? String(authMe.body.user.name)
      : authMe.ok && authMe.body?.session?.role
        ? String(authMe.body.session.role).replace(/_/g, " ")
        : "Unknown User";

  const record: ImportLogRecord = {
    id: `${createdAt.getTime()}`,
    fileName: params.fileName,
    module: params.moduleLabel,
    importedBy,
    totalRecords: params.summary.totalRows,
    success: params.summary.created + params.summary.updated,
    failed: params.summary.failed,
    status: deriveImportStatus(params.summary),
    date: formatDisplayDate(createdAt),
    createdAt: createdAt.toISOString(),
    duplicateHandling: params.duplicateHandling,
    errorHandling: params.errorHandling,
    notes: params.notes,
    summary: params.summary,
  };

  const nextStore: ImportExportLogStore = {
    ...store,
    imports: [record, ...store.imports],
  };

  await writeLogStore(nextStore);
  return record;
}

function buildLogStats(store: ImportExportLogStore) {
  const successfulImports = store.imports.reduce((sum, item) => sum + item.success, 0);
  const failedImports = store.imports.reduce((sum, item) => sum + item.failed, 0);
  const totalExportedRecords = store.exports.reduce((sum, item) => sum + item.records, 0);

  return {
    totalImports: store.imports.length,
    successfulImports,
    failedImports,
    totalExports: store.exports.length,
    totalExportedRecords,
  };
}

export async function GET() {
  const store = await readLogStore();

  return NextResponse.json({
    imports: store.imports,
    exports: store.exports,
    stats: buildLogStats(store),
  });
}

function shouldStopOnError(errorHandling: ErrorHandling) {
  return errorHandling === "STOP_ON_FIRST_ERROR";
}

function isRowSkippable(errorHandling: ErrorHandling) {
  return errorHandling === "SKIP_ERROR_ROWS" || errorHandling === "IMPORT_VALID_ROWS_ONLY";
}

async function processRows(params: {
  rows: Array<Record<string, unknown>>;
  duplicateHandling: DuplicateHandling;
  errorHandling: ErrorHandling;
  onRow: (params: {
    row: Record<string, unknown>;
    rowIndex: number;
    duplicateHandling: DuplicateHandling;
  }) => Promise<"created" | "updated" | "skipped">;
}) {
  const summary = {
    totalRows: params.rows.length,
    created: 0,
    updated: 0,
    skipped: 0,
    failed: 0,
    stoppedEarly: false,
    errors: [] as ImportErrorItem[],
  };

  for (let index = 0; index < params.rows.length; index += 1) {
    const row = params.rows[index];

    try {
      const result = await params.onRow({
        row,
        rowIndex: index + 2,
        duplicateHandling: params.duplicateHandling,
      });

      if (result === "created") {
        summary.created += 1;
      } else if (result === "updated") {
        summary.updated += 1;
      } else {
        summary.skipped += 1;
      }
    } catch (error) {
      summary.failed += 1;
      summary.errors.push({
        row: index + 2,
        message: error instanceof Error ? error.message : "Unknown import error.",
      });

      if (shouldStopOnError(params.errorHandling) || !isRowSkippable(params.errorHandling)) {
        summary.stoppedEarly = true;
        break;
      }
    }
  }

  return summary;
}

function buildSummaryMessage(moduleLabel: string, summary: Awaited<ReturnType<typeof processRows>>) {
  const base = `${moduleLabel} import completed. Created ${summary.created}, updated ${summary.updated}, skipped ${summary.skipped}, failed ${summary.failed}.`;

  if (summary.stoppedEarly) {
    return `${base} Import stopped early after an error.`;
  }

  return base;
}

async function buildImportSuccessResponse(params: {
  request: Request;
  fileName: string;
  moduleLabel: string;
  duplicateHandling: DuplicateHandling;
  errorHandling: ErrorHandling;
  notes: string | null;
  summary: Awaited<ReturnType<typeof processRows>>;
}) {
  const log = await appendImportLog({
    request: params.request,
    fileName: params.fileName,
    moduleLabel: params.moduleLabel,
    duplicateHandling: params.duplicateHandling,
    errorHandling: params.errorHandling,
    notes: params.notes,
    summary: params.summary,
  });

  return NextResponse.json({
    message: buildSummaryMessage(params.moduleLabel, params.summary),
    module: params.moduleLabel,
    notes: params.notes,
    summary: params.summary,
    log,
  });
}

export async function POST(request: Request) {
  try {
    const formData = await request.formData();
    const module = normalizeText(formData.get("module")) as ImportModule;
    const duplicateHandling = normalizeText(formData.get("duplicateHandling")) as DuplicateHandling;
    const errorHandling = normalizeText(formData.get("errorHandling")) as ErrorHandling;
    const file = formData.get("file");
    const notes = normalizeOptionalText(formData.get("notes"));

    if (!(file instanceof File)) {
      return NextResponse.json({ message: "Please choose an import file." }, { status: 400 });
    }

    if (!module) {
      return NextResponse.json({ message: "Please select a module." }, { status: 400 });
    }

    const bytes = await file.arrayBuffer();
    const workbook = XLSX.read(Buffer.from(bytes), { type: "buffer" });
    const firstSheetName = workbook.SheetNames[0];

    if (!firstSheetName) {
      return NextResponse.json({ message: "The uploaded file does not contain any sheets." }, { status: 400 });
    }

    const rows = XLSX.utils.sheet_to_json<Record<string, unknown>>(workbook.Sheets[firstSheetName], {
      defval: "",
    });

    if (rows.length === 0) {
      return NextResponse.json({ message: "The uploaded file does not contain any data rows." }, { status: 400 });
    }

    if (module === "product-category") {
      const categoriesResponse = await fetchCollection<{
        categories?: Array<{ id: string; name: string; description?: string | null; status: string }>;
      }>(request, "/api/categories");

      const existingCategories = new Map(
        (categoriesResponse.categories ?? []).map((item) => [normalizeKey(item.name), item]),
      );

      const summary = await processRows({
        rows,
        duplicateHandling,
        errorHandling,
        onRow: async ({ row, duplicateHandling: duplicateMode }) => {
          const name =
            normalizeText(findValue(row, ["Main Category (English)", "name"])) ||
            normalizeText(findValue(row, ["মেইন ক্যাটেগরি (বাংলা)", "category"])) ||
            "";
          const description = normalizeOptionalText(findValue(row, ["বিবরণ", "description"]));
          const status = normalizeText(findValue(row, ["status"])) || "ACTIVE";

          if (!name) {
            throw new Error("Category name is required.");
          }

          const existing = existingCategories.get(normalizeKey(name));

          if (existing) {
            if (duplicateMode === "SKIP_DUPLICATE") {
              return "skipped";
            }

            if (duplicateMode === "STOP_IMPORT") {
              throw new Error(`Category "${name}" already exists.`);
            }

            const update = await backendRequest(request, `/api/categories/${existing.id}`, {
              method: "PATCH",
              body: { name, description, status },
            });

            if (!update.ok) {
              throw new Error(update.body.message ?? `Failed to update category "${name}".`);
            }

            return "updated";
          }

          const created = await backendRequest(request, "/api/categories", {
            method: "POST",
            body: { name, description, status },
          });

          if (!created.ok) {
            throw new Error(created.body.message ?? `Failed to create category "${name}".`);
          }

          return "created";
        },
      });

      return buildImportSuccessResponse({
        request,
        fileName: file.name,
        moduleLabel: "Product Category",
        duplicateHandling,
        errorHandling,
        notes,
        summary,
      });
    }

    if (module === "brand") {
      const brandsResponse = await fetchCollection<{
        brands?: Array<{ id: string; name: string; description?: string | null; status: string }>;
      }>(request, "/api/brands");

      const existingBrands = new Map((brandsResponse.brands ?? []).map((item) => [normalizeKey(item.name), item]));

      const summary = await processRows({
        rows,
        duplicateHandling,
        errorHandling,
        onRow: async ({ row, duplicateHandling: duplicateMode }) => {
          const name = normalizeText(findValue(row, ["name", "brand name"]));
          const description = normalizeOptionalText(findValue(row, ["description"]));
          const logoUrl = normalizeOptionalText(findValue(row, ["logoUrl", "logo url"]));
          const status = normalizeText(findValue(row, ["status"])) || "ACTIVE";

          if (!name) {
            throw new Error("Brand name is required.");
          }

          const existing = existingBrands.get(normalizeKey(name));

          if (existing) {
            if (duplicateMode === "STOP_IMPORT") {
              throw new Error(`Brand "${name}" already exists.`);
            }

            return "skipped";
          }

          const created = await backendRequest(request, "/api/brands", {
            method: "POST",
            body: { name, description, logoUrl, status },
          });

          if (!created.ok) {
            throw new Error(created.body.message ?? `Failed to create brand "${name}".`);
          }

          return "created";
        },
      });

      return buildImportSuccessResponse({
        request,
        fileName: file.name,
        moduleLabel: "Brand",
        duplicateHandling,
        errorHandling,
        notes,
        summary,
      });
    }

    if (module === "unit") {
      const unitsResponse = await fetchCollection<{
        units?: Array<{ id: string; name: string; shortName: string }>;
      }>(request, "/api/units");

      const existingUnits = new Map(
        (unitsResponse.units ?? []).flatMap((item) => [
          [normalizeKey(item.name), item],
          [normalizeKey(item.shortName), item],
        ]),
      );

      const summary = await processRows({
        rows,
        duplicateHandling,
        errorHandling,
        onRow: async ({ row, duplicateHandling: duplicateMode }) => {
          const name = normalizeText(findValue(row, ["name", "unit name"]));
          const shortName = normalizeText(findValue(row, ["shortName", "short name"]));
          const type = normalizeText(findValue(row, ["type"])).toUpperCase() || "COUNTABLE";
          const description = normalizeOptionalText(findValue(row, ["description"]));
          const status = normalizeText(findValue(row, ["status"])).toUpperCase() || "ACTIVE";

          if (!name || !shortName) {
            throw new Error("Unit name and short name are required.");
          }

          const existing = existingUnits.get(normalizeKey(name)) ?? existingUnits.get(normalizeKey(shortName));

          if (existing) {
            if (duplicateMode === "STOP_IMPORT") {
              throw new Error(`Unit "${name}" already exists.`);
            }

            return "skipped";
          }

          const created = await backendRequest(request, "/api/units", {
            method: "POST",
            body: { name, shortName, type, description, status },
          });

          if (!created.ok) {
            throw new Error(created.body.message ?? `Failed to create unit "${name}".`);
          }

          return "created";
        },
      });

      return buildImportSuccessResponse({
        request,
        fileName: file.name,
        moduleLabel: "Unit",
        duplicateHandling,
        errorHandling,
        notes,
        summary,
      });
    }

    if (module === "supplier-data") {
      const suppliersResponse = await fetchCollection<{
        suppliers?: Array<{ id: string; supplierCode: string; name: string }>;
      }>(request, "/api/suppliers");

      const existingSuppliers = new Map(
        (suppliersResponse.suppliers ?? []).flatMap((item) => [
          [normalizeKey(item.supplierCode), item],
          [normalizeKey(item.name), item],
        ]),
      );

      const summary = await processRows({
        rows,
        duplicateHandling,
        errorHandling,
        onRow: async ({ row, duplicateHandling: duplicateMode }) => {
          const supplierCode = normalizeText(findValue(row, ["supplierCode", "supplier code"]));
          const name = normalizeText(findValue(row, ["name", "companyOrPersonName", "company or person name"]));
          const mobile = normalizeOptionalText(findValue(row, ["mobile", "phone"]));
          const email = normalizeOptionalText(findValue(row, ["email"]));
          const address = normalizeOptionalText(findValue(row, ["address"]));
          const contactPerson = normalizeOptionalText(findValue(row, ["contactPerson", "contact person"]));
          const contactPersonMobile = normalizeOptionalText(findValue(row, ["contactPersonMobile", "contact person mobile"]));
          const notesValue = normalizeOptionalText(findValue(row, ["notes", "shortNote", "short note"])) || notes;
          const status = normalizeText(findValue(row, ["status"])).toUpperCase() || "ACTIVE";

          if (!supplierCode || !name) {
            throw new Error("Supplier code and supplier name are required.");
          }

          const existing =
            existingSuppliers.get(normalizeKey(supplierCode)) ?? existingSuppliers.get(normalizeKey(name));

          if (existing) {
            if (duplicateMode === "SKIP_DUPLICATE") {
              return "skipped";
            }

            if (duplicateMode === "STOP_IMPORT") {
              throw new Error(`Supplier "${name}" already exists.`);
            }

            const updated = await backendRequest(request, `/api/suppliers/${existing.id}`, {
              method: "PUT",
              body: {
                supplierCode,
                name,
                mobile,
                email,
                address,
                contactPerson,
                contactPersonMobile,
                notes: notesValue,
                status,
              },
            });

            if (!updated.ok) {
              throw new Error(updated.body.message ?? `Failed to update supplier "${name}".`);
            }

            return "updated";
          }

          const created = await backendRequest(request, "/api/suppliers", {
            method: "POST",
            body: {
              supplierCode,
              name,
              mobile,
              email,
              address,
              contactPerson,
              contactPersonMobile,
              notes: notesValue,
              status,
            },
          });

          if (!created.ok) {
            throw new Error(created.body.message ?? `Failed to create supplier "${name}".`);
          }

          return "created";
        },
      });

      return buildImportSuccessResponse({
        request,
        fileName: file.name,
        moduleLabel: "Supplier Data",
        duplicateHandling,
        errorHandling,
        notes,
        summary,
      });
    }

    if (module === "product-template") {
      const templatesResponse = await fetchCollection<{
        templates?: Array<{ id: string; code: string; name: string }>;
      }>(request, "/api/product-templates");

      const existingTemplates = new Map(
        (templatesResponse.templates ?? []).flatMap((item) => [
          [normalizeKey(item.code), item],
          [normalizeKey(item.name), item],
        ]),
      );

      const summary = await processRows({
        rows,
        duplicateHandling,
        errorHandling,
        onRow: async ({ row, duplicateHandling: duplicateMode }) => {
          const code = normalizeText(findValue(row, ["code", "template code"]));
          const name = normalizeText(findValue(row, ["name", "template name"]));
          const description = normalizeOptionalText(findValue(row, ["description"])) || notes;
          const status = normalizeText(findValue(row, ["status"])).toUpperCase() || "ACTIVE";

          if (!code || !name) {
            throw new Error("Template code and template name are required.");
          }

          const existing =
            existingTemplates.get(normalizeKey(code)) ?? existingTemplates.get(normalizeKey(name));

          if (existing) {
            if (duplicateMode === "SKIP_DUPLICATE") {
              return "skipped";
            }

            if (duplicateMode === "STOP_IMPORT") {
              throw new Error(`Template "${name}" already exists.`);
            }

            const updated = await backendRequest(request, `/api/product-templates/${existing.id}`, {
              method: "PUT",
              body: { code, name, description, status },
            });

            if (!updated.ok) {
              throw new Error(updated.body.message ?? `Failed to update template "${name}".`);
            }

            return "updated";
          }

          const created = await backendRequest(request, "/api/product-templates", {
            method: "POST",
            body: { code, name, description, status },
          });

          if (!created.ok) {
            throw new Error(created.body.message ?? `Failed to create template "${name}".`);
          }

          return "created";
        },
      });

      return buildImportSuccessResponse({
        request,
        fileName: file.name,
        moduleLabel: "Product Template",
        duplicateHandling,
        errorHandling,
        notes,
        summary,
      });
    }

    if (module === "product-catalog" || module === "barcode-database") {
      const productsResponse = await fetchCollection<ProductFiltersPayload>(request, "/api/products");
      const categories = productsResponse.filters?.categories ?? [];
      const brands = productsResponse.filters?.brands ?? [];
      const units = productsResponse.filters?.units ?? [];
      const products = productsResponse.products ?? [];

      const categoryMap = new Map(categories.map((item) => [normalizeKey(item.name), item.id]));
      const brandMap = new Map(brands.map((item) => [normalizeKey(item.name), item.id]));
      const unitMap = new Map(
        units.flatMap((item) => [
          [normalizeKey(item.name), item.id],
          [normalizeKey(item.shortName), item.id],
        ]),
      );
      const productMap = new Map(products.map((item) => [normalizeKey(item.sku), item]));

      const summary = await processRows({
        rows,
        duplicateHandling,
        errorHandling,
        onRow: async ({ row, duplicateHandling: duplicateMode }) => {
          const sku = normalizeText(findValue(row, ["sku", "productSku", "product sku"]));
          const existing = productMap.get(normalizeKey(sku));

          if (module === "barcode-database") {
            const barcode = normalizeText(findValue(row, ["barcode"]));

            if (!sku || !barcode) {
              throw new Error("Product SKU and barcode are required.");
            }

            if (!existing) {
              throw new Error(`Product with SKU "${sku}" was not found.`);
            }

            const updated = await backendRequest(request, `/api/products/${existing.id}`, {
              method: "PUT",
              body: {
                name: existing.name,
                sku: existing.sku,
                price: existing.price,
                barcode,
                suggestedPrice: existing.suggestedPrice,
                categoryId: existing.categoryId,
                brandId: existing.brandId,
                unitId: existing.unitId,
                packageSize: normalizeOptionalText(findValue(row, [
                  "packageSize",
                  "packSize",
                  "pack size",
                  "package size",
                ])) ?? existing.packageSize,
                description: existing.note,
                pictureUrl: existing.pictureUrl,
              },
            });

            if (!updated.ok) {
              throw new Error(updated.body.message ?? `Failed to update barcode for SKU "${sku}".`);
            }

            return "updated";
          }

          const name = normalizeText(findValue(row, ["name", "productName", "product name"]));
          const barcode = normalizeOptionalText(findValue(row, ["barcode"]));
          const price = normalizeNumber(findValue(row, ["price"]));
          const suggestedPrice = normalizeNumber(findValue(row, [
            "suggestedPrice",
            "suggested price",
            "suggested selling price",
          ]));
          const categoryName = normalizeText(findValue(row, ["category"]));
          const brandName = normalizeText(findValue(row, ["brand"]));
          const unitName = normalizeText(findValue(row, ["unit"]));
          const packageSize = normalizeOptionalText(findValue(row, [
            "packageSize",
            "pack size",
            "packSize",
            "package size",
          ]));
          const description = normalizeOptionalText(findValue(row, [
            "description",
            "additional information",
            "additionalInformation",
          ]));
          const pictureUrl = normalizeOptionalText(findValue(row, [
            "pictureUrl",
            "picture url",
            "image url",
            "imageUrl",
            "logo url",
            "logoUrl",
          ]));
          const categoryId = categoryName ? categoryMap.get(normalizeKey(categoryName)) ?? null : null;
          const brandId = brandName ? brandMap.get(normalizeKey(brandName)) ?? null : null;
          const unitId = unitName ? unitMap.get(normalizeKey(unitName)) ?? null : null;

          if (!name || !sku) {
            throw new Error("Product name and SKU are required.");
          }

          if (categoryName && !categoryId) {
            throw new Error(`Category "${categoryName}" was not found.`);
          }

          if (brandName && !brandId) {
            throw new Error(`Brand "${brandName}" was not found.`);
          }

          if (unitName && !unitId) {
            throw new Error(`Unit "${unitName}" was not found.`);
          }

          if (existing) {
            if (duplicateMode === "SKIP_DUPLICATE") {
              return "skipped";
            }

            if (duplicateMode === "STOP_IMPORT") {
              throw new Error(`Product with SKU "${sku}" already exists.`);
            }

            const updated = await backendRequest(request, `/api/products/${existing.id}`, {
              method: "PUT",
              body: {
                name,
                sku,
                price,
                barcode,
                suggestedPrice,
                categoryId,
                brandId,
                unitId,
                packageSize,
                description,
                pictureUrl: pictureUrl ?? existing.pictureUrl,
              },
            });

            if (!updated.ok) {
              throw new Error(updated.body.message ?? `Failed to update product "${name}".`);
            }

            return "updated";
          }

          const created = await backendRequest(request, "/api/products", {
            method: "POST",
            body: {
              name,
              sku,
              price,
              barcode,
              suggestedPrice,
              categoryId,
              brandId,
              unitId,
              packageSize,
              description,
              pictureUrl,
            },
          });

          if (!created.ok) {
            throw new Error(created.body.message ?? `Failed to create product "${name}".`);
          }

          return "created";
        },
      });

      return buildImportSuccessResponse({
        request,
        fileName: file.name,
        moduleLabel: module === "product-catalog" ? "Product Catalog" : "Barcode Database",
        duplicateHandling,
        errorHandling,
        notes,
        summary,
      });
    }

    if (module === "bank-account" || module === "money-box") {
      const shopsResponse = await fetchCollection<{
        shops?: Array<{ id: string; shopCode?: string | null; shopName: string }>;
      }>(request, "/api/shops");
      const shopMap = new Map(
        (shopsResponse.shops ?? []).flatMap((item) => [
          [normalizeKey(item.id), item.id],
          [normalizeKey(item.shopName), item.id],
          [normalizeKey(item.shopCode), item.id],
        ]),
      );

      if (module === "bank-account") {
        const existingResponse = await fetchCollection<{
          bankAccounts?: Array<{
            id: string;
            bankName: string;
            accountNumber: string;
          }>;
        }>(request, "/api/bank-accounts");

        const existingAccounts = new Map(
          (existingResponse.bankAccounts ?? []).map((item) => [
            normalizeKey(`${item.bankName}::${item.accountNumber}`),
            item,
          ]),
        );

        const summary = await processRows({
          rows,
          duplicateHandling,
          errorHandling,
          onRow: async ({ row, duplicateHandling: duplicateMode }) => {
            const shopIdentifier = normalizeText(findValue(row, ["shopId", "shopCode", "shopName", "shop code", "shop name"]));
            const shopId = shopMap.get(normalizeKey(shopIdentifier)) ?? null;
            const accountName = normalizeText(findValue(row, ["accountName", "account name"]));
            const bankName = normalizeText(findValue(row, ["bankName", "bank name"]));
            const branchName = normalizeOptionalText(findValue(row, ["branchName", "branch name"]));
            const accountNumber = normalizeText(findValue(row, ["accountNumber", "account number"]));
            const accountType = normalizeText(findValue(row, ["accountType", "account type"])).toUpperCase() || "CURRENT";
            const openingBalance = normalizeNumber(findValue(row, ["openingBalance", "opening balance"])) ?? 0;
            const currency = normalizeText(findValue(row, ["currency"])).toUpperCase() || "BDT";
            const status = normalizeText(findValue(row, ["status"])).toUpperCase() || "ACTIVE";
            const isDefault = normalizeKey(findValue(row, ["isDefault", "is default"])) === "true";
            const accountNotes = normalizeOptionalText(findValue(row, ["notes"]));

            if (!shopId || !accountName || !bankName || !accountNumber) {
              throw new Error("Shop, account name, bank name, and account number are required.");
            }

            const existing = existingAccounts.get(normalizeKey(`${bankName}::${accountNumber}`));

            if (existing) {
              if (duplicateMode === "SKIP_DUPLICATE") {
                return "skipped";
              }

              if (duplicateMode === "STOP_IMPORT") {
                throw new Error(`Bank account "${bankName} / ${accountNumber}" already exists.`);
              }

              const updated = await backendRequest(request, `/api/bank-accounts/${existing.id}`, {
                method: "PUT",
                body: {
                  shopId,
                  accountName,
                  bankName,
                  branchName,
                  accountNumber,
                  accountType,
                  openingBalance,
                  currency,
                  status,
                  isDefault,
                  notes: accountNotes,
                },
              });

              if (!updated.ok) {
                throw new Error(updated.body.message ?? `Failed to update bank account "${accountName}".`);
              }

              return "updated";
            }

            const created = await backendRequest(request, "/api/bank-accounts", {
              method: "POST",
              body: {
                shopId,
                accountName,
                bankName,
                branchName,
                accountNumber,
                accountType,
                openingBalance,
                currency,
                status,
                isDefault,
                notes: accountNotes,
              },
            });

            if (!created.ok) {
              throw new Error(created.body.message ?? `Failed to create bank account "${accountName}".`);
            }

            return "created";
          },
        });

        return buildImportSuccessResponse({
          request,
          fileName: file.name,
          moduleLabel: "Bank Account",
          duplicateHandling,
          errorHandling,
          notes,
          summary,
        });
      }

      const existingResponse = await fetchCollection<{
        moneyBoxes?: Array<{
          id: string;
          code: string;
        }>;
      }>(request, "/api/money-boxes");

      const existingMoneyBoxes = new Map(
        (existingResponse.moneyBoxes ?? []).map((item) => [normalizeKey(item.code), item]),
      );

      const summary = await processRows({
        rows,
        duplicateHandling,
        errorHandling,
        onRow: async ({ row, duplicateHandling: duplicateMode }) => {
          const shopIdentifier = normalizeText(findValue(row, ["shopId", "shopCode", "shopName", "shop code", "shop name"]));
          const shopId = shopMap.get(normalizeKey(shopIdentifier)) ?? null;
          const boxName = normalizeText(findValue(row, ["boxName", "box name", "name"]));
          const code = normalizeText(findValue(row, ["code"]));
          const type = normalizeText(findValue(row, ["type"])).toUpperCase() || "CASH";
          const openingBalance = normalizeNumber(findValue(row, ["openingBalance", "opening balance"])) ?? 0;
          const details = normalizeOptionalText(findValue(row, ["details", "description"]));
          const status = normalizeText(findValue(row, ["status"])).toUpperCase() || "ACTIVE";

          if (!shopId || !boxName || !code) {
            throw new Error("Shop, money box name, and code are required.");
          }

          const existing = existingMoneyBoxes.get(normalizeKey(code));

          if (existing) {
            if (duplicateMode === "SKIP_DUPLICATE") {
              return "skipped";
            }

            if (duplicateMode === "STOP_IMPORT") {
              throw new Error(`Money box code "${code}" already exists.`);
            }

            const updated = await backendRequest(request, `/api/money-boxes/${existing.id}`, {
              method: "PUT",
              body: {
                shopId,
                boxName,
                code,
                type,
                openingBalance,
                details,
                status,
              },
            });

            if (!updated.ok) {
              throw new Error(updated.body.message ?? `Failed to update money box "${boxName}".`);
            }

            return "updated";
          }

          const created = await backendRequest(request, "/api/money-boxes", {
            method: "POST",
            body: {
              shopId,
              boxName,
              code,
              type,
              openingBalance,
              details,
              status,
            },
          });

          if (!created.ok) {
            throw new Error(created.body.message ?? `Failed to create money box "${boxName}".`);
          }

          return "created";
        },
      });

      return buildImportSuccessResponse({
        request,
        fileName: file.name,
        moduleLabel: "Money Box",
        duplicateHandling,
        errorHandling,
        notes,
        summary,
      });
    }

    return NextResponse.json({ message: "Selected module is not supported for import yet." }, { status: 400 });
  } catch (error) {
    console.error("Bulk import failed.", error);

    return NextResponse.json(
      {
        message: error instanceof Error ? error.message : "Unable to process the import right now.",
      },
      { status: 500 },
    );
  }
}
