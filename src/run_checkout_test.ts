import { signAccessToken } from "./auth/jwt";

async function main() {
  const token = signAccessToken(
    {
      sub: "cmr0gdhs5005iw8g0cqf5tgmo",
      appType: "MOBILE",
      role: "SHOP_OWNER",
      sessionFamily: "test-family",
      shopId: "cmr0gdhu7005kw8g06c2lngfc",
    },
    "dev-only-auth-secret",
    3600
  );

  console.log("Generated Token:", token);

  const payload = {
    customer: {
      name: "Guest Customer",
      phone: ""
    },
    items: [
      {
        productId: "cmr0h6wz9007ow8g0eeb1xr8f", // valid shopProduct ID for target shop
        quantity: 1,
        salePrice: 20
      }
    ],
    paidAmount: 121,
    discountAmount: 0,
    taxAmount: 1,
    chargeAmount: 100,
    paymentMethod: "BKASH"
  };

  const url = "http://localhost:4000/app/api/customers/sales";
  try {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}`
      },
      body: JSON.stringify(payload)
    });

    console.log("Response Status:", res.status);
    const data = await res.json();
    console.log("Response JSON:", JSON.stringify(data, null, 2));
  } catch (error) {
    console.error("HTTP error:", error);
  }
}

main();
