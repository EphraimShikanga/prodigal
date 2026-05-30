import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AlertsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.amberAlert.findMany({
      orderBy: { dispatch_timestamp: 'desc' },
      include: {
        case: true,
      },
    });
  }
}
