import { NextResponse } from "next/server";
import * as XLSX from "xlsx";

export const runtime = "nodejs";

function getBackendBaseUrl() {
  return process.env.BACKEND_URL || process.env.API_BASE_URL || "http://localhost:4000";
}

function buildBackendUrl(pathname: string) {
  return new URL(`/web${pathname}`, getBackendBaseUrl()).toString();
}

type WorkbookCategoryRow = {
  "Main Category (English)"?: string;
  "মেইন ক্যাটেগরি (বাংলা)"?: string;
  "বিবরণ"?: string;
};

export async function POST(request: Request) {
  try {
    const formData = await request.formData();
    const file = formData.get("file");

    if (!(file instanceof File)) {
      return NextResponse.json({ message: "Please choose an Excel file." }, { status: 400 });
    }

    const bytes = await file.arrayBuffer();
    const workbook = XLSX.read(Buffer.from(bytes), { type: "buffer" });
    const firstSheetName = workbook.SheetNames[0];

    if (!firstSheetName) {
      return NextResponse.json({ message: "The Excel file does not contain any sheets." }, { status: 400 });
    }

    const sheet = workbook.Sheets[firstSheetName];
    const rows = XLSX.utils.sheet_to_json<WorkbookCategoryRow>(sheet, {
      defval: "",
    });

    const categories = rows
      .map((row) => {
        const name = row["Main Category (English)"]?.trim() || row["মেইন ক্যাটেগরি (বাংলা)"]?.trim() || "";
        const description = row["বিবরণ"]?.trim() || null;

        return {
          name,
          description,
          status: "ACTIVE" as const,
        };
      })
      .filter((row) => row.name.length > 0);

    if (categories.length === 0) {
      return NextResponse.json(
        { message: "No category rows were found in the first worksheet." },
        { status: 400 },
      );
    }

    const headers = new Headers(request.headers);
    headers.set("content-type", "application/json");
    headers.delete("host");
    headers.delete("content-length");

    const upstream = await fetch(buildBackendUrl("/api/categories/import"), {
      method: "POST",
      headers,
      body: JSON.stringify({ categories }),
      redirect: "manual",
    });

    return new NextResponse(await upstream.arrayBuffer(), {
      status: upstream.status,
      headers: upstream.headers,
    });
  } catch (error) {
    console.error("Failed to import categories from Excel.", error);

    return NextResponse.json({ message: "Unable to import categories right now." }, { status: 500 });
  }
}
