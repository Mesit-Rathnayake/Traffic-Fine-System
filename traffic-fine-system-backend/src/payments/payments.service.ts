import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { EmailService } from '../email/email.service';

@Injectable()
export class PaymentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly emailService: EmailService,
  ) {}

  async payFine(referenceNumber: string, amount: number) {
    const safeAmount = Number(amount);

    if (Number.isNaN(safeAmount) || safeAmount <= 0) {
      throw new BadRequestException('Amount must be a positive number');
    }

    // 🔍 Find fine
    const fine = await this.prisma.fine.findUnique({
      where: { referenceNumber },
    });

    // ❌ Fine not found
    if (!fine) {
      throw new NotFoundException('Fine not found');
    }

    // ❌ Already paid
    if (fine.status === 'PAID') {
      throw new BadRequestException('Fine already paid');
    }

    // 💳 Create payment record
    const payment = await this.prisma.payment.create({
      data: {
        fineId: fine.id,
        amount: safeAmount,
        status: 'SUCCESS',
      },
    });

    // ✅ Update fine status
    await this.prisma.fine.update({
      where: { id: fine.id },
      data: {
        status: 'PAID',
      },
    });

    // 📧 Send email notification - do not fail payment if email sending fails
    try {
      await this.emailService.sendPaymentSuccessEmail(
        'officer@gmail.com',
        fine.referenceNumber,
        payment.amount,
      );
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e);
      console.error('Failed to send payment email:', msg);
    }

    // 🚀 Return response
    return {
      message: 'Payment successful',
      payment,
    };
  }

  // Support paying by internal fine id as well
  async payFineById(fineId: number, amount: number) {
    const safeAmount = Number(amount);

    if (Number.isNaN(safeAmount) || safeAmount <= 0) {
      throw new BadRequestException('Amount must be a positive number');
    }

    const fine = await this.prisma.fine.findUnique({ where: { id: fineId } });

    if (!fine) {
      throw new NotFoundException('Fine not found');
    }

    if (fine.status === 'PAID') {
      throw new BadRequestException('Fine already paid');
    }

    const payment = await this.prisma.payment.create({
      data: {
        fineId: fine.id,
        amount: safeAmount,
        status: 'SUCCESS',
      },
    });

    await this.prisma.fine.update({
      where: { id: fine.id },
      data: { status: 'PAID' },
    });

    try {
      await this.emailService.sendPaymentSuccessEmail(
        'officer@gmail.com',
        fine.referenceNumber,
        payment.amount,
      );
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e);
      console.error('Failed to send payment email:', msg);
    }

    return { message: 'Payment successful', payment };
  }
}
