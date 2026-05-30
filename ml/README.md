# ARGUS-KE ML Service (Tafuta Mtoto)

The AI brain for a missing-persons recovery platform. A small, typed **FastAPI**
microservice that detects faces, produces **512-dim** embeddings, enrolls
verified missing-person faces, and matches a probe image against enrolled cases
— the live-camera **"Match Found"** engine.

The Supabase backend (Edge Functions / Postgres) and a Flutter app call this
service over REST.

---

## Key idea: pluggable backends

The service runs with **zero ML dependencies** out of the box and swaps in the
real model / database when you want it.

### Face engine (`ARGUS_ML_BACKEND`: `auto` | `insightface` | `stub`)

- **`stub` (`StubFaceEngine`)** — no heavy deps. Deterministic. `detect()`
  returns exactly one face covering the central 60% of the image
  (`det_score=0.99`); `embed()` returns a deterministic, L2-normalized 512-d
  embedding derived from a hash of the downscaled grayscale image. Same image
  → identical embedding; different image → different. Perfect for dev/CI/tests.
- **`insightface` (`InsightFaceEngine`)** — real recognition via
  `FaceAnalysis(name='buffalo_l')`, `prepare(ctx_id=-1, det_size=(640,640))`.
  Uses `face.normed_embedding`. `insightface` is imported lazily, so the base
  install never needs it.
- **`auto`** — tries InsightFace, falls back to the stub on any import/load
  error (logs a warning).

### Vector store (`ARGUS_STORE_BACKEND`: `auto` | `pgvector` | `memory`)

- **`memory` (`InMemoryStore`)** — in-process list with cosine-similarity
  search. Non-persistent.
- **`pgvector` (`PgVectorStore`)** — Postgres + pgvector via `psycopg`
  (imported lazily). Cosine distance `<=>`; `similarity = 1 - distance`.
- **`auto`** — pgvector when `ARGUS_DATABASE_URL` is set, else memory; falls
  back to memory on a pgvector connection error (logs a warning).

---

## Architecture

```
                 +-------------------+        REST         +------------------------+
  Flutter app -->|  Supabase Edge    |------------------->|  ARGUS-KE ML service    |
  (live camera)  |  Functions / API  |   /detect /embed   |  (this FastAPI app)     |
                 +-------------------+   /enroll /match    +-----------+------------+
                          |                                            |
                          v                                            v
                 +-------------------+                      +------------------------+
                 | Supabase Postgres |  <--- same DB --->   |  PgVectorStore         |
                 |  + pgvector       |   argus_faces table  |  (embeddings, search)  |
                 +-------------------+                      +------------------------+
```

```
app/
  config.py            Settings (pydantic-settings, ARGUS_ prefix)
  schemas.py           Pydantic request/response models
  main.py              create_app(): lifespan loads engine+store onto app.state
  api/
    deps.py            get_engine / get_store / get_settings dependencies
    routes_health.py   "/" , "/health"
    routes_faces.py    "/api/v1/faces/detect", "/embed"
    routes_cases.py    "/api/v1/cases/enroll", DELETE "/{case_id}"
    routes_match.py    "/api/v1/match", "/api/v1/match/embedding"
  services/
    imaging.py         decode_image / decode_b64_image (PIL -> RGB ndarray)
    matching.py        l2_normalize / cosine_similarity
    face_engine.py     Face, FaceEngine, StubFaceEngine, InsightFaceEngine, load_engine
    vector_store.py    FaceRecord, VectorStore, InMemoryStore, PgVectorStore, load_store
  db/
    schema.sql         CREATE EXTENSION vector + argus_faces + cosine index
```

---

## Run it

### Local (no ML deps, fully runnable)

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```

The interactive docs are at `http://localhost:8000/docs`.
Defaults use the deterministic stub engine + in-memory store, so every endpoint
works immediately.

### Tests

```bash
# tests force ARGUS_ML_BACKEND=stub and ARGUS_STORE_BACKEND=memory
pytest
```

### Docker

```bash
# build + run the service alongside Postgres/pgvector
docker compose up --build

# one-time: create the table + index in the db service
docker compose exec -T db psql -U argus -d argus < app/db/schema.sql
```

