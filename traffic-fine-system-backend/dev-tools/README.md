Dev tools for local testing

Files:
- `test-apis.js` — Smoke test script that logs in as `admin` and calls main API endpoints.
- `create-sample-fine.js` — Creates a sample fine with `referenceNumber: REF123` for testing payments.

Usage:
1. Ensure the backend is running (`npm run start:dev`).
2. From the project root run:

```powershell
node dev-tools/create-sample-fine.js
node dev-tools/test-apis.js
```

Notes:
- These scripts are for local development only. Do not commit real credentials into source.
- If you change the admin password, update `dev-tools/test-apis.js` accordingly.
