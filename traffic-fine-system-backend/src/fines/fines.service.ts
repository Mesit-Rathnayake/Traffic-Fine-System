import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FinesService {
  constructor(private prisma: PrismaService) {}

  async getFineByReference(referenceNumber: string) {
    return this.prisma.fine.findUnique({
      where: { referenceNumber },
    });
  }
}
