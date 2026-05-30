import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface EnrollResult {
  case_id: string;
  face_id: string;
  embedding_dim: number;
  det_score: number;
  stored: boolean;
}

export interface MatchItem {
  case_id: string;
  face_id: string;
  similarity: number;
  ob_number?: string | null;
  metadata?: Record<string, unknown> | null;
}

export interface MatchResult {
  probe_faces: number;
  best_similarity: number | null;
  matches: MatchItem[];
}

export interface KnownFace {
  name: string;
  confidence: number;
}

export interface ImageMatch {
  person: string;
  similarity: number;
}

/** Result of the ML image-verification pipeline (/api/images). */
export interface ImageVerificationResult {
  success: boolean;
  image_id: string | null;
  image_exists: boolean;
  duplicate_image: boolean;
  duplicate_probability: number;
  faces_detected: number;
  known_faces: KnownFace[];
  unknown_faces: number;
  matches: ImageMatch[];
  gemini_summary: string;
}

/**
 * Client for the ARGUS-KE ML service (FastAPI face-recognition microservice).
 *
 * The ML service base URL comes from the ML_SERVICE_URL env var
 * (default http://localhost:8000). Photos are referenced by URL in the DB, so
 * this service fetches the image bytes and forwards them as multipart uploads.
 */
@Injectable()
export class MlService {
  private readonly logger = new Logger(MlService.name);
  private readonly baseUrl: string;

  constructor(private readonly config: ConfigService) {
    this.baseUrl =
      this.config.get<string>('ML_SERVICE_URL') ?? 'http://localhost:8000';
  }

  private async fetchImage(photoUrl: string): Promise<Blob> {
    const res = await fetch(photoUrl);
    if (!res.ok) {
      throw new Error(`Failed to fetch photo (${res.status}) from ${photoUrl}`);
    }
    const buf = await res.arrayBuffer();
    const type = res.headers.get('content-type') ?? 'image/jpeg';
    return new Blob([buf], { type });
  }

  /** Enroll a verified missing-person face into the ML index. */
  async enrollCase(params: {
    caseId: string;
    obNumber: string;
    photoUrl: string;
    metadata?: Record<string, unknown>;
  }): Promise<EnrollResult> {
    const image = await this.fetchImage(params.photoUrl);
    const form = new FormData();
    form.append('file', image, 'case.jpg');
    form.append('case_id', params.caseId);
    form.append('ob_number', params.obNumber);
    if (params.metadata) form.append('metadata', JSON.stringify(params.metadata));

    const res = await fetch(`${this.baseUrl}/api/v1/cases/enroll`, {
      method: 'POST',
      body: form,
    });
    if (!res.ok) {
      throw new Error(`ML enroll failed (${res.status}): ${await res.text()}`);
    }
    return (await res.json()) as EnrollResult;
  }

  /** Match a sighting photo against all enrolled cases. */
  async matchByPhotoUrl(
    photoUrl: string,
    opts?: { topK?: number; threshold?: number },
  ): Promise<MatchResult> {
    const image = await this.fetchImage(photoUrl);
    const form = new FormData();
    form.append('file', image, 'sighting.jpg');
    if (opts?.topK != null) form.append('top_k', String(opts.topK));
    if (opts?.threshold != null) form.append('threshold', String(opts.threshold));

    const res = await fetch(`${this.baseUrl}/api/v1/match`, {
      method: 'POST',
      body: form,
    });
    if (!res.ok) {
      throw new Error(`ML match failed (${res.status}): ${await res.text()}`);
    }
    return (await res.json()) as MatchResult;
  }

  /** Remove a case's embeddings from the ML index (e.g. when resolved). */
  async deleteCase(caseId: string): Promise<void> {
    const res = await fetch(
      `${this.baseUrl}/api/v1/cases/${encodeURIComponent(caseId)}`,
      { method: 'DELETE' },
    );
    if (!res.ok) {
      this.logger.warn(`ML delete failed (${res.status}) for case ${caseId}`);
    }
  }

  /** Liveness check against the ML service. */
  async health(): Promise<boolean> {
    try {
      const res = await fetch(`${this.baseUrl}/health`);
      return res.ok;
    } catch {
      return false;
    }
  }

  // --- Image-verification API (ML /api/images) -----------------------------

  /**
   * Verify an uploaded image: duplicate detection, face recognition against
   * known persons, and a Gemini natural-language summary.
   */
  async verifyImage(
    photoUrl: string,
    personName?: string,
  ): Promise<ImageVerificationResult> {
    const image = await this.fetchImage(photoUrl);
    const form = new FormData();
    form.append('file', image, 'upload.jpg');
    if (personName) form.append('person_name', personName);

    const res = await fetch(`${this.baseUrl}/api/images/upload`, {
      method: 'POST',
      body: form,
    });
    if (!res.ok) {
      throw new Error(`ML image verify failed (${res.status}): ${await res.text()}`);
    }
    return (await res.json()) as ImageVerificationResult;
  }

  /** Enroll a known person from an image so future uploads can recognise them. */
  async enrollPerson(
    photoUrl: string,
    name: string,
  ): Promise<ImageVerificationResult> {
    const image = await this.fetchImage(photoUrl);
    const form = new FormData();
    form.append('file', image, 'person.jpg');
    form.append('name', name);

    const res = await fetch(`${this.baseUrl}/api/images/persons`, {
      method: 'POST',
      body: form,
    });
    if (!res.ok) {
      throw new Error(`ML person enroll failed (${res.status}): ${await res.text()}`);
    }
    return (await res.json()) as ImageVerificationResult;
  }

  /** Fetch a stored image's details, detected faces, matches and summary. */
  async searchImage(imageId: string): Promise<Record<string, unknown>> {
    const res = await fetch(
      `${this.baseUrl}/api/images/search/${encodeURIComponent(imageId)}`,
    );
    if (!res.ok) {
      throw new Error(`ML image search failed (${res.status}): ${await res.text()}`);
    }
    return (await res.json()) as Record<string, unknown>;
  }
}
