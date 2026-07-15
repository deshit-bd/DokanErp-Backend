import { getPurchaseReturnSummary, toPurchaseStatusLabel } from "@domain/purchase/purchase.entity";

export function toPurchaseDto(purchase: any) {
  const returns = Array.isArray(purchase.returns) ? purchase.returns : [];
  const returnSummary = getPurchaseReturnSummary(purchase);
  const isReceived = purchase.status === "APPROVED";

  const mappedItems = purchase.items.map((item: any) => {
    let returnedQty = 0;
    for (const ret of returns) {
      if (ret.status !== "REJECTED") {
        for (const retItem of ret.items || []) {
          if (retItem.purchaseItemId === item.id) {
            returnedQty += Number(retItem.quantity);
          }
        }
      }
    }
    return {
      id: item.masterProductId ?? item.id,
      productId: item.masterProductId ?? item.id,
      product_id: item.masterProductId ?? item.id,
      purchaseItemId: item.id,
      purchase_item_id: item.id,
      masterProductId: item.masterProductId,
      name: item.masterProduct?.name ?? "Unnamed product",
      product_name: item.masterProduct?.name ?? "Unnamed product",
      productName: item.masterProduct?.name ?? "Unnamed product",
      sku: item.masterProduct?.sku ?? null,
      batchNo: item.batchNo,
      expiryDate: item.expiryDate,
      quantity: Number(item.quantity),
      orderedQuantity: Number(item.quantity),
      ordered_quantity: Number(item.quantity),
      receivedQuantity: isReceived ? Number(item.quantity) : 0,
      received_quantity: isReceived ? Number(item.quantity) : 0,
      returnedQuantity: returnedQty,
      returned_quantity: returnedQty,
      purchasePrice: Number(item.purchasePrice),
      unitCost: Number(item.purchasePrice),
      unit_cost: Number(item.purchasePrice),
      totalAmount: Number(item.totalAmount),
    };
  });

  const mappedStatus = purchase.status === "APPROVED" ? "received" : purchase.status === "REJECTED" ? "cancelled" : "submitted";

  return {
    id: purchase.id,
    uuid: purchase.id,
    shopId: purchase.shopId,
    shopName: purchase.shop?.shopName,
    supplierId: purchase.supplierId,
    supplier_id: purchase.supplierId,
    supplierKey: purchase.supplierId,
    supplier_key: purchase.supplierId,
    supplierName: purchase.supplier?.name ?? null,
    supplier_name: purchase.supplier?.name ?? null,
    supplierCode: purchase.supplier?.supplierCode ?? null,
    createdByUserId: purchase.createdByUserId ?? null,
    approvedByUserId: purchase.approvedByUserId ?? null,
    invoiceNo: purchase.invoiceNo,
    reference: purchase.invoiceNo ?? purchase.id,
    purchaseDate: purchase.purchaseDate,
    createdAt: purchase.createdAt ? purchase.createdAt.getTime() : Date.now(),
    created_at: purchase.createdAt ? purchase.createdAt.getTime() : Date.now(),
    updatedAt: purchase.updatedAt ? purchase.updatedAt.getTime() : Date.now(),
    updated_at: purchase.updatedAt ? purchase.updatedAt.getTime() : Date.now(),
    status: mappedStatus,
    rawStatus: purchase.status,
    statusLabel: toPurchaseStatusLabel(purchase.status),
    subtotalAmount: Number(purchase.subtotalAmount),
    discountAmount: Number(purchase.discountAmount),
    extraChargeAmount: Number(purchase.extraChargeAmount),
    totalAmount: Number(purchase.totalAmount),
    paidAmount: Number(purchase.paidAmount),
    dueAmount: Number(purchase.dueAmount),
    paymentMethod: purchase.paymentMethod,
    paymentDetails: purchase.paymentMeta ?? null,
    invoiceFileName: purchase.invoiceFileName,
    notes: purchase.notes,
    note: purchase.notes,
    approvedAt: purchase.approvedAt,
    rejectedAt: purchase.rejectedAt,
    rejectionReason: purchase.rejectionReason,
    returnedAmount: returnSummary.returnedAmount,
    effectivePayableAmount: returnSummary.effectivePayable,
    remainingDueAmount: returnSummary.remainingDue,
    refundableAmount: returnSummary.refundableAmount,
    items: mappedItems,
    lines: mappedItems,
    returns: returns.map((entry: any) => ({
      id: entry.id,
      status: entry.status,
      refundMethod: entry.refundMethod,
      refundAmount: Number(entry.refundAmount ?? 0),
      notes: entry.notes ?? null,
      returnDate: entry.returnDate,
      items: Array.isArray(entry.items)
        ? entry.items.map((item: any) => ({
            id: item.id,
            purchaseItemId: item.purchaseItemId,
            masterProductId: item.masterProductId,
            quantity: Number(item.quantity),
            unitPrice: Number(item.unitPrice),
            totalAmount: Number(item.totalAmount),
            reason: item.reason ?? null,
          }))
        : [],
    })),
  };
}
