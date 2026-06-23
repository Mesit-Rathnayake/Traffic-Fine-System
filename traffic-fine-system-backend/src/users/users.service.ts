import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findByUsername(username: string) {
    return this.prisma.user.findUnique({
      where: { username },
    });
  }

  async findByEmail(email: string) {
  return this.prisma.user.findUnique({
    where: {
      email: email, // This assumes your schema has 'email' marked as @unique
    },
  });
  }

  async createUser(data: any) {
    return this.prisma.user.create({ data });
  }

  // Add these to your current UsersService class
  async findById(id: number) {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async updateUser(id: number, data: any) {
    return this.prisma.user.update({
      where: { id },
      data: {
        name : data.name,
        email : data.email,
        phone: data.phone,
        license : data.license,
      },
    });
}
}
