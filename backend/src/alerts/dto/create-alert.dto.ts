import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsUrl,
  IsOptional,
  Min,
  Max,
  IsDateString,
} from 'class-validator';

export class CreateAlertDto {
  @IsString()
  @IsNotEmpty()
  child_name: string;

  @IsNumber()
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

  @IsString()
  @IsNotEmpty()
  reporter_name: string;

  @IsString()
  @IsNotEmpty()
  reporter_phone: string;

  @IsString()
  @IsOptional()
  reporter_email?: string;

  @IsString()
  @IsNotEmpty()
  reporter_relationship: string;

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
  @IsNotEmpty()
  last_seen_time: string;

  @IsString()
  @IsOptional()
  source?: string; // 'mobile', 'web', etc.
}
