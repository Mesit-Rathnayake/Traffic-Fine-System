import { Controller, Get, Query } from '@nestjs/common';
import { AdminService } from './admin.service';
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
@Controller('admin')
export class AdminController {
  constructor(private adminService: AdminService) {}

  @Get('total-collections')
  getTotal() {
    return this.adminService.getTotalCollections();
  }

  @Get('district-collections')
  getDistrictCollections() {
    return this.adminService.getDistrictCollections();
  }

  @Get('category-breakdown')
  getCategoryBreakdown() {
    return this.adminService.getCategoryBreakdown();
  }

  @Get('users')
  getUsersList(@Query('limit') limit?: string) {
    return this.adminService.getUsersList(Number.parseInt(limit || '20', 10));
  }

  @Get('fines')
  getFinesList(@Query('limit') limit?: string) {
    return this.adminService.getFinesList(Number.parseInt(limit || '20', 10));
  }

  @Get('payments')
  getPaymentsList(@Query('limit') limit?: string) {
    return this.adminService.getPaymentsList(Number.parseInt(limit || '20', 10));
  }
}
