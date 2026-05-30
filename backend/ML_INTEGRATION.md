# Backend ↔ ML integration (ARGUS-KE)

How the NestJS backend connects to the ML face-recognition service and the
Supabase Postgres database. **This flow has been verified end-to-end against a
local Postgres 16 + pgvector instance (functionally identical to Supabase).**

## Architecture

```
Flutter app
   │ HTTP
   ▼
NestJS backend (:3000) ──MlService (REST)──▶ ML FastAPI (:8000)
   │                                              │
   └───────────── Supabase Postgres ◀─────────────┘
        Prisma tables: children, reporters, police_abstracts,
                       cases, sightings, amber_alerts
        ML table (pgvector): argus_faces   ← written by the ML service
```

- **Service layer:** `src/ml/ml.service.ts` (`MlService`) calls the ML API.
  - On `PATCH /cases/:id/status` → `APPROVED`, `CasesService` calls `ml.enrollCase()`
    (downloads `child.photo_url`, forwards to `POST /api/v1/cases/enroll`).
  - On `POST /sightings` without a `case_id`, `SightingsService` calls
    `ml.matchByPhotoUrl()` (`POST /api/v1/match`) and auto-links the best match.
  - Both calls are best-effort: ML downtime never blocks the request.
- **Data layer:** the ML service's `PgVectorStore` writes `argus_faces` into the
  **same** database, when `ARGUS_DATABASE_URL` == the backend `DATABASE_URL`.

## ⚠️ Gotcha: `prisma db push` DROPS `argus_faces`

`argus_faces` is owned by the ML service (not in `schema.prisma`). `prisma db push`
makes the DB match the Prisma schema exactly, so it **deletes `argus_faces`**.

**Correct order:**
1. `npx prisma db push`  (or `prisma migrate deploy`)
2. THEN apply `../ml/app/db/schema.sql` (creates `argus_faces` + pgvector index)

Re-apply step 2 after any future `db push`. (`prisma migrate deploy` is additive
and safe, so prefer migrations once you have them.)

## Setup (local Postgres + pgvector)

The DB is a single Postgres-with-pgvector instance shared by the backend (Prisma
tables) and the ML service (`argus_faces`). It runs via `backend/docker-compose.yml`
(image built from `backend/database/Dockerfile` = `pgvector/pgvector:pg16`),
exposed on host port **1223**.

1. **Start the database**
   ```
   cd backend
   docker compose up -d --build db        # Postgres + pgvector on localhost:1223
   ```
2. **backend/.env**
   ```
   DATABASE_URL=postgresql://argus:argus@localhost:1223/argus?schema=public
   ML_SERVICE_URL=http://localhost:8000
   ```
3. **ml/.env** (same DB so vectors persist alongside the app data)
   ```
   ARGUS_DATABASE_URL=postgresql://argus:argus@localhost:1223/argus
   ARGUS_STORE_BACKEND=auto      # uses pgvector when ARGUS_DATABASE_URL is set
   ```
4. **Create tables** (order matters — see gotcha above)
   ```
   cd backend && npx prisma db push
   docker exec -i backend-db-1 psql -U argus -d argus < ../ml/app/db/schema.sql
   ```
5. **Run** (two terminals)
   ```
   cd ml      && .venv\Scripts\python -m uvicorn app.main:app --port 8000
   cd backend && npm run start:dev
   ```

> To use a managed Postgres instead (e.g. Supabase/Neon/RDS), just set
> `DATABASE_URL` / `ARGUS_DATABASE_URL` to that server's connection string
> (managed Postgres usually needs `?sslmode=require`). No code changes.

## Verified flow (what the e2e test exercised)

1. `POST /cases` → case `PENDING`.
2. `PATCH /cases/:id/status {status:"APPROVED"}` → ML enrolled the child's face;
   a `vector(512)` row appeared in `argus_faces` with the case_id + OB number.
3. `POST /sightings` with the same photo → auto-linked to the case (similarity 1.0).
4. `POST /sightings` with a different photo → no match, `case_id` left NULL.

> Note: the e2e test used the deterministic `stub` ML engine so matches are
> reproducible. With `ARGUS_ML_BACKEND=gemini`, matching is description-based
> (a look-alike shortlist for moderators), not biometric identity — tune
> `ARGUS_MATCH_THRESHOLD` accordingly.
