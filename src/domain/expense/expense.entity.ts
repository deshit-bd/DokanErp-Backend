export type Expense = {
  id: string;
  shopId: string;
  category: string;
  amount: number;
  expenseDate: Date;
  description: string | null;
  paymentMethod: string | null;
  moneyBoxId: string | null;
  bankAccountId: string | null;
  status: string;
  createdAt: Date;
  updatedAt: Date;
};

export type ExpenseSummaryRange = "today" | "week" | "month" | "year" | "all";

export function toMoney(value: unknown): number {
  return Number(value ?? 0);
}

export function getExpenseRangeBounds(range: ExpenseSummaryRange, source = new Date()): { start: Date; end: Date } {
  const now = new Date(source);
  const start = new Date(now);
  const end = new Date(now);

  if (range === "today") {
    start.setHours(0, 0, 0, 0);
    end.setHours(23, 59, 59, 999);
    return { start, end };
  }

  if (range === "week") {
    start.setDate(now.getDate() - 6);
    start.setHours(0, 0, 0, 0);
    end.setHours(23, 59, 59, 999);
    return { start, end };
  }

  if (range === "year") {
    start.setMonth(0, 1);
    start.setHours(0, 0, 0, 0);
    end.setMonth(11, 31);
    end.setHours(23, 59, 59, 999);
    return { start, end };
  }

  if (range === "all") {
    return { start: new Date(0), end: new Date(now.getFullYear() + 100, 11, 31, 23, 59, 59, 999) };
  }

  start.setDate(1);
  start.setHours(0, 0, 0, 0);
  end.setMonth(now.getMonth() + 1, 0);
  end.setHours(23, 59, 59, 999);
  return { start, end };
}

export function getPreviousExpenseRangeBounds(range: ExpenseSummaryRange, start: Date, end: Date): { start: Date; end: Date } {
  if (range === "all") {
    return { start: new Date(0), end: new Date(0) };
  }
  const rangeMs = end.getTime() - start.getTime() + 1;
  const previousEnd = new Date(start.getTime() - 1);
  const previousStart = new Date(previousEnd.getTime() - rangeMs + 1);
  return { start: previousStart, end: previousEnd };
}

export function getExpenseTrendBuckets(range: ExpenseSummaryRange, start: Date): { key: string; label: string }[] {
  if (range === "today") {
    return [
      { key: "08", label: "8am" },
      { key: "10", label: "10am" },
      { key: "12", label: "12pm" },
      { key: "14", label: "2pm" },
      { key: "16", label: "4pm" },
      { key: "18", label: "6pm" },
      { key: "20", label: "8pm" },
    ];
  }

  if (range === "week") {
    const dayNames = ["রবি", "সোম", "মঙ্গল", "বুধ", "বৃহ", "শুক্র", "শনি"];
    return Array.from({ length: 7 }, (_, index) => {
      const date = new Date(start);
      date.setDate(start.getDate() + index);
      return { key: date.toISOString().slice(0, 10), label: dayNames[date.getDay()] };
    });
  }

  if (range === "year" || range === "all") {
    const monthNames = ["জানু", "ফেব", "মার্চ", "এপ্রি", "মে", "জুন", "জুল", "আগ", "সেপ", "অক্ট", "নভে", "ডিসে"];
    return Array.from({ length: 12 }, (_, index) => ({ key: String(index), label: monthNames[index] }));
  }

  const lastDay = new Date(start.getFullYear(), start.getMonth() + 1, 0).getDate();
  const bucketDays = Array.from(new Set([1, 5, 10, 15, 20, 25, lastDay])).sort((a, b) => a - b);
  return bucketDays.map((day) => ({ key: String(day), label: `${day}` }));
}

export function getExpenseTrendKey(range: ExpenseSummaryRange, date: Date): string {
  if (range === "today") {
    if (date.getHours() < 10) return "08";
    if (date.getHours() < 12) return "10";
    if (date.getHours() < 14) return "12";
    if (date.getHours() < 16) return "14";
    if (date.getHours() < 18) return "16";
    if (date.getHours() < 20) return "18";
    return "20";
  }

  if (range === "week") {
    return date.toISOString().slice(0, 10);
  }

  if (range === "year" || range === "all") {
    return String(date.getMonth());
  }

  const day = date.getDate();
  if (day <= 1) return "1";
  if (day <= 5) return "5";
  if (day <= 10) return "10";
  if (day <= 15) return "15";
  if (day <= 20) return "20";
  if (day <= 25) return "25";
  return String(new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate());
}
