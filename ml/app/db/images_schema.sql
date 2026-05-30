-- Schema for the face-recognition / image-verification subsystem (ARGUS-KE).
-- Requires the pgvector extension for 512-d face embeddings.

CREATE EXTENSION IF NOT EXISTS vector;

-- Stored images: original file location plus content + perceptual hashes used
-- for exact and near-duplicate detection.
CREATE TABLE IF NOT EXISTS images (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    image_path  text,
    image_hash  text,
    phash       text,
    uploaded_at timestamptz DEFAULT now()
);

-- Known persons, optionally linked to the representative image they were
-- enrolled from.
CREATE TABLE IF NOT EXISTS persons (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name       text NOT NULL,
    image_id   uuid REFERENCES images(id) ON DELETE SET NULL,
    created_at timestamptz DEFAULT now()
);

-- One row per detected face: its 512-d embedding plus detection metadata.
CREATE TABLE IF NOT EXISTS face_embeddings (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    image_id   uuid REFERENCES images(id) ON DELETE CASCADE,
    person_id  uuid REFERENCES persons(id) ON DELETE SET NULL,
    embedding  vector(512) NOT NULL,
    bbox       jsonb,
    det_score  real,
    created_at timestamptz DEFAULT now()
);

-- Indexes.
CREATE INDEX IF NOT EXISTS idx_images_image_hash
    ON images (image_hash);

CREATE INDEX IF NOT EXISTS idx_face_embeddings_embedding
    ON face_embeddings USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

CREATE INDEX IF NOT EXISTS idx_face_embeddings_person_id
    ON face_embeddings (person_id);
