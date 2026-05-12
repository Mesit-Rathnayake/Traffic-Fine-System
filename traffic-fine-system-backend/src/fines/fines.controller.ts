import { Controller, Get, Param } from '@nestjs/common';
import { FinesService } from './fines.service';

@Controller('fines')
export class FinesController {
  constructor(private finesService: FinesService) {}

  @Get(':referenceNumber')
  getFine(@Param('referenceNumber') ref: string) {
    return this.finesService.getFineByReference(ref);
  }
}