import { ReferralStatus, ReferralType } from '@prisma/client'; import { db } from '../db/client.js';
export async function createReferral(input:{referrerId:string;refereeId:string;type:ReferralType;qualifyingEvent:string;reward:number}){return db.referral.create({data:input});}
export async function qualifyReferral(id:string){return db.referral.updateMany({where:{id,status:ReferralStatus.PENDING},data:{status:ReferralStatus.QUALIFIED}});}
