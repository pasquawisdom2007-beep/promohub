import { Bot, Context, InlineKeyboard } from 'grammy';
import { Objective, Platform } from '@prisma/client';
import { env } from '../config/env.js';
import { db } from '../db/client.js';
import { createCampaign, transitionCampaign } from '../services/campaigns.js';
import { upsertTelegramUser } from '../services/users.js';

type CampaignDraft = {
  step: 'title' | 'advertisementText' | 'destination' | 'platform' | 'objective' | 'category' | 'targetLocation' | 'budget';
  title?: string;
  advertisementText?: string;
  destination?: string;
  platform?: Platform;
  objective?: Objective;
  category?: string;
  targetLocation?: string;
};

const drafts = new Map<string, CampaignDraft>();

const menu = () => new InlineKeyboard()
  .text('Promote', 'promote').text('Become a Publisher', 'publisher').row()
  .text('WhatsApp Agent', 'agent').row()
  .text('My Dashboard', 'dashboard').text('Wallet', 'wallet').row()
  .text('How It Works', 'how').row()
  .text('Support', 'support');

function isCommand(text: string) {
  return text.startsWith('/');
}

function promptForDraft(ctx: Context, draft: CampaignDraft) {
  const prompts: Record<CampaignDraft['step'], string> = {
    title: 'What is the campaign title?',
    advertisementText: 'Send the advertisement text that should be promoted.',
    destination: 'Send the destination URL (for example, https://example.com).',
    platform: 'Choose the target platform: TELEGRAM_CHANNEL, TELEGRAM_GROUP, WHATSAPP_CHANNEL, WHATSAPP_GROUP, or WEBSITE.',
    objective: 'Choose the campaign objective: MEMBERS, VIEWS, CLICKS, or EXPOSURE.',
    category: 'What category is this campaign for? Reply with a category or “skip”.',
    targetLocation: 'What country or target location should this campaign reach? Reply with a location or “skip”.',
    budget: `What is the campaign budget in minor currency units? Minimum: ${env.MIN_CAMPAIGN_BUDGET}.`,
  };
  return ctx.reply(prompts[draft.step]);
}

async function beginCampaign(ctx: Context) {
  const telegramId = ctx.from?.id;
  if (!telegramId) return;
  const draft: CampaignDraft = { step: 'title' };
  drafts.set(String(telegramId), draft);
  await ctx.reply('Let’s create your advertising campaign. Send /cancel at any time to stop.');
  return promptForDraft(ctx, draft);
}

async function handleCampaignInput(ctx: Context, text: string) {
  const telegramId = ctx.from?.id;
  if (!telegramId) return false;
  const key = String(telegramId);
  const draft = drafts.get(key);
  if (!draft) return false;

  if (text === '/cancel') {
    drafts.delete(key);
    await ctx.reply('Campaign creation cancelled.');
    return true;
  }
  if (isCommand(text)) {
    await ctx.reply('Please finish the current campaign step or use /cancel.');
    return true;
  }

  switch (draft.step) {
    case 'title': draft.title = text; draft.step = 'advertisementText'; break;
    case 'advertisementText': draft.advertisementText = text; draft.step = 'destination'; break;
    case 'destination':
      try { new URL(text); } catch { await ctx.reply('That URL is not valid. Please send a complete URL beginning with https:// or http://.'); return true; }
      draft.destination = text; draft.step = 'platform'; break;
    case 'platform': {
      const value = text.toUpperCase() as Platform;
      if (!Object.values(Platform).includes(value)) { await ctx.reply(`Invalid platform. Choose one of: ${Object.values(Platform).join(', ')}.`); return true; }
      draft.platform = value; draft.step = 'objective'; break;
    }
    case 'objective': {
      const value = text.toUpperCase() as Objective;
      if (!Object.values(Objective).includes(value)) { await ctx.reply(`Invalid objective. Choose one of: ${Object.values(Objective).join(', ')}.`); return true; }
      draft.objective = value; draft.step = 'category'; break;
    }
    case 'category': draft.category = text.toLowerCase() === 'skip' ? undefined : text; draft.step = 'targetLocation'; break;
    case 'targetLocation': draft.targetLocation = text.toLowerCase() === 'skip' ? undefined : text; draft.step = 'budget'; break;
    case 'budget': {
      const budget = Number(text);
      if (!Number.isSafeInteger(budget) || budget < env.MIN_CAMPAIGN_BUDGET) { await ctx.reply(`Budget must be a whole number of at least ${env.MIN_CAMPAIGN_BUDGET}.`); return true; }
      try {
        const user = await upsertTelegramUser({
          telegramId: key,
          username: ctx.from?.username,
          firstName: ctx.from?.first_name ?? 'User',
          lastName: ctx.from?.last_name,
        });
        const advertiser = await db.advertiser.upsert({ where: { userId: user.id }, create: { userId: user.id }, update: {} });
        const campaign = await createCampaign({
          advertiserId: advertiser.id,
          title: draft.title!,
          destination: draft.destination!,
          description: draft.advertisementText!,
          advertisementText: draft.advertisementText!,
          budget,
          platform: draft.platform!,
          objective: draft.objective!,
          category: draft.category,
          targetLocation: draft.targetLocation,
        });
        await transitionCampaign(campaign.id, 'PENDING_REVIEW');
        drafts.delete(key);
        await ctx.reply(`Campaign ${campaign.publicId} was submitted for review. An admin must approve it before it can be matched with publishers.`);
      } catch (error) {
        console.error('Campaign creation failed', error);
        await ctx.reply('I could not create that campaign. Please check the details and try again with /start.');
      }
      return true;
    }
  }
  await promptForDraft(ctx, draft);
  return true;
}

export function createBot() {
  const bot = new Bot(env.TELEGRAM_BOT_TOKEN);

  bot.command('start', async (ctx) => {
    const from = ctx.from;
    if (!from) return;
    const user = await upsertTelegramUser({ telegramId: String(from.id), username: from.username, firstName: from.first_name, lastName: from.last_name });
    await ctx.reply(`PROMOHUB\n\nAdvertise anywhere. Grow everywhere.\n\nWelcome, ${user.firstName}. Choose an option below.`, { reply_markup: menu() });
  });

  bot.command('menu', (ctx) => ctx.reply('PROMOHUB menu', { reply_markup: menu() }));
  bot.command('help', (ctx) => ctx.reply('PROMOHUB helps advertisers create campaigns, publishers offer communities, and agents accept approved marketplace opportunities. Use /start to open the menu or /cancel to stop a campaign form.'));
  bot.command('cancel', async (ctx) => {
    if (ctx.from) drafts.delete(String(ctx.from.id));
    await ctx.reply('Current action cancelled.');
  });

  bot.callbackQuery('promote', beginCampaign);
  bot.callbackQuery('publisher', (ctx) => ctx.answerCallbackQuery('Publisher onboarding will be added next.'));
  bot.callbackQuery('agent', (ctx) => ctx.answerCallbackQuery('Agent onboarding will be added next.'));
  bot.callbackQuery('dashboard', (ctx) => ctx.answerCallbackQuery('Dashboard will be added next.'));
  bot.callbackQuery('wallet', (ctx) => ctx.answerCallbackQuery('Wallet view will be added next.'));
  bot.callbackQuery('how', (ctx) => ctx.answerCallbackQuery('Create a campaign, pass moderation, then reach matched publishers.'));
  bot.callbackQuery('support', (ctx) => ctx.answerCallbackQuery('Support tickets will be added next.'));
  bot.on('message:text', async (ctx) => { await handleCampaignInput(ctx, ctx.message.text.trim()); });

  bot.catch((err) => console.error('Telegram bot error', err));
  return bot;
}
