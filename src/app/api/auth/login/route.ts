import { NextResponse } from "next/server";
import { UserType } from "@prisma/client";
import { prisma } from "@/lib/prisma";

type LoginBody = {
  identity?: string;
  password?: string;
};

const redirectByUserType: Record<UserType, string> = {
  SUPER_ADMIN: "/super-admin/dashboard",
  SHOP_OWNER: "/shop/dashboard",
  STAFF: "/staff/dashboard",
  SUPPLIER: "/supplier/dashboard",
};

export async function POST(request: Request) {
  const body = (await request.json()) as LoginBody;
  const identity = body.identity?.trim();
  const password = body.password?.trim();

  if (!identity || !password) {
    return NextResponse.json(
      { message: "Email/mobile/store ID and password are required." },
      { status: 400 },
    );
  }

  const user = await prisma.user.findFirst({
    where: {
      OR: [{ email: identity }, { phone: identity }],
    },
    select: {
      id: true,
      email: true,
      phone: true,
      passwordHash: true,
      pinHash: true,
      userType: true,
      status: true,
    },
  });

  if (!user) {
    const shop = await prisma.shop.findFirst({
      where: { shopName: identity },
      include: {
        owner: {
          select: {
            id: true,
            email: true,
            phone: true,
            passwordHash: true,
            pinHash: true,
            userType: true,
            status: true,
          },
        },
      },
    });

    if (!shop?.owner) {
      return NextResponse.json({ message: "Invalid login credentials." }, { status: 401 });
    }

    const matchedPassword =
      shop.owner.passwordHash === password || shop.owner.pinHash === password;

    if (!matchedPassword) {
      return NextResponse.json({ message: "Invalid login credentials." }, { status: 401 });
    }

    return NextResponse.json({
      message: "Login successful.",
      redirectTo: redirectByUserType[shop.owner.userType],
      userType: shop.owner.userType,
    });
  }

  const matchedPassword = user.passwordHash === password || user.pinHash === password;

  if (!matchedPassword) {
    return NextResponse.json({ message: "Invalid login credentials." }, { status: 401 });
  }

  return NextResponse.json({
    message: "Login successful.",
    redirectTo: redirectByUserType[user.userType],
    userType: user.userType,
  });
}
