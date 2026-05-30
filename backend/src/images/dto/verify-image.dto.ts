import { IsOptional, IsString, IsUrl } from 'class-validator';

export class VerifyImageDto {
  // require_tld:false so local upload URLs (http://localhost:3000/uploads/..) pass.
  @IsUrl({ require_tld: false })
  photo_url: string;

  @IsString()
  @IsOptional()
  person_name?: string;
}
