import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
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

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('OFFICER')
  @Post()
  createFine(@Body() body: any, @Req() req: any) {
    return this.finesService.createFine({
      category: body.category,
      amount: Number(body.amount),
      district: body.district,
      driverName: body.driverName,
      driverLicense: body.driverLicense,
      vehicleNumber: body.vehicleNumber,
      offenseDate: body.offenseDate,
      offenseLocation: body.offenseLocation,
      notes: body.notes,
      officerId: req.user.userId,
    });
  }

  @UseGuards(JwtAuthGuard)
  @Get('protected')
  getProtected() {
    return {
      message: 'Protected route working',
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN', 'OFFICER')
  @Get('admin-only')
  adminOnlyRoute() {
    return {
      message: 'Welcome Admin',
    };
  }

  @UseGuards(JwtAuthGuard)
  @Get(':referenceNumber')
  getFine(@Param('referenceNumber') ref: string) {
    return this.finesService.getFineByReference(ref);
  }
}