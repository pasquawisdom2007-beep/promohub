import { NotificationType } from '@prisma/client'; import { db } from '../db/client.js';
export function notify(input:{userId:string;type:NotificationType;title:string;body:string}){return db.notification.create({data:input});}
