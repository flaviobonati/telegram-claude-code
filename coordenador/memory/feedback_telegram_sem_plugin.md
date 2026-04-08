---
name: Telegram via Vercel webhook + SSH — setup definitivo
description: INVIOLAVEL - Telegram funciona via Vercel webhook que faz SSH e tmux send-keys. NUNCA usar plugin. NUNCA polling.
type: feedback
---

## Setup DEFINITIVO do Telegram

**Receber**: Telegram → Vercel webhook → SSH root na VPS → `tmux send-keys -t fabrica` → msg chega instantânea no terminal
**Enviar**: `node /opt/mitra-factory/tg.mjs "mensagem"` → curl API direta

## Componentes
- Vercel project: `vercel-telegram-webhook` (scope: flavio-mitralabios-projects)
- Webhook endpoint: `/api/webhook`
- SSH key: `/opt/mitra-factory/.ssh/vercel_webhook` (public key em /root/.ssh/authorized_keys)
- Bot token: 8542084519:AAH...
- Allowed user: 8748910578

## NUNCA MAIS
- Plugin do Telegram (desinstalado permanentemente)
- Polling via API (telegram_check.mjs)
- Cron pra checar mensagens
- --channels no Claude Code
- Bot da comunidade (claude-code-telegram)

## Iniciar Claude Code
```
tmux new -s fabrica
export PATH="$HOME/.bun/bin:$PATH"
claude
```
SEM --channels. NUNCA.

**Why:** 2 dias de sofrimento com plugin que perdia msgs. Webhook + SSH + tmux send-keys é instantâneo e 100% confiável.
