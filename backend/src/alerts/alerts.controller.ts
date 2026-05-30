import { Controller, Get, HttpCode, HttpStatus } from '@nestjs/common';
import { AlertsService } from './alerts.service';

@Controller('alerts')
export class AlertsController {
  constructor(private readonly alertsService: AlertsService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll() {
    return this.alertsService.findAll();
  }
}
