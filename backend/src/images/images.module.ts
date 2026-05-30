import { Module } from '@nestjs/common';
import { ImagesController } from './images.controller';

/**
 * Exposes the ML image-verification API through the backend. MlService is
 * provided globally by MlModule, so no providers are needed here.
 */
@Module({
  controllers: [ImagesController],
})
export class ImagesModule {}
