import { IsNotEmpty, IsString, IsUrl } from 'class-validator';

export class EnrollPersonDto {
  // require_tld:false so local upload URLs (http://localhost:3000/uploads/..) pass.
  @IsUrl({ require_tld: false })
  photo_url: string;

  @IsString()
  @IsNotEmpty()
  name: string;
}
