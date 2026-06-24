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
    const updatePayload: Record<string, string> = {};

    if (typeof data?.name === 'string') updatePayload.name = data.name;
    if (typeof data?.email === 'string') updatePayload.email = data.email;
    if (typeof data?.phone === 'string') updatePayload.phone = data.phone;
    if (typeof data?.license === 'string') updatePayload.license = data.license;

    return this.prisma.user.update({
      where: { id },
      data: updatePayload,
    });
  }
}
