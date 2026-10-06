import { describe,expect,it } from 'vitest';
import { shouldRetryPosting } from '../src/services/telegram-ops.js';
import { logEvent } from '../src/services/observability.js';
import { internalReference } from '../src/services/phase3-payments.js';
import { requireValidWebhookSignature } from '../src/services/payments.js';
describe('phase 3 hardening',()=>{it('limits posting retries',()=>{expect(shouldRetryPosting(0,3)).toBe(true);expect(shouldRetryPosting(3,3)).toBe(false);});it('generates internal payment references',()=>{expect(internalReference()).toMatch(/^PAY-/);expect(internalReference('REF')).toMatch(/^REF-/);});it('rejects invalid payment webhook signatures',()=>{expect(()=>requireValidWebhookSignature({},'invalid','expected')).toThrow();});it('does not emit secret-like fields in structured logs',()=>{const original=console.log;let output='';console.log=(value:string)=>{output=value;};logEvent('test',{token:'hidden',amount:10});console.log=original;expect(output).not.toContain('hidden');expect(output).toContain('amount');});});
