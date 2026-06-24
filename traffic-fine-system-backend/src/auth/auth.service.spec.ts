import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  let usersService: { findByUsername: jest.Mock; findByEmail: jest.Mock; createUser: jest.Mock };
  let jwtService: { sign: jest.Mock };

  beforeEach(async () => {
    usersService = {
      findByUsername: jest.fn(),
      findByEmail: jest.fn(),
      createUser: jest.fn(),
    };

    jwtService = {
      sign: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UsersService, useValue: usersService },
        { provide: JwtService, useValue: jwtService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('accepts username-based login payloads', async () => {
    jest.spyOn(bcrypt, 'compare').mockResolvedValue(true as never);
    usersService.findByUsername.mockResolvedValue({
      id: 1,
      name: 'Alice',
      username: 'alice',
      email: 'alice@example.com',
      password: 'hashed',
      role: 'DRIVER',
    });
    jwtService.sign.mockReturnValue('jwt-token');

    const result = await service.login({ username: 'alice', password: 'secret123' });

    expect(usersService.findByUsername).toHaveBeenCalledWith('alice');
    expect(result.access_token).toBe('jwt-token');
    expect(result.user.username).toBe('alice');
  });
});
