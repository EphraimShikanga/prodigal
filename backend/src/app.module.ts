import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { MlModule } from './ml/ml.module';
import { CasesModule } from './cases/cases.module';
import { SightingsModule } from './sightings/sightings.module';
import { AlertsModule } from './alerts/alerts.module';
import { UploadModule } from './common/upload/upload.module';
import { ImagesModule } from './images/images.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    PrismaModule,
    MlModule,
    CasesModule,
    SightingsModule,
    AlertsModule,
    UploadModule,
    ImagesModule,
  ],
})
export class AppModule {}
