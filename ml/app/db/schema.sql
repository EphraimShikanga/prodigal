-- ARGUS-KE ML service -- pgvector schema for enrolled face embeddings.
--
-- Apply this in the Supabase SQL editor (or any Postgres with the pgvector
-- extension available). It creates the `argus_faces` table used by
-- PgVectorStore and a cosine-distance index for fast similarity search.

-- Enable the pgvector extension (idempotent).
CREATE EXTENSION IF NOT EXISTS vector;

-- Enrolled missing-person faces.
-- One row per enrolled face; a case may have multiple faces.
CREATE TABLE IF NOT EXISTS argus_faces (
    face_id     uuid PRIMARY KEY,
    case_id     text NOT NULL,
    ob_number   text,
    embedding   vector(512) NOT NULL,
    metadata    jsonb,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- Fast lookups / deletes by case.
CREATE INDEX IF NOT EXISTS argus_faces_case_id_idx
    ON argus_faces (case_id);

-- Approximate-nearest-neighbour index for cosine similarity search.
-- The PgVectorStore search uses the `<=>` cosine-distance operator, so the
-- index must use `vector_cosine_ops`. IVFFlat is broadly available (including
-- Supabase); switch to HNSW if your Postgres/pgvector build supports it.
--
-- IVFFlat (default): tune `lists` roughly to sqrt(row_count); ANALYZE after
-- bulk loads so the planner uses the index.
CREATE INDEX IF NOT EXISTS argus_faces_embedding_cosine_idx
    ON argus_faces
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

-- Alternative HNSW index (uncomment if supported; remove the IVFFlat one above):
-- CREATE INDEX IF NOT EXISTS argus_faces_embedding_cosine_idx
--     ON argus_faces
--     USING hnsw (embedding vector_cosine_ops);
