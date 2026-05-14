import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { FinesModule } from './fines/fines.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { PaymentsModule } from './payments/payments.module';

@Module({
  imports: [PrismaModule, FinesModule, AuthModule, UsersModule, PaymentsModule],
})
export class AppModule {}