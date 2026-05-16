const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

(async () => {
  try {
    const existing = await prisma.fine.findUnique({ where: { referenceNumber: 'REF123' } });
    if (existing) {
      console.log('Fine already exists:', existing);
      process.exit(0);
    }

    const fine = await prisma.fine.create({
      data: {
        referenceNumber: 'REF123',
        category: 'SPEEDING',
        amount: 100,
        officerId: 1,
        district: 'Central',
      },
    });

    console.log('Created fine:', fine);
  } catch (e) {
    console.error('Error creating fine:', e);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
})();
