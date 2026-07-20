import { encodeCode39 } from "./barcode-template";

type BarcodeSvgOptions = {
  barHeight?: number;
  fontSize?: number;
  gapWidth?: number;
  narrowWidth?: number;
  quietZone?: number;
  wideWidth?: number;
};

function escapeSvgText(value: string) {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

export function generateBarcodeSvg(
  value: string,
  options: BarcodeSvgOptions = {},
) {
  const {
    narrowWidth = 2,
    wideWidth = 5,
    gapWidth = 2,
    quietZone = 16,
    barHeight = 72,
    fontSize = 16,
  } = options;

  const { value: normalizedValue, patterns } = encodeCode39(value);
  const textY = quietZone + barHeight + fontSize + 6;
  let cursorX = quietZone;
  const bars: string[] = [];

  patterns.forEach((pattern, patternIndex) => {
    pattern.split("").forEach((widthCode, stripeIndex) => {
      const stripeWidth = widthCode === "w" ? wideWidth : narrowWidth;
      const isBar = stripeIndex % 2 === 0;

      if (isBar) {
        bars.push(
          `<rect x="${cursorX}" y="${quietZone}" width="${stripeWidth}" height="${barHeight}" fill="#1f2937" rx="0.4" />`,
        );
      }

      cursorX += stripeWidth;
    });

    if (patternIndex < patterns.length - 1) {
      cursorX += gapWidth;
    }
  });

  const totalWidth = cursorX + quietZone;
  const totalHeight = textY + quietZone;

  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${totalWidth}" height="${totalHeight}" viewBox="0 0 ${totalWidth} ${totalHeight}" role="img" aria-label="Barcode ${escapeSvgText(normalizedValue)}">
  <rect width="${totalWidth}" height="${totalHeight}" fill="#ffffff" rx="10" />
  ${bars.join("\n  ")}
  <text x="${totalWidth / 2}" y="${textY}" text-anchor="middle" font-family="Arial, Helvetica, sans-serif" font-size="${fontSize}" letter-spacing="2" fill="#475569">${escapeSvgText(normalizedValue)}</text>
</svg>`;
}
