import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async login(loginDto: { email?: string; username?: string; password: string }) {
    const { email, username, password } = loginDto;

    if (!password || (!email && !username)) {
      throw new BadRequestException('Email or username and password are required');
    }

    const normalizedEmail = email?.trim().toLowerCase();
    const normalizedUsername = username?.trim();

    const user = normalizedEmail
      ? await this.usersService.findByEmail(normalizedEmail)
      : await this.usersService.findByUsername(normalizedUsername!);

    if (!user?.password) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = {
      sub: user.id,
      email: user.email,
      username: user.username,
      role: user.role,
    };

    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        name: user.name,
        username: user.username,
        email: user.email,
        role: user.role,
      },
    };
  }

  async register(body: any) {
    const existingUsername = await this.usersService.findByUsername(
      body.username,
    );

    if (existingUsername) {
      throw new BadRequestException('Username already exists');
    }

    const hashedPassword = await bcrypt.hash(body.password, 10);

    const user = await this.usersService.createUser({
      name: body.name,
      username: body.username,
      email: body.email,
      password: hashedPassword,
      role: 'DRIVER',
    });

    return {
      message: 'Driver registered successfully',
      user: {
        id: user.id,
        name: user.name,
        username: user.username,
        email: user.email,
        role: user.role,
      },
    };
  }
}