import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FinesService {
  constructor(private prisma: PrismaService) {}

  async listFines() {
    return this.prisma.fine.findMany({
      orderBy: { id: 'desc' },
    });
  }

  async getFineByReference(referenceNumber: string) {
    return this.prisma.fine.findUnique({
      where: { referenceNumber },
    });
  }

  async createFine(data: {
    category: string;
    amount: number;
    district?: string;
    officerId: number;
  }) {
    if (!data.category || !data.amount || data.amount <= 0) {
      throw new BadRequestException('Category and valid amount are required');
    }

    const referenceNumber = await this.generateReferenceNumber();

    const fine = await this.prisma.fine.create({
      data: {
        referenceNumber,
        category: data.category,
        amount: data.amount,
        district: data.district || null,
        officerId: data.officerId,
        status: 'PENDING',
      },
    });

    return {
      message: 'Fine created successfully',
      fine,
    };
  }

  private async generateReferenceNumber() {
    const count = await this.prisma.fine.count();
    const nextNumber = count + 1;

    return `FINE-${new Date().getFullYear()}-${String(nextNumber).padStart(
      5,
      '0',
    )}`;
  }
}