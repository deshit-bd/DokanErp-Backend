# Mudi ERP Frontend

Standalone Next.js frontend for the Mudi ERP platform.

## Structure

- `src`: app routes, components, clients, hooks, and services
- `scripts/prepare-next-dev.mjs`: clears `.next-dev` before dev
- `src/app/api`: thin proxy routes that forward auth and category requests to the backend API

## Commands

- `npm run dev`
- `npm run build`
- `npm run start`