> The base image (`Dockerfile` / `requirements.txt`) ships **without** the ML
> model or DB drivers, so `docker compose` defaults the `ml` service to the stub
> engine. To run the **pgvector** store or **insightface** engine in the
> container, add `requirements-ml.txt` to the image build and set
> `ARGUS_STORE_BACKEND=pgvector` / `ARGUS_ML_BACKEND=insightface`
> (see *Enabling the real model* below).

---

## API

Base prefix: `ARGUS_API_PREFIX` (default `/api/v1`).

| Method | Path                          | Body                                   | Returns           | Description                                              |
|--------|-------------------------------|----------------------------------------|-------------------|---------------------------------------------------------|
| GET    | `/`                           | —                                      | `HealthResponse`  | Service root / health snapshot.                         |
| GET    | `/health`                     | —                                      | `HealthResponse`  | Health + config (`enrolled` = store count).             |
| POST   | `/api/v1/faces/detect`        | multipart `file`                       | `DetectResponse`  | Detect faces; filtered by `min_det_score`.              |
| POST   | `/api/v1/faces/embed`         | multipart `file`                       | `EmbedResponse`   | Detect + 512-d embeddings (all faces).                  |
| POST   | `/api/v1/cases/enroll`        | multipart **or** JSON (`image_b64`)    | `EnrollResponse`  | Enroll the highest-score face for a case.               |
| DELETE | `/api/v1/cases/{case_id}`     | —                                      | `{case_id,deleted}` | Delete all enrolled faces for a case.                 |
| POST   | `/api/v1/match`               | multipart `file` (+`top_k`,`threshold`)| `MatchResponse`   | Match probe image against enrolled cases.               |
| POST   | `/api/v1/match/embedding`     | JSON `MatchEmbeddingRequest`           | `MatchResponse`   | Match a precomputed embedding.                          |

A match is reported when cosine `similarity >= threshold` (default
`ARGUS_MATCH_THRESHOLD=0.35`), up to `top_k` (default `5`) results.

### curl examples

`/health`:

```bash
curl http://localhost:8000/health
# {"status":"ok","version":"0.1.0","model_backend":"stub","model_loaded":true,
#  "store_backend":"memory","embedding_dim":512,"enrolled":0}
```

`/faces/detect`:

```bash
curl -X POST http://localhost:8000/api/v1/faces/detect \
  -F "file=@child.jpg"
# {"count":1,"faces":[{"bbox":{"x1":...,"y1":...,"x2":...,"y2":...},
#  "det_score":0.99,"landmarks":null}]}
```

`/faces/embed`:

```bash
curl -X POST http://localhost:8000/api/v1/faces/embed \
  -F "file=@child.jpg"
# {"count":1,"embeddings":[{"bbox":{...},"det_score":0.99,
#  "embedding":[0.01, -0.04, ...]}]}   # length == 512
```

`/cases/enroll` — multipart (image upload):

```bash
curl -X POST http://localhost:8000/api/v1/cases/enroll \
  -F "file=@child.jpg" \
  -F "case_id=C1" \
  -F "ob_number=OB/1" \
  -F 'metadata={"name":"Asha","age":7}'
# {"case_id":"C1","face_id":"<uuid>","embedding_dim":512,
#  "det_score":0.99,"stored":true}
```

`/cases/enroll` — JSON (base64 image, e.g. from a Supabase Edge Function):

```bash
curl -X POST http://localhost:8000/api/v1/cases/enroll \
  -H "Content-Type: application/json" \
  -d '{"case_id":"C1","ob_number":"OB/1",
       "image_b64":"data:image/jpeg;base64,/9j/4AAQ...",
       "metadata":{"name":"Asha"}}'
```

`/match` — probe a live-camera frame against enrolled cases:

```bash
curl -X POST http://localhost:8000/api/v1/match \
  -F "file=@camera_frame.jpg" \
  -F "top_k=5" \
  -F "threshold=0.35"
# {"probe_faces":1,"best_similarity":0.98,
#  "matches":[{"case_id":"C1","face_id":"<uuid>","similarity":0.98,
#  "ob_number":"OB/1","metadata":{"name":"Asha"}}]}
```

