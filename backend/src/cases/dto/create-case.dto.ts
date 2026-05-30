import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsUrl,
  IsDateString,
  Min,
  Max,
  IsInt,
  ValidateNested,
  IsOptional,
  IsEmail,
} from 'class-validator';
import { Type } from 'class-transformer';

export class ChildDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsInt()
  @Min(0)
  @Max(18)
  age: number;

  @IsString()
  @IsNotEmpty()
  gender: string;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsUrl()
  @IsNotEmpty()
  photo_url: string;
}

export class ReporterDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  phone: string;

  @IsEmail()
  @IsOptional()
  email?: string;

  @IsString()
  @IsNotEmpty()
  relationship: string;
}

export class PoliceAbstractDto {
  @IsString()
  @IsNotEmpty()
  police_ob_number: string;

  @IsString()
  @IsNotEmpty()
  station_name: string;

  @IsString()
  @IsNotEmpty()
  officer_id: string;

  @IsString()
  @IsNotEmpty()
  officer_name: string;

  @IsUrl()
  @IsNotEmpty()
  abstract_image_url: string;
}

export class CreateCaseDto {
  @ValidateNested()
  @Type(() => ChildDto)
  child: ChildDto;

  @ValidateNested()
  @Type(() => ReporterDto)
  reporter: ReporterDto;

  @ValidateNested()
  @Type(() => PoliceAbstractDto)
  police: PoliceAbstractDto;

  @IsString()
  @IsNotEmpty()
  last_seen_location: string;

  @IsNumber()
  @Min(-90)
  @Max(90)
  last_seen_lat: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
  last_seen_lng: number;

  @IsDateString()
  last_seen_time: string;
}
