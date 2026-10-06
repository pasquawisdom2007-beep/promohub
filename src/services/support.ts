import { TicketCategory, TicketPriority } from '@prisma/client'; import { db } from '../db/client.js';
export function createTicket(input:{userId:string;category:TicketCategory;subject:string;message:string;priority?:TicketPriority}){if(!input.subject.trim()||!input.message.trim())throw new Error('Subject and message are required');return db.supportTicket.create({data:input});}