`/match/embedding` — when the caller already has an embedding:

```bash
curl -X POST http://localhost:8000/api/v1/match/embedding \
  -H "Content-Type: application/json" \
  -d '{"embedding":[0.01, -0.04, ...], "top_k":5, "threshold":0.35}'
# {"probe_faces":1,"best_similarity":...,"matches":[...]}
```

Delete a case:

```bash
curl -X DELETE http://localhost:8000/api/v1/cases/C1
# {"case_id":"C1","deleted":1}
```

---

## Supabase + Flutter integration

**1. Provision the database.** Open the Supabase **SQL editor** and run
`app/db/schema.sql`. It enables the `vector` extension and creates the
`argus_faces` table with a cosine-distance index for fast search.

**2. Point the ML service at Supabase Postgres.** Set
`ARGUS_DATABASE_URL` to your Supabase connection string and
`ARGUS_STORE_BACKEND=pgvector` (or leave `auto`). The service then enrolls and
searches embeddings directly in the same database your backend uses:

```bash
ARGUS_DATABASE_URL=postgresql://postgres:<password>@db.<ref>.supabase.co:5432/postgres
ARGUS_STORE_BACKEND=pgvector
```

**3. Enrollment flow (verified missing-person face).** A Supabase **Edge
Function** receives a verified case photo, then calls the ML service:
- upload the bytes to `POST /api/v1/cases/enroll` (multipart), **or**
- send JSON with `image_b64` (handy from a serverless function that already has
  the base64 payload).

The response `face_id` / `case_id` can be stored alongside your case record.

**4. Live "Match Found" flow (Flutter app).** The Flutter app captures camera
frames and (directly or via an Edge Function) sends each frame to
`POST /api/v1/match`. The service detects + embeds the probe face and returns
the best matching enrolled case(s). When `best_similarity >= threshold`, surface
a **Match Found** alert with the returned `case_id` / `ob_number` / `metadata`.

> Tip: to keep heavy image bytes off the device→cloud path, the app can compute
> embeddings on a trusted backend and call `POST /api/v1/match/embedding`
> instead.

**5. CORS.** If a browser/Flutter-web client calls the service directly, set
`ARGUS_CORS_ORIGINS` to your app origins (defaults to `["*"]`).

---

## Enabling the real model

Switch from the deterministic stub to the production InsightFace model and
pgvector persistence:

```bash
pip install -r requirements-ml.txt          # insightface, onnxruntime, opencv, psycopg, pgvector
ARGUS_ML_BACKEND=insightface uvicorn app.main:app
```

To also persist embeddings in Postgres/pgvector, additionally set
`ARGUS_DATABASE_URL` and `ARGUS_STORE_BACKEND=pgvector`. For Docker, extend the
image to install `requirements-ml.txt` before flipping these env vars in
`docker-compose.yml`.

---

## Configuration reference

All settings use the `ARGUS_` env prefix (see `.env.example`).

| Variable                | Default                | Notes                                   |
|-------------------------|------------------------|-----------------------------------------|
| `ARGUS_ML_BACKEND`      | `auto`                 | `auto` / `insightface` / `stub`         |
| `ARGUS_STORE_BACKEND`   | `auto`                 | `auto` / `pgvector` / `memory`          |
| `ARGUS_EMBEDDING_DIM`   | `512`                  | Embedding dimensionality                |
| `ARGUS_MATCH_THRESHOLD` | `0.35`                 | Cosine sim; `>=` is a match             |
| `ARGUS_MATCH_TOP_K`     | `5`                    | Max matches returned                    |
| `ARGUS_MIN_DET_SCORE`   | `0.5`                  | Detect filter threshold                 |
| `ARGUS_MAX_IMAGE_MB`    | `10`                   | Upload size limit                       |
| `ARGUS_DATABASE_URL`    | _(unset)_              | Postgres+pgvector DSN                   |
| `ARGUS_CORS_ORIGINS`    | `["*"]`                | JSON array of allowed origins           |
