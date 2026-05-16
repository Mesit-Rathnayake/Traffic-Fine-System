import { Injectable } from '@nestjs/common';
import * as nodemailer from 'nodemailer';

@Injectable()
export class EmailService {
  private transporter;

  constructor() {
    this.transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });
  }

  async sendPaymentSuccessEmail(
    to: string,
    referenceNumber: string,
    amount: number,
  ) {
    await this.transporter.sendMail({
      from: process.env.EMAIL_USER,
      to,
      subject: 'Traffic Fine Payment Confirmation',
      text: `
Payment Successful!

Reference Number: ${referenceNumber}
Amount: Rs.${amount}

The driving license can now be released.

Traffic Fine Management System
      `,
    });

    return {
      success: true,
      message: 'Email sent successfully',
    };
  }
}