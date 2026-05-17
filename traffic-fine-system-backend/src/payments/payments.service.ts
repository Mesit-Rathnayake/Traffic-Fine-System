import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PaymentsService {
  constructor(private prisma: PrismaService) {}

  async payFine(referenceNumber: string, amount: number) {

    const fine = await this.prisma.fine.findUnique({
      where: { referenceNumber },
    });

    if (!fine) {
      throw new NotFoundException('Fine not found');
    }

    if (fine.status === 'PAID') {
      throw new BadRequestException('Fine already paid');
    }

    const payment = await this.prisma.payment.create({
      data: {
        fineId: fine.id,
        amount,
        status: 'SUCCESS',
      },
    });

    await this.prisma.fine.update({
      where: { id: fine.id },
      data: {
        status: 'PAID',
      },
    });

    return {
      message: 'Payment successful',
      payment,
    };
  }
}