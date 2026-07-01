/*
  Warnings:

  - A unique constraint covering the columns `[fineId]` on the table `Payment` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[email]` on the table `User` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `email` to the `User` table without a default value. This is not possible if the table is not empty.

*/
-- AlterEnum
ALTER TYPE "Role" ADD VALUE 'DRIVER';

-- AlterTable
ALTER TABLE "Fine" ADD COLUMN     "driverLicense" TEXT,
ADD COLUMN     "driverName" TEXT,
ADD COLUMN     "notes" TEXT,
ADD COLUMN     "offenseDate" TEXT,
ADD COLUMN     "offenseLocation" TEXT,
ADD COLUMN     "vehicleNumber" TEXT;

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "email" TEXT NOT NULL,
ADD COLUMN     "license" TEXT,
ADD COLUMN     "phone" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "Payment_fineId_key" ON "Payment"("fineId");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_fineId_fkey" FOREIGN KEY ("fineId") REFERENCES "Fine"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
