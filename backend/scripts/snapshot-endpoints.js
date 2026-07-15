const fs = require('fs');
const path = require('path');

const BASE_URL = process.env.SNAPSHOT_BASE_URL || 'http://localhost:4000';
const OUT_DIR = process.argv[2] || path.resolve(__dirname, '..', '.snapshots', 'baseline');

const LOGIN_IDENTITY = 'superadmin@dokanerp.local';
const LOGIN_PASSWORD = '12345678';

const GET_ENDPOINTS = [
  '/web/api/categories',
  '/web/api/units',
  '/web/api/brands',
  '/web/api/settings/store',
  '/web/api/settings/inventory',
];

function extractCookie(setCookieHeaders, name) {
  for (const header of setCookieHeaders || []) {
    const match = header.match(new RegExp(`${name}=([^;]+)`));
    if (match) return `${name}=${match[1]}`;
  }
  return null;
}

async function main() {
  fs.mkdirSync(OUT_DIR, { recursive: true });

  const loginRes = await fetch(`${BASE_URL}/web/api/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ identity: LOGIN_IDENTITY, password: LOGIN_PASSWORD }),
  });

  if (!loginRes.ok) {
    throw new Error(`Login failed with status ${loginRes.status}: ${await loginRes.text()}`);
  }

  const setCookies = loginRes.headers.getSetCookie ? loginRes.headers.getSetCookie() : [];
  const accessCookie = extractCookie(setCookies, 'mudi_access_token');

  if (!accessCookie) {
    throw new Error('Could not extract access token cookie from login response.');
  }

  const results = {};
  for (const endpoint of GET_ENDPOINTS) {
    const res = await fetch(`${BASE_URL}${endpoint}`, {
      headers: { Cookie: accessCookie },
    });
    const body = await res.text();
    let parsed;
    try {
      parsed = JSON.parse(body);
    } catch {
      parsed = body;
    }
    results[endpoint] = { status: res.status, body: parsed };

    const fileName = endpoint.replace(/\//g, '_') + '.json';
    fs.writeFileSync(path.join(OUT_DIR, fileName), JSON.stringify({ status: res.status, body: parsed }, null, 2));
    console.log(`Snapshotted ${endpoint} -> ${res.status}`);
  }

  console.log(`Wrote ${GET_ENDPOINTS.length} snapshots to ${OUT_DIR}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
