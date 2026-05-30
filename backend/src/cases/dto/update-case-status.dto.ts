import { IsNotEmpty, IsIn } from 'class-validator';

export class UpdateCaseStatusDto {
  @IsNotEmpty()
  @IsIn(['PENDING', 'APPROVED', 'RESOLVED', 'REJECTED'])
  status: string;
}
