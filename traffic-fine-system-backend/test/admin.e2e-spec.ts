import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AdminModule } from '../src/admin/admin.module';
import { PrismaService } from '../src/prisma/prisma.service';
import { JwtAuthGuard } from '../src/auth/jwt-auth.guard';
import { RolesGuard } from '../src/auth/roles.guard';

describe('AdminController (e2e)', () => {
  let app: INestApplication;

  const prismaMock = {
    payment: {
      aggregate: jest.fn(),
      findMany: jest.fn(),
    },
    fine: {
      findMany: jest.fn(),
    },
  };

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AdminModule],
    })
      .overrideProvider(PrismaService)
      .useValue(prismaMock)
      .overrideGuard(JwtAuthGuard)
      .useValue({ canActivate: () => true })
      .overrideGuard(RolesGuard)
      .useValue({ canActivate: () => true })
      .compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterEach(async () => {
    jest.clearAllMocks();
    await app.close();
  });

  it('GET /admin/total-collections', async () => {
    prismaMock.payment.aggregate.mockResolvedValue({
      _sum: { amount: 1250 },
    });

    await request(app.getHttpServer())
      .get('/admin/total-collections')
      .expect(200)
      .expect({ total: 1250 });
  });

  it('GET /admin/district-collections', async () => {
    prismaMock.payment.findMany.mockResolvedValue([
      { fineId: 1, amount: 500 },
      { fineId: 2, amount: 750 },
    ]);
    prismaMock.fine.findMany.mockResolvedValue([
      { id: 1, district: 'Colombo' },
      { id: 2, district: 'Kandy' },
    ]);

    await request(app.getHttpServer())
      .get('/admin/district-collections')
      .expect(200)
      .expect([
        { district: 'Colombo', total: 500 },
        { district: 'Kandy', total: 750 },
      ]);
  });

  it('GET /admin/category-breakdown', async () => {
    prismaMock.fine.findMany.mockResolvedValue([
      { id: 1, category: 'Speeding' },
      { id: 2, category: 'Parking' },
      { id: 3, category: 'Speeding' },
    ]);
    prismaMock.payment.findMany.mockResolvedValue([
      { fineId: 1 },
      { fineId: 3 },
    ]);

    await request(app.getHttpServer())
      .get('/admin/category-breakdown')
      .expect(200)
      .expect([
        { category: 'Speeding', count: 2 },
        { category: 'Parking', count: 0 },
      ]);
  });
});
