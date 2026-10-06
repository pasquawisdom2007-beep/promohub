/*
  Warnings:

  - Added the required column `updatedAt` to the `Placement` table without a default value. This is not possible if the table is not empty.
  - Added the required column `targetType` to the `Rating` table without a default value. This is not possible if the table is not empty.
  - Added the required column `targetUserId` to the `Rating` table without a default value. This is not possible if the table is not empty.
  - Added the required column `qualifyingEvent` to the `Referral` table without a default value. This is not possible if the table is not empty.
  - Added the required column `type` to the `Referral` table without a default value. This is not possible if the table is not empty.
  - Added the required column `placementId` to the `TrackingLink` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `Withdrawal` table without a default value. This is not possible if the table is not empty.

*/
-- CreateTable
CREATE TABLE "AgentOpportunity" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "campaignId" TEXT NOT NULL,
    "agentId" TEXT NOT NULL,
    "reward" INTEGER NOT NULL,
    "deadline" DATETIME,
    "status" TEXT NOT NULL DEFAULT 'OFFERED',
    "acceptedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT,
    CONSTRAINT "AgentOpportunity_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "AgentOpportunity_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "Agent" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "AgentOpportunity_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "AgentPlacementSubmission" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "campaignId" TEXT NOT NULL,
    "agentId" TEXT NOT NULL,
    "placementId" TEXT,
    "communityName" TEXT NOT NULL,
    "communityType" TEXT NOT NULL,
    "information" TEXT NOT NULL,
    "proofUrl" TEXT,
    "notes" TEXT,
    "status" TEXT NOT NULL DEFAULT 'SUBMITTED',
    "verification" TEXT NOT NULL DEFAULT 'PENDING',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "userId" TEXT,
    CONSTRAINT "AgentPlacementSubmission_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "AgentPlacementSubmission_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "Agent" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "AgentPlacementSubmission_placementId_fkey" FOREIGN KEY ("placementId") REFERENCES "Placement" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "AgentPlacementSubmission_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "CampaignAllocation" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "campaignId" TEXT NOT NULL,
    "placementId" TEXT,
    "recipientId" TEXT NOT NULL,
    "recipientType" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "idempotencyKey" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "CampaignAllocation_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "ClickEvent" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "campaignId" TEXT NOT NULL,
    "trackingLinkId" TEXT NOT NULL,
    "placementId" TEXT NOT NULL,
    "occurredAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userAgent" TEXT,
    "source" TEXT,
    CONSTRAINT "ClickEvent_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ClickEvent_trackingLinkId_fkey" FOREIGN KEY ("trackingLinkId") REFERENCES "TrackingLink" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Agent" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "contactInformation" TEXT,
    "country" TEXT,
    "areas" TEXT,
    "platformType" TEXT,
    "acceptedCategories" TEXT,
    "paymentDetails" TEXT,
    "availability" TEXT NOT NULL DEFAULT 'AVAILABLE',
    CONSTRAINT "Agent_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Agent" ("id", "userId") SELECT "id", "userId" FROM "Agent";
DROP TABLE "Agent";
ALTER TABLE "new_Agent" RENAME TO "Agent";
CREATE UNIQUE INDEX "Agent_userId_key" ON "Agent"("userId");
CREATE TABLE "new_Community" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "publisherId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "platform" TEXT NOT NULL,
    "audienceSize" INTEGER,
    "communityType" TEXT,
    "category" TEXT,
    "description" TEXT,
    "targetLocation" TEXT,
    "memberCountVerified" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "Community_publisherId_fkey" FOREIGN KEY ("publisherId") REFERENCES "Publisher" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Community" ("audienceSize", "id", "name", "platform", "publisherId") SELECT "audienceSize", "id", "name", "platform", "publisherId" FROM "Community";
DROP TABLE "Community";
ALTER TABLE "new_Community" RENAME TO "Community";
CREATE TABLE "new_Placement" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "campaignId" TEXT NOT NULL,
    "communityId" TEXT NOT NULL,
    "publisherId" TEXT,
    "agentId" TEXT,
    "price" INTEGER NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "scheduledAt" DATETIME,
    "postedAt" DATETIME,
    "telegramMessageId" TEXT,
    "destination" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Placement_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Placement_communityId_fkey" FOREIGN KEY ("communityId") REFERENCES "Community" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Placement_publisherId_fkey" FOREIGN KEY ("publisherId") REFERENCES "Publisher" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "Placement_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "Agent" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_Placement" ("campaignId", "communityId", "id", "scheduledAt", "status") SELECT "campaignId", "communityId", "id", "scheduledAt", "status" FROM "Placement";
DROP TABLE "Placement";
ALTER TABLE "new_Placement" RENAME TO "Placement";
CREATE INDEX "Placement_publisherId_createdAt_idx" ON "Placement"("publisherId", "createdAt");
CREATE TABLE "new_Publisher" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "category" TEXT,
    "description" TEXT,
    "audienceLocation" TEXT,
    "advertisingPrice" INTEGER NOT NULL DEFAULT 0,
    "maxAdsPerDay" INTEGER NOT NULL DEFAULT 1,
    "acceptedCategories" TEXT,
    "approvalMode" TEXT NOT NULL DEFAULT 'MANUAL',
    "availability" TEXT NOT NULL DEFAULT 'AVAILABLE',
    CONSTRAINT "Publisher_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Publisher" ("id", "userId") SELECT "id", "userId" FROM "Publisher";
DROP TABLE "Publisher";
ALTER TABLE "new_Publisher" RENAME TO "Publisher";
CREATE UNIQUE INDEX "Publisher_userId_key" ON "Publisher"("userId");
CREATE TABLE "new_Rating" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "campaignId" TEXT NOT NULL,
    "raterId" TEXT NOT NULL,
    "targetUserId" TEXT NOT NULL,
    "targetType" TEXT NOT NULL,
    "communityQuality" INTEGER,
    "audienceRelevance" INTEGER,
    "performance" INTEGER,
    "score" INTEGER NOT NULL,
    "comment" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Rating_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Rating_raterId_fkey" FOREIGN KEY ("raterId") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Rating_targetUserId_fkey" FOREIGN KEY ("targetUserId") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Rating" ("campaignId", "comment", "createdAt", "id", "raterId", "score") SELECT "campaignId", "comment", "createdAt", "id", "raterId", "score" FROM "Rating";
DROP TABLE "Rating";
ALTER TABLE "new_Rating" RENAME TO "Rating";
CREATE UNIQUE INDEX "Rating_campaignId_raterId_targetUserId_key" ON "Rating"("campaignId", "raterId", "targetUserId");
CREATE TABLE "new_Referral" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "referrerId" TEXT NOT NULL,
    "refereeId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "qualifyingEvent" TEXT NOT NULL,
    "reward" INTEGER NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "paidAt" DATETIME,
    CONSTRAINT "Referral_referrerId_fkey" FOREIGN KEY ("referrerId") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Referral_refereeId_fkey" FOREIGN KEY ("refereeId") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Referral" ("createdAt", "id", "refereeId", "referrerId", "reward") SELECT "createdAt", "id", "refereeId", "referrerId", "reward" FROM "Referral";
DROP TABLE "Referral";
ALTER TABLE "new_Referral" RENAME TO "Referral";
CREATE UNIQUE INDEX "Referral_referrerId_refereeId_qualifyingEvent_key" ON "Referral"("referrerId", "refereeId", "qualifyingEvent");
CREATE TABLE "new_TrackingLink" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "campaignId" TEXT NOT NULL,
    "placementId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "destination" TEXT NOT NULL,
    "clicks" INTEGER NOT NULL DEFAULT 0,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "TrackingLink_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "TrackingLink_placementId_fkey" FOREIGN KEY ("placementId") REFERENCES "Placement" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_TrackingLink" ("campaignId", "clicks", "createdAt", "destination", "id", "token") SELECT "campaignId", "clicks", "createdAt", "destination", "id", "token" FROM "TrackingLink";
DROP TABLE "TrackingLink";
ALTER TABLE "new_TrackingLink" RENAME TO "TrackingLink";
CREATE UNIQUE INDEX "TrackingLink_placementId_key" ON "TrackingLink"("placementId");
CREATE UNIQUE INDEX "TrackingLink_token_key" ON "TrackingLink"("token");
CREATE TABLE "new_Withdrawal" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "paymentReference" TEXT,
    "adminNote" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Withdrawal_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Withdrawal" ("amount", "createdAt", "id", "status", "userId") SELECT "amount", "createdAt", "id", "status", "userId" FROM "Withdrawal";
DROP TABLE "Withdrawal";
ALTER TABLE "new_Withdrawal" RENAME TO "Withdrawal";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

-- CreateIndex
CREATE UNIQUE INDEX "AgentOpportunity_campaignId_agentId_key" ON "AgentOpportunity"("campaignId", "agentId");

-- CreateIndex
CREATE UNIQUE INDEX "CampaignAllocation_idempotencyKey_key" ON "CampaignAllocation"("idempotencyKey");

-- CreateIndex
CREATE INDEX "CampaignAllocation_campaignId_recipientType_idx" ON "CampaignAllocation"("campaignId", "recipientType");

-- CreateIndex
CREATE INDEX "ClickEvent_campaignId_occurredAt_idx" ON "ClickEvent"("campaignId", "occurredAt");
