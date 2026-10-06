import { createBot } from './bot/start.js'; import { env } from './config/env.js';
const bot=createBot(); if(env.NODE_ENV!=='test'){bot.start({onStart:info=>console.log(`PROMOHUB bot started as @${info.username}`)});}
