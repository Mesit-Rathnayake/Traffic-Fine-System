import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { FinesModule } from './fines/fines.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { PaymentsModule } from './payments/payments.module';
import { AdminModule } from './admin/admin.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { EmailModule } from './email/email.module';

@Module({
  imports: [
    PrismaModule,
    FinesModule,
    AuthModule,
    UsersModule,
    PaymentsModule,
    AdminModule,
    EmailModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
