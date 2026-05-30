import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { CasesService } from './cases.service';
import { CreateCaseDto } from './dto/create-case.dto';
import { UpdateCaseStatusDto } from './dto/update-case-status.dto';

@Controller('cases')
export class CasesController {
  constructor(private readonly casesService: CasesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ValidationPipe({ whitelist: true, transform: true }))
  async create(@Body() createCaseDto: CreateCaseDto) {
    return this.casesService.create(createCaseDto);
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll(@Query('status') status?: string) {
    return this.casesService.findAll(status);
  }

  @Get('metrics')
  @HttpCode(HttpStatus.OK)
  async getMetrics() {
    return this.casesService.getMetrics();
  }

  @Get(':id')
  @HttpCode(HttpStatus.OK)
  async findOne(@Param('id') id: string) {
    return this.casesService.findOne(id);
  }

  @Patch(':id/status')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ whitelist: true, transform: true }))
  async updateStatus(
    @Param('id') id: string,
    @Body() updateCaseStatusDto: UpdateCaseStatusDto,
  ) {
    return this.casesService.updateStatus(id, updateCaseStatusDto);
  }
}
