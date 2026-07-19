export type ReportRange = "today" | "week" | "month" | "year" | "all";
export type ReportRangeOrCustom = ReportRange | "custom";

export function parseRangeParam(value: unknown, allowAll = false): ReportRange {
  const allowed = allowAll ? ["today", "week", "month", "year", "all"] : ["today", "week", "month", "year"];
  const normalized = typeof value === "string" ? value.trim() : "month";
  return (allowed.includes(normalized) ? normalized : "month") as ReportRange;
}

export function getRangeBounds(range: ReportRange, source = new Date()): { start: Date; end: Date } {
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
    return {
      start: new Date(0),
      end: new Date(now.getFullYear() + 100, 11, 31, 23, 59, 59, 999),
    };
  }

  start.setDate(1);
  start.setHours(0, 0, 0, 0);
  end.setMonth(now.getMonth() + 1, 0);
  end.setHours(23, 59, 59, 999);
  return { start, end };
}

export function getHourlySlots() {
  return [
    { hour: "8am", sales: 0 },
    { hour: "10am", sales: 0 },
    { hour: "12pm", sales: 0 },
    { hour: "2pm", sales: 0 },
    { hour: "4pm", sales: 0 },
    { hour: "6pm", sales: 0 },
    { hour: "8pm", sales: 0 },
  ];
}

export function mapHourToSlot(hour: number): string {
  if (hour < 10) return "8am";
  if (hour < 12) return "10am";
  if (hour < 14) return "12pm";
  if (hour < 16) return "2pm";
  if (hour < 18) return "4pm";
  if (hour < 20) return "6pm";
  return "8pm";
}

export function getPreviousRangeBounds(range: ReportRangeOrCustom, start: Date, end: Date): { start: Date; end: Date } {
  if (range === "all") {
    return { start: new Date(0), end: new Date(0) };
  }
  const rangeMs = end.getTime() - start.getTime() + 1;
  const prevEnd = new Date(start.getTime() - 1);
  const prevStart = new Date(prevEnd.getTime() - rangeMs + 1);
  return { start: prevStart, end: prevEnd };
}

export function getTrendBuckets(range: ReportRange, start: Date): Array<{ key: string; label: string }> {
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
      return {
        key: date.toISOString().slice(0, 10),
        label: dayNames[date.getDay()],
      };
    });
  }

  if (range === "year" || range === "all") {
    const monthNames = ["জানু", "ফেব", "মার্চ", "এপ্রি", "মে", "জুন", "জুল", "আগ", "সেপ", "অক্ট", "নভে", "ডিসে"];
    return Array.from({ length: 12 }, (_, index) => ({
      key: String(index),
      label: monthNames[index],
    }));
  }

  const lastDay = new Date(start.getFullYear(), start.getMonth() + 1, 0).getDate();
  const bucketDays = Array.from(new Set([1, 5, 10, 15, 20, 25, lastDay])).sort((a, b) => a - b);
  return bucketDays.map((day) => ({ key: String(day), label: `${day}` }));
}

export function getTrendKey(range: ReportRange, date: Date): string {
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

export function getAgingBucketKey(daysOutstanding: number): "0_7" | "8_15" | "16_30" | "31_plus" {
  if (daysOutstanding <= 7) return "0_7";
  if (daysOutstanding <= 15) return "8_15";
  if (daysOutstanding <= 30) return "16_30";
  return "31_plus";
}

export function parseCustomDateRange(fromParam: string, toParam: string): { start: Date; end: Date } | null {
  const start = new Date(fromParam);
  const end = new Date(toParam);
  if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime()) || start > end) {
    return null;
  }
  return { start, end };
}
