import { Body, Controller, Post, BadRequestException } from '@nestjs/common';
import { PaymentsService } from './payments.service';

@Controller('payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  // File: traffic-fine-system-backend/src/payments/payments.controller.ts

@Post('pay')
async pay(@Body() body: any) {
  try {
    console.log('--- PAY REQUEST RECEIVED ---', body);
    
    // We will now catch the error right here
    return await this.paymentsService.payFine(body.referenceNumber, body.amount);
  } catch (error) {
    // This logs the full error detail to your terminal
    console.error('--- FULL ERROR DETAILS ---', error);
    
    // 1. Narrow the type to see if it is an object
  if (error instanceof Error) {
    console.log('Error message:', error.message);
  }

  // 2. If you are using NestJS Exceptions, cast it to 'any' or 'any' type 
  // so you can access the status property safely.
  const err = error as any; 
  if (err.status === 404) {
    console.error('The backend service failed to find the Fine ID in the database!');
  }
  
  throw error;
  }
}
}
