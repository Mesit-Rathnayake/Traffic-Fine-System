import { Body, Controller, Post } from '@nestjs/common';
import { PaymentsService } from './payments.service';

@Controller('payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  @Post('pay')
  pay(@Body() body: any) {
    // Support either referenceNumber or fineId in the request body
    if (body.referenceNumber) {
      return this.paymentsService.payFine(body.referenceNumber, body.amount);
    }

    if (body.fineId) {
      return this.paymentsService.payFineById(body.fineId, body.amount);
    }

    return this.paymentsService.payFine(body.referenceNumber, body.amount);
  }
}
