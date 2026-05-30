import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SubmitSightingDto } from './dto/submit-sighting.dto';

@Injectable()
export class SightingsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: SubmitSightingDto) {
    if (dto.case_id) {
      const parentCase = await this.prisma.case.findUnique({
        where: { id: dto.case_id },
      });
      if (!parentCase) {
        throw new NotFoundException(`Case with ID ${dto.case_id} not found`);
      }
    }

    return this.prisma.sighting.create({
      data: {
        case_id: dto.case_id || null,
        latitude: dto.latitude,
        longitude: dto.longitude,
        location_description: dto.location_description,
        photo_url: dto.photo_url,
        reporter_name: dto.reporter_name || null,
        reporter_phone: dto.reporter_phone || null,
        status: 'PENDING',
      },
    });
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
