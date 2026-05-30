import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MlService, MatchItem } from '../ml/ml.service';
import { SubmitSightingDto } from './dto/submit-sighting.dto';

@Injectable()
export class SightingsService {
  private readonly logger = new Logger(SightingsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly ml: MlService,
  ) {}

  async create(dto: SubmitSightingDto) {
    if (dto.case_id) {
      const parentCase = await this.prisma.case.findUnique({
        where: { id: dto.case_id },
      });
      if (!parentCase) {
        throw new NotFoundException(`Case with ID ${dto.case_id} not found`);
      }
    }

    // If the reporter did not link a case, ask the ML service to match the
    // sighting photo against enrolled cases (best-effort).
    let caseId = dto.case_id || null;
    let match: MatchItem | null = null;
    if (!caseId) {
      try {
        const result = await this.ml.matchByPhotoUrl(dto.photo_url);
        const best = result.matches[0];
        if (best) {
          // Confirm the matched case still exists before linking.
          const exists = await this.prisma.case.findUnique({
            where: { id: best.case_id },
          });
          if (exists) {
            caseId = best.case_id;
            match = best;
            this.logger.log(
              `Sighting matched case ${best.case_id} (similarity ${best.similarity.toFixed(3)})`,
            );
          }
        }
      } catch (err) {
        this.logger.error(`ML match failed for sighting: ${err}`);
      }
    }

    const sighting = await this.prisma.sighting.create({
      data: {
        case_id: caseId,
        latitude: dto.latitude,
        longitude: dto.longitude,
        location_description: dto.location_description,
        photo_url: dto.photo_url,
        reporter_name: dto.reporter_name || null,
        reporter_phone: dto.reporter_phone || null,
        status: 'PENDING',
      },
    });

    // Surface the match (similarity / ob number) to the caller for review.
    return { ...sighting, match };
  }

  async findAll() {
    return this.prisma.sighting.findMany({
      orderBy: { created_at: 'desc' },
      include: {
        case: {
          include: {
            child: true,
          },
        },
      },
    });
  }
}
