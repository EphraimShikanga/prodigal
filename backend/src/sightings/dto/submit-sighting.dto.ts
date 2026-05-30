import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsUrl,
  IsOptional,
  IsUUID,
  Min,
  Max,
} from 'class-validator';

export class SubmitSightingDto {
  @IsUUID()
  @IsOptional()
  case_id?: string;

  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @IsString()
  @IsNotEmpty()
  location_description: string;

  @IsUrl()
  @IsNotEmpty()
  photo_url: string;

  @IsString()
  @IsOptional()
  reporter_name?: string;

  @IsString()
  @IsOptional()
  reporter_phone?: string;
}
