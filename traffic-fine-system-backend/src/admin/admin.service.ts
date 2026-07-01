import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  // 🔥 Total successful payment collections
  async getTotalCollections() {
    const result = await this.prisma.payment.aggregate({
      _sum: {
        amount: true,
      },
      where: {
        status: 'SUCCESS',
      },
    });

    return {
      total: result._sum.amount || 0,
    };
  }

  // 🔥 District-wise collections
  async getDistrictCollections() {
    const payments = await this.prisma.payment.findMany({
      where: { status: 'SUCCESS' },
      select: { fineId: true, amount: true },
    });

    const fineIds = Array.from(new Set(payments.map((p) => p.fineId)));
    const fines = await this.prisma.fine.findMany({
      where: { id: { in: fineIds } },
      select: { id: true, district: true },
    });

    const fineDistrictMap: Record<number, string> = {};
    fines.forEach((f) => {
      fineDistrictMap[f.id] = f.district || 'UNKNOWN';
    });

    const map: Record<string, number> = {};
    payments.forEach((payment) => {
      const district = fineDistrictMap[payment.fineId] || 'UNKNOWN';
      map[district] = (map[district] || 0) + payment.amount;
    });

    return Object.keys(map).map((district) => ({
      district,
      total: map[district],
    }));
  }

  // 🔥 Fine category breakdown
  async getCategoryBreakdown() {
    const fines = await this.prisma.fine.findMany({
      select: { id: true, category: true },
    });
    const payments = await this.prisma.payment.findMany({
      where: { status: 'SUCCESS' },
      select: { fineId: true },
    });

    const paidFineIds = new Set(payments.map((p) => p.fineId));
    const map: Record<string, number> = {};

    fines.forEach((fine) => {
      const category = fine.category;
      if (!map[category]) map[category] = 0;
      if (paidFineIds.has(fine.id)) map[category]++;
    });

    return Object.keys(map).map((category) => ({
      category,
      count: map[category],
    }));
  }

  async getUsersList(limit = 20) {
    const safeLimit = Number.isFinite(limit) ? Math.min(Math.max(limit, 1), 100) : 20;

    return this.prisma.user.findMany({
      orderBy: { id: 'desc' },
      take: safeLimit,
      select: {
        id: true,
        name: true,
        username: true,
        email: true,
        role: true,
      },
    });
  }

  async getFinesList(limit = 20) {
    const safeLimit = Number.isFinite(limit) ? Math.min(Math.max(limit, 1), 100) : 20;

    return this.prisma.fine.findMany({
      orderBy: { id: 'desc' },
      take: safeLimit,
      select: {
        id: true,
        referenceNumber: true,
        category: true,
        amount: true,
        status: true,
        district: true,
        officerId: true,
        driverName: true,
        driverLicense: true,
        vehicleNumber: true,
        offenseDate: true,
        offenseLocation: true,
        notes: true,
      },
    });
  }

  async getPaymentsList(limit = 20) {
    const safeLimit = Number.isFinite(limit) ? Math.min(Math.max(limit, 1), 100) : 20;

    return this.prisma.payment.findMany({
      orderBy: { createdAt: 'desc' },
      take: safeLimit,
      select: {
        id: true,
        fineId: true,
        amount: true,
        status: true,
        createdAt: true,
        fine: {
          select: {
            referenceNumber: true,
            category: true,
            district: true,
          },
        },
      },
    });
  }
}
