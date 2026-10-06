import { db } from '../db/client.js';
export async function recordPostingAttempt(input:{placementId:string;status:string;error?:string;providerMessageId?:string}){const last=await db.postingAttempt.findFirst({where:{placementId:input.placementId},orderBy:{attemptNumber:'desc'}});return db.postingAttempt.create({data:{placementId:input.placementId,attemptNumber:(last?.attemptNumber??0)+1,status:input.status,error:input.error,providerMessageId:input.providerMessageId}});}
export function shouldRetryPosting(attempts:number,maxAttempts=3){return attempts<maxAttempts;}
