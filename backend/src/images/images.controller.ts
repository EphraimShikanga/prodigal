import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { MlService } from '../ml/ml.service';
import { VerifyImageDto } from './dto/verify-image.dto';
import { EnrollPersonDto } from './dto/enroll-person.dto';

/**
 * Backend gateway to the ML image-verification API (ML /api/images).
 *
 * Images are referenced by URL (e.g. the URL returned by POST /upload/image);
 * MlService fetches the bytes and forwards them to the ML service.
 */
@Controller('images')
export class ImagesController {
  constructor(private readonly ml: MlService) {}

  /** Verify an image: duplicate detection + face recognition + Gemini summary. */
  @Post('verify')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ whitelist: true, transform: true }))
  async verify(@Body() dto: VerifyImageDto) {
    return this.ml.verifyImage(dto.photo_url, dto.person_name);
  }

  /** Enroll a known person so future uploads can be recognised. */
  @Post('persons')
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ValidationPipe({ whitelist: true, transform: true }))
  async enrollPerson(@Body() dto: EnrollPersonDto) {
    return this.ml.enrollPerson(dto.photo_url, dto.name);
  }

  /** Fetch a stored image's details, faces, matches and Gemini summary. */
  @Get('search/:imageId')
  @HttpCode(HttpStatus.OK)
  async search(@Param('imageId') imageId: string) {
    return this.ml.searchImage(imageId);
  }
}
