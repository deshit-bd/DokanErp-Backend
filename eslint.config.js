const tseslint = require("typescript-eslint");
const boundaries = require("eslint-plugin-boundaries");

const LAYER_ELEMENTS = [
  { type: "domain", pattern: "src/domain/*" },
  { type: "application", pattern: "src/application/*" },
  { type: "adapters", pattern: "src/adapters/*" },
  { type: "infrastructure", pattern: "src/infrastructure/*" },
  { type: "legacy-routes", pattern: "src/routes/*" },
];

module.exports = tseslint.config(
  {
    // src/*.ts / src/*.js (direct children of src/, not in any subfolder) are
    // pre-existing one-off debug/check scripts (call_sales_api.ts, check_db.js,
    // debug-stock.ts, etc.) that predate this architecture and are not part of
    // the app's module graph (never imported by infrastructure/http/server.ts).
    // They are out of scope for the Clean Architecture migration; move genuine
    // one-off scripts to scripts/ instead of adding new files here.
    // scripts/** are plain CommonJS Node scripts (one-off data imports, DB
    // checks) outside the TypeScript app entirely — not subject to the
    // architecture being enforced here.
    ignores: [
      "dist/**",
      "node_modules/**",
      "scratch/**",
      ".snapshots/**",
      "src/*.ts",
      "src/*.js",
      "scripts/**",
      "eslint.config.js",
    ],
  },
  ...tseslint.configs.recommended,
  {
    files: ["src/**/*.ts"],
    plugins: { boundaries },
    settings: {
      "boundaries/elements": LAYER_ELEMENTS,
      "boundaries/ignore": ["src/**/*.d.ts"],
      "import/resolver": {
        typescript: { project: "./tsconfig.json" },
      },
    },
    rules: {
      // Layer dependency rule: each ring may only import itself or further inward.
      // legacy-routes (src/routes/*) is the pre-migration codebase; it is left
      // unrestricted here (default allow) since it is deleted module-by-module as
      // each one migrates, not refactored to comply with boundaries in place.
      "boundaries/element-types": [
        "error",
        {
          default: "disallow",
          rules: [
            { from: "domain", allow: ["domain"] },
            { from: "application", allow: ["domain", "application"] },
            // Deliberate, narrow exception: adapters (repository implementations,
            // storage adapters) may import infrastructure/prisma's client singleton
            // and infrastructure/config — this app has no DI container, so
            // repository implementations reach for the shared client directly
            // instead of receiving it injected. Do not use this to justify
            // importing unrelated infrastructure (e.g. the Express app/server).
            { from: "adapters", allow: ["domain", "application", "adapters", "infrastructure"] },
            { from: "infrastructure", allow: ["domain", "application", "adapters", "infrastructure"] },
            { from: "legacy-routes", allow: ["domain", "application", "adapters", "infrastructure", "legacy-routes"] },
          ],
        },
      ],
    },
  },
  {
    // Only adapters/persistence and infrastructure/prisma may import the raw
    // Prisma client constructor. Everything else (including the rest of
    // adapters/) takes a repository/port instead.
    files: ["src/**/*.ts"],
    ignores: ["src/adapters/persistence/**/*.ts", "src/infrastructure/prisma/**/*.ts", "src/routes/**/*.ts"],
    rules: {
      "no-restricted-imports": [
        "error",
        {
          paths: [
            {
              name: "@prisma/client",
              importNames: ["PrismaClient"],
              message:
                "Do not import the raw PrismaClient outside adapters/persistence or infrastructure/prisma. Use a repository port instead.",
            },
          ],
        },
      ],
    },
  },
  {
    files: ["src/domain/**/*.ts", "src/application/**/*.ts"],
    rules: {
      "no-restricted-imports": [
        "error",
        {
          // @prisma/client itself is NOT banned here: domain/application may
          // import its generated *enum* value types (e.g. CategoryStatus) —
          // the one documented exception (see CLAUDE.md). Only the
          // PrismaClient constructor is banned, same as the adapters-wide rule.
          paths: [
            {
              name: "@prisma/client",
              importNames: ["PrismaClient"],
              message: "domain/ and application/ must not depend on the Prisma client. Depend on a repository port instead.",
            },
          ],
          patterns: [
            {
              group: ["express", "../**/adapters/**", "../**/infrastructure/**"],
              message:
                "domain/ and application/ must not depend on express, adapters/, or infrastructure/. Depend on ports (interfaces) instead.",
            },
          ],
        },
      ],
    },
  },
  {
    files: ["src/routes/**/*.ts", "src/**/*.js"],
    rules: {
      "boundaries/element-types": "off",
      "@typescript-eslint/no-explicit-any": "off",
    },
  },
  {
    rules: {
      "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
      "@typescript-eslint/no-explicit-any": "warn",
    },
  },
);
