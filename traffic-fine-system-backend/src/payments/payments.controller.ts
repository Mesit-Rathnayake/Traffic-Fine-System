import { Body, Controller, Post } from '@nestjs/common';
import { PaymentsService } from './payments.service';

@Controller('payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  @Post('pay')
  pay(@Body() body: any) {
    return this.paymentsService.payFine(
      body.referenceNumber,
      body.amount,
    );
  }
}