# Postgres 16 WITH pgvector — the ML service stores face embeddings in a
# vector(512) column (argus_faces), which plain postgres:16-alpine cannot do.
# This single DB serves both the Prisma app tables and the ML vector table.
FROM pgvector/pgvector:pg16
