import { signAccessToken } from '/Users/macbookair/Desktop/dokan_erp/backend/src/auth/jwt';
import { getAuthSecret } from '/Users/macbookair/Desktop/dokan_erp/backend/src/auth/session';
import http from 'http';

const secret = getAuthSecret();
const token = signAccessToken({
  sub: 'cmr0gdhs5005iw8g0cqf5tgmo',
  appType: 'MOBILE',
  role: 'SHOP_OWNER',
  shopId: 'cmr0gdhu7005kw8g06c2lngfc',
  sessionFamily: 'test-session-family'
}, secret, 3600);

const req = http.request({
  hostname: '127.0.0.1',
  port: 4000,
  path: '/app/api/customers/sales',
  method: 'GET',
  headers: {
    'Authorization': 'Bearer ' + token,
  }
}, (res) => {
  let body = '';
  res.on('data', chunk => body += chunk);
  res.on('end', () => {
    console.log('STATUS:', res.statusCode);
    if (res.statusCode === 200) {
      const data = JSON.parse(body);
      console.log('SUMMARY:', data.summary);
      console.log('SALES COUNT:', data.sales?.length);
      console.log('FIRST 5 SALES:', JSON.stringify(data.sales?.slice(0, 5), null, 2));
    } else {
      console.log('BODY:', body);
    }
  });
});

req.on('error', (err) => console.error('Error:', err.message));
req.end();
