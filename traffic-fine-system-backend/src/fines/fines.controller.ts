import { Controller, Get, Param } from '@nestjs/common';
import { FinesService } from './fines.service';
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('fines')
export class FinesController {
  constructor(private finesService: FinesService) {}

  @Get(':referenceNumber')
  getFine(@Param('referenceNumber') ref: string) {
    return this.finesService.getFineByReference(ref);
  }

  @UseGuards(JwtAuthGuard)
  @Get('protected')
  getProtected() {
    return {
      message: 'Protected route working',
    };
  }
}