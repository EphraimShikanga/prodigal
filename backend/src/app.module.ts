import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { CasesModule } from './cases/cases.module';
import { SightingsModule } from './sightings/sightings.module';
import { AlertsModule } from './alerts/alerts.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    PrismaModule,
    CasesModule,
    SightingsModule,
    AlertsModule,
  ],
})
export class AppModule {}
