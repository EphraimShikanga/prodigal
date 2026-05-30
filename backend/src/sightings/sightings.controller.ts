import { Controller, Post, Get, Body, HttpCode, HttpStatus, UsePipes, ValidationPipe } from '@nestjs/common';
import { SightingsService } from './sightings.service';
import { SubmitSightingDto } from './dto/submit-sighting.dto';

@Controller('sightings')
export class SightingsController {
  constructor(private readonly sightingsService: SightingsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ValidationPipe({ whitelist: true, transform: true }))
  async create(@Body() submitSightingDto: SubmitSightingDto) {
    return this.sightingsService.create(submitSightingDto);
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll() {
    return this.sightingsService.findAll();
  }
}
