---
name: Webhook Telegram via arquivo (base64 + SSH)
description: Mensagens do Flavio chegam como pointer pra arquivo, nao texto cru. Read tool pra ler.
type: feedback
---

A partir de 05/04/2026, o webhook Vercel do Telegram:
1. Recebe POST do Telegram
2. Codifica msg.text em base64 (zero risco de escape)
3. SSH na VPS → `echo base64 | base64 -d > /opt/mitra-factory/telegram_msgs/msg_{ts}_{id}.txt`
4. `tmux send-keys -t fabrica 'Telegram de Flávio (ler arquivo): /caminho/msg_*.txt'`

**Como processar as mensagens:**
- Mensagem chega no formato: `Telegram de Flávio (ler arquivo): /opt/mitra-factory/telegram_msgs/msg_YYYY-MM-DDTHH-MM-SS-sssZ_NNN.txt`
- Usar `Read` tool pra ler o arquivo
- O texto integral esta la, com qualquer caractere especial

**Historico:**
- Webhook antigo: `tmux send-keys 'Telegram de Flávio: [texto cru]'` — quebrava com unicode bullets (⁃), braces {...}, etc
- Webhook novo: arquivo + pointer. Funciona com qualquer texto.

**URL do webhook no Telegram Bot:**
- Producao: `https://vercel-telegram-webhook-flavio-mitralabios-projects.vercel.app/api/webhook`
- Setar via: `curl -X POST "https://api.telegram.org/bot{TOKEN}/setWebhook" -d "url=..."`
- Bot token: `8542084519:AAH7uC99u76NJISICyIGjM_n8XZidJbtZh0`

**Incidente:** Deploy-em-preview-url. O bot estava apontando pra deployment especifico (-p16l0b1l9-) em vez do alias de producao. Correcao: setWebhook para o alias de producao.
