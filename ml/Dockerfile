# ARGUS-KE ML Service - base image (runnable WITHOUT the heavy ML model).
#
# This installs only requirements.txt so the service runs with the deterministic
# StubFaceEngine + InMemoryStore out of the box. To enable the real model,
# additionally install requirements-ml.txt and set ARGUS_ML_BACKEND=insightface
# (see README.md).
FROM python:3.11-slim

# Avoid .pyc files and buffer issues; keep logs flushing immediately.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install base dependencies first to leverage Docker layer caching.
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application package.
COPY app ./app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
