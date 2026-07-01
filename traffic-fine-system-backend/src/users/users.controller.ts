import {
  Body,
  Controller,
  Get,
  Post,
  Put,
  Req,
  UseGuards,
  BadRequestException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';

import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@Req() req: any) {
    return req.user;
  }

  @UseGuards(JwtAuthGuard)
  @Put('profile')
  updateProfile() {
    return {
      message: 'Profile update endpoint working',
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN', 'OFFICER')
  @Post('create-officer')
  async createOfficer(@Body() body: any) {
    const existingUsername = await this.usersService.findByUsername(
      body.username,
    );

    if (existingUsername) {
      throw new BadRequestException('Username already exists');
    }

    const existingEmail = await this.usersService.findByEmail(body.email);

    if (existingEmail) {
      throw new BadRequestException('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(body.password, 10);

    const officer = await this.usersService.createUser({
      name: body.name,
      username: body.username,
      email: body.email,
      password: hashedPassword,
      role: 'OFFICER',
      phone: body.phone || null,
      license: body.license || null,
    });

    return {
      message: 'Officer created successfully',
      officer: {
        id: officer.id,
        name: officer.name,
        username: officer.username,
        email: officer.email,
        role: officer.role,
        phone: officer.phone,
        license: officer.license,
      },
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN', 'OFFICER')
  @Get()
  listUsers() {
    return this.usersService.listUsers();
  }
}