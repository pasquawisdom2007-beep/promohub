import { Bot, InlineKeyboard } from 'grammy';
import { env } from '../config/env.js';
import { upsertTelegramUser } from '../services/users.js';

export function createBot() {
  const bot = new Bot(env.TELEGRAM_BOT_TOKEN);
  bot.command('start', async (ctx) => {
    const from = ctx.from;
    if (!from) return;
    const user = await upsertTelegramUser({
      telegramId: String(from.id), username: from.username, firstName: from.first_name, lastName: from.last_name,
    });
    await ctx.reply(`PROMOHUB\n\nAdvertise anywhere. Grow everywhere.\n\nWelcome, ${user.firstName}.`, {
      reply_markup: new InlineKeyboard()
        .text('🚀 Promote', 'promote').text('📢 Become a Publisher', 'publisher').row()
        .text('🟢 Become a WhatsApp Agent', 'agent').row()
        .text('📊 My Dashboard', 'dashboard').text('💰 Wallet', 'wallet').row()
        .text('📚 How It Works', 'how').row().text('🆘 Support', 'support'),
    });
  });
  bot.callbackQuery('promote', (ctx) => ctx.answerCallbackQuery('Campaign creation flow is ready for Phase 1 services.'));
  bot.catch((err) => console.error('Telegram bot error', err));
  return bot;
}
