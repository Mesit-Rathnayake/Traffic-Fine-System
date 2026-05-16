import { Injectable, UnauthorizedException } from '@nestjs/common';
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
  console.log('USERNAME:', username);

  const user = await this.usersService.findByUsername(username);

  if (!user) {
    throw new UnauthorizedException('Invalid credentials');
  }

  // Avoid logging sensitive fields such as the hashed password
  console.log('USER FROM DB:', { id: user.id, username: user.username, role: user.role });

  // If no password is stored for the user, reject authentication
  if (!user.password) {
    throw new UnauthorizedException('Invalid credentials');
  }

  const passwordMatch = await bcrypt.compare(password, user.password);

  console.log('PASSWORD MATCH:', passwordMatch);

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
}