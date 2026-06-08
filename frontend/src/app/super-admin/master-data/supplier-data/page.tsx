"use client";

import MasterDataSubmodulePage from "../[slug]/page";

export default function SupplierDataPage() {
  return <MasterDataSubmodulePage params={Promise.resolve({ slug: "supplier-data" })} />;
}
