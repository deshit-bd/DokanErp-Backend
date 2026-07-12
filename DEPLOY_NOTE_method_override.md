# Deploy note: enable Save/Update/Delete (method-override)

## Problem
The hosting layer in front of the API rejects **PUT / PATCH / DELETE** with an
HTML `403 Forbidden` before the request reaches Node. Only GET and POST get
through. Result: every Save / Update / Delete in the mobile & web app fails.

Verified: `GET`/`POST` → JSON from the app; `PUT`/`PATCH`/`DELETE` → HTML 403.

## Fix (already applied in code)
The apps now send every PUT/PATCH/DELETE as a **POST** carrying an
`X-HTTP-Method-Override` header. A tiny middleware in `backend/src/app.ts`
restores the real verb before routing, so all existing routes work unchanged.

Backend change (in `backend/src/app.ts`, right after `app.use(express.json())`):

```ts
// Some hosting layers in front of this API reject the verbs PUT/PATCH/DELETE
// outright. The clients therefore send those requests as POST carrying an
// `X-HTTP-Method-Override` header; restore the real verb here, before routing,
// so every existing route keeps working unchanged.
app.use((request, _response, next) => {
  const override = request.headers["x-http-method-override"];
  if (request.method === "POST" && typeof override === "string") {
    const verb = override.toUpperCase();
    if (verb === "PUT" || verb === "PATCH" || verb === "DELETE") {
      request.method = verb;
    }
  }
  next();
});
```

## To deploy
1. Apply the change above to `backend/src/app.ts` in the full backend repo.
2. Build & redeploy the backend the usual way (e.g. `npm run build` + restart /
   PM2 reload / redeploy pipeline).

## How to verify after deploy
From a shell (replace TOKEN and an id):

```
# Should now return JSON (200/4xx from the app), NOT an HTML 403 page:
curl -i -X POST \
  -H "Content-Type: application/json" \
  -H "X-HTTP-Method-Override: PATCH" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"canSell":true}' \
  https://server.dokan.erp.sbmoffice.net/app/api/staff/<STAFF_ID>/permissions
```

Then in the app: open a staff member → toggle a permission → Save → should show
"কর্মচারী আপডেট করা হয়েছে". Settings save and any delete will also work.

## Alternative (no backend change)
Ask the host to allow PUT/PATCH/DELETE on `/app/api/*` (remove the
Apache/LiteSpeed/cPanel/mod_security method restriction). Then the apps work
even without the override — though keeping the override is harmless and more
portable.
