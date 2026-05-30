import { Controller, Get, Post, Patch, Body, Param, HttpCode, HttpStatus, UsePipes, ValidationPipe, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AlertsService } from './alerts.service';
import { CreateAlertDto } from './dto/create-alert.dto';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { v4 as uuidv4 } from 'uuid';

const multerOptions = {
  storage: diskStorage({
    destination: './uploads',
    filename: (req: any, file: Express.Multer.File, callback: (error: Error | null, filename: string) => void) => {
      const uniqueSuffix = uuidv4();
      const ext = extname(file.originalname);
      callback(null, `${uniqueSuffix}${ext}`);
    },
  }),
  fileFilter: (req: any, file: Express.Multer.File, callback: (error: Error | null, accept: boolean) => void) => {
    const allowedMimes = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/webp',
    ];
    if (allowedMimes.includes(file.mimetype)) {
      callback(null, true);
    } else {
      callback(new Error('Only JPEG, PNG, and WebP images are allowed'), false);
    }
  },
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
  },
};

@Controller('alerts')
export class AlertsController {
  constructor(private readonly alertsService: AlertsService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll() {
    return this.alertsService.findAll();
  }

  @Post('mobile')
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(FileInterceptor('photo', multerOptions))
  async createMobileAlert(
    @UploadedFile() file: Express.Multer.File | undefined,
    @Body() body: any,
  ) {
    const apiBaseUrl = process.env.API_BASE_URL || 'http://localhost:3000';
    const dto: CreateAlertDto = {
      child_name: body.child_name,
      age: parseInt(body.age),
      gender: body.gender,
      description: body.description,
      photo_url: file ? `${apiBaseUrl}/uploads/${file.filename}` : (body.photo_url || null),
      reporter_name: body.reporter_name,
      reporter_phone: body.reporter_phone,
      reporter_email: body.reporter_email,
      reporter_relationship: body.reporter_relationship,
      last_seen_location: body.last_seen_location,
      last_seen_lat: parseFloat(body.last_seen_lat),
      last_seen_lng: parseFloat(body.last_seen_lng),
      last_seen_time: body.last_seen_time,
      source: body.source,
    };
    return this.alertsService.createMobileAlert(dto);
  }

  @Get('pending')
  @HttpCode(HttpStatus.OK)
  async getPendingAlerts() {
    return this.alertsService.getPendingAlerts();
  }

  @Patch(':id/verify')
  @HttpCode(HttpStatus.OK)
  async verifyAlert(@Param('id') id: string) {
    return this.alertsService.verifyAlert(id);
  }

  @Get('public')
  @HttpCode(HttpStatus.OK)
  async getPublicAlerts() {
    return this.alertsService.getPublicAlerts();
  }

  @Get('found')
  @HttpCode(HttpStatus.OK)
  async getFoundCases() {
    return this.alertsService.getFoundCases();
  }
}
