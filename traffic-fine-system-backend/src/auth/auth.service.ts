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
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async login(username: string, password: string) {
    const user = await this.usersService.findByUsername(username);

    if (!user || !user.password) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = {
      sub: user.id,
      username: user.username,
      role: user.role,
    };

    return {
      access_token: this.jwtService.sign(payload),
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