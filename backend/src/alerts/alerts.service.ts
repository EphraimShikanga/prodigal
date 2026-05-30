import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAlertDto } from './dto/create-alert.dto';

@Injectable()
export class AlertsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.amberAlert.findMany({
      orderBy: { dispatch_timestamp: 'desc' },
      include: {
        case: {
          include: {
            child: true,
            reporter: true,
          },
        },
      },
    });
  }

  async createMobileAlert(dto: CreateAlertDto) {
    return this.prisma.$transaction(async (tx) => {
      // Create child record
      const child = await tx.child.create({
        data: {
          name: dto.child_name,
          age: dto.age,
          gender: dto.gender,
          description: dto.description,
          photo_url: dto.photo_url,
        },
      });

      // Create reporter record
      const reporter = await tx.reporter.create({
        data: {
          name: dto.reporter_name,
          phone: dto.reporter_phone,
          email: dto.reporter_email || null,
          relationship: dto.reporter_relationship,
        },
      });

      // Create police abstract record (temporary for mobile reports)
      const police = await tx.policeAbstract.create({
        data: {
          police_ob_number: `MOBILE/${Date.now()}`,
          station_name: 'Mobile Report',
          officer_id: 'PENDING',
          officer_name: 'Pending Verification',
          abstract_image_url: dto.photo_url,
          stamp_verification_status: 'PENDING',
        },
      });

      // Create case record
      const caseRecord = await tx.case.create({
        data: {
          child_id: child.id,
          reporter_id: reporter.id,
          police_abstract_id: police.id,
          last_seen_location: dto.last_seen_location,
          last_seen_lat: dto.last_seen_lat,
          last_seen_lng: dto.last_seen_lng,
          last_seen_time: new Date(dto.last_seen_time),
          status: 'PENDING',
        },
        include: {
          child: true,
          reporter: true,
          police_abstract: true,
        },
      });

      return caseRecord;
    });
  }

  async getPendingAlerts() {
    return this.prisma.case.findMany({
      where: {
        status: 'PENDING',
        police_abstract: {
          station_name: 'Mobile Report',
        },
      },
      orderBy: { created_at: 'desc' },
      include: {
        child: true,
        reporter: true,
        police_abstract: true,
      },
    });
  }

  async verifyAlert(caseId: string) {
    return this.prisma.case.update({
      where: { id: caseId },
      data: {
        status: 'APPROVED',
        police_abstract: {
          update: {
            station_name: 'Verified Mobile Report',
            stamp_verification_status: 'VERIFIED',
          },
        },
      },
      include: {
        child: true,
        reporter: true,
        police_abstract: true,
      },
    });
  }

  async getPublicAlerts() {
    return this.prisma.case.findMany({
      where: {
        status: 'APPROVED',
        police_abstract: {
          station_name: 'Verified Mobile Report',
        },
      },
      orderBy: { created_at: 'desc' },
      include: {
        child: true,
        reporter: true,
        police_abstract: true,
      },
    });
  }

  async getFoundCases() {
    return this.prisma.case.findMany({
      where: {
        status: 'RESOLVED',
      },
      orderBy: { created_at: 'desc' },
      include: {
        child: true,
        reporter: true,
        police_abstract: true,
      },
    });
  }
}
