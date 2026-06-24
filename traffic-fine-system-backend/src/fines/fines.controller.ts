import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { FinesService } from './fines.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';

@Controller('fines')
export class FinesController {
  constructor(private readonly finesService: FinesService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  listFines() {
    return this.finesService.listFines();
  }

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
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @Get('admin-only')
  adminOnlyRoute() {
    return {
      message: 'Welcome Admin',
    };
  }
}
