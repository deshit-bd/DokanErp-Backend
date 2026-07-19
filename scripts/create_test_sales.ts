async function main() {
  const identity = "01762161370"; // Sakib
  const password = "1234";
  let token = "";
  let shopId = "";

  try {
    const res = await fetch("https://server.dokan.erp.sbmoffice.net/app/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ identity, password, appType: "MOBILE" })
    });
    const data: any = await res.json();
    if (res.ok) {
      token = data.access_token || data.tokens?.access_token || "";
      shopId = data.user?.shop?.id || "";
      console.log(`Logged in successfully. Shop ID: ${shopId}`);
    } else {
      console.error("Login failed:", data);
      return;
    }
  } catch (err: any) {
    console.error("Login request failed:", err.message);
    return;
  }

  const salesToCreate = [
    {
      // tasmim
      customerId: "cmrfwvysr002j0trwbjifkm3a",
      name: "tasmim",
      qty: 5, // 5 * 5 = 25
      price: 5
    },
    {
      // ami
      customerId: "cmrfym21r00340trwibym3lng",
      name: "ami",
      qty: 10, // 10 * 5 = 50
      price: 5
    }
  ];

  for (const target of salesToCreate) {
    try {
      console.log(`Recording credit sale of ${target.qty * target.price} Taka to ${target.name}...`);
      const res = await fetch("https://server.dokan.erp.sbmoffice.net/app/api/customers/sales", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          customerId: target.customerId,
          paidAmount: 0,
          paymentMethod: "due",
          items: [
            {
              masterProductId: "cmrfw30en000g0trwvqumit4f", // product "sajib"
              qty: target.qty,
              salePrice: target.price
            }
          ]
        })
      });
      const data = await res.json();
      console.log(`Response for ${target.name}:`, res.status, data);
    } catch (err: any) {
      console.error(`Failed for ${target.name}:`, err.message);
    }
  }
}

main();
