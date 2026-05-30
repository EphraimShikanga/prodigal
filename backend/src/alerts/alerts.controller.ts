import { Controller, Get, Post, Patch, Body, Param, HttpCode, HttpStatus, UsePipes, ValidationPipe } from '@nestjs/common';
import { AlertsService } from './alerts.service';
import { CreateAlertDto } from './dto/create-alert.dto';

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
  @UsePipes(new ValidationPipe({ whitelist: true, transform: true }))
  async createMobileAlert(@Body() createAlertDto: CreateAlertDto) {
    return this.alertsService.createMobileAlert(createAlertDto);
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
