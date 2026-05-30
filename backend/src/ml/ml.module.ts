import { Global, Module } from '@nestjs/common';
import { MlService } from './ml.service';

/**
 * Global module exposing the ML service client app-wide (like PrismaModule),
 * so CasesService and SightingsService can inject MlService directly.
 */
@Global()
@Module({
  providers: [MlService],
  exports: [MlService],
})
export class MlModule {}
