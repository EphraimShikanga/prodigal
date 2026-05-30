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

## Setup (NeonDB — serverless Postgres)

One Neon database is shared by the backend (Prisma tables) and the ML service
(`argus_faces` + `images`/`persons`/`face_embeddings`). Neon supports pgvector.

1. **Get the connection string:** Neon console → your project → **Connection Details**.
   - Use the **direct (unpooled)** string for `prisma db push` / migrations.
   - Keep `?sslmode=require` (Neon requires SSL).
2. **backend/.env**
   ```
   DATABASE_URL=postgresql://<user>:<password>@<endpoint>.<region>.aws.neon.tech/<db>?sslmode=require
   ML_SERVICE_URL=http://localhost:8000
   ```
3. **ml/.env** (same connection string so vectors persist alongside the app data)
   ```
   ARGUS_DATABASE_URL=postgresql://<user>:<password>@<endpoint>.<region>.aws.neon.tech/<db>?sslmode=require
   ARGUS_STORE_BACKEND=auto      # uses pgvector when ARGUS_DATABASE_URL is set
   ```
4. **Enable pgvector + create tables** (order matters — see gotcha above)
   ```
   cd backend && npx prisma db push
   # then run, in the Neon SQL editor (or via psql to the Neon URL):
   #   the contents of  ml/app/db/schema.sql         (argus_faces)
   #   the contents of  ml/app/db/images_schema.sql  (images/persons/face_embeddings)
   # both files begin with CREATE EXTENSION IF NOT EXISTS vector;
   ```
5. **Run** (two terminals)
   ```
   cd ml      && .venv\Scripts\python -m uvicorn app.main:app --port 8000
   cd backend && npm run start:dev
   ```

> Nothing in the code is Neon-specific — it's standard Postgres via psycopg
> (ML) and Prisma (backend). Any Postgres+pgvector works by changing only the
> connection string. Neon tip: the compute auto-suspends when idle, so the first
> request after a pause has a short cold-start.

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
