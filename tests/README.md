# Tests included without duplicating application code

- API unit tests: `apps/api/src/**/*.spec.ts` (Jest/ts-jest).
- API isolated PostgreSQL integration tests: `apps/api/src/order/*integration.spec.ts`.
- API route E2E sample: `apps/api/test/app.e2e-spec.ts` and `apps/api/scripts/e2e.mjs`.
- Web unit tests: `apps/web/test/*.spec.ts`.
- Smoke script: `apps/api/scripts/smoke.mjs`.

The GitHub CI workflow initializes `brewlite_test` from the checked-in SQL. It does not connect to Render. `npm run test:e2e` requires a separately running **local test** API with `ENABLE_DEMO_PAYMENTS=true` and an isolated database; do not run E2E against production.

Reports/screenshots of a successful run must be captured by the group; mere presence of files is not proof that tests have passed.
