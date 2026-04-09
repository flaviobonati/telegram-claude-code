# Telegram <-> Claude Code (Bidirectional)

Talk to [Claude Code](https://docs.anthropic.com/en/docs/claude-code) from your phone via Telegram. Claude reads your message, processes it, and replies back to Telegram. Latency: ~1-3 seconds.

```
                        TELEGRAM BIDIRECTIONAL FLOW

  [Phone/Telegram]                                          [VPS / Claude Code]
       |                                                           |
       |  1. You type a message                                    |
       |  ───────────────────────>  [Telegram Bot API]             |
       |                                 |                         |
       |                     2. Webhook fires                      |
       |                                 |                         |
       |                          [Vercel Function]                |
       |                                 |                         |
       |                     3. SSH into VPS                       |
       |                        - writes msg to file (base64)      |
       |                        - tmux send-keys "ler arquivo X"   |
       |                                 |                         |
       |                                 └──────────────────> [Claude Code]
       |                                                      reads file,
       |                                                      processes,
       |                                                      runs:
       |                                                      node tg.mjs "reply"
       |                                                           |
       |  <────────────────────────────────────────────────────────┘
       |  4. You receive the reply on Telegram
```

## Prerequisites

- **Claude Code** running on a Linux VPS inside a **tmux** session
- **Node.js 18+** on the VPS (for `tg.mjs` and native `fetch`)
- **Vercel account** (free tier works fine)
- **Telegram Bot** created via [@BotFather](https://t.me/BotFather)
- **SSH access** from Vercel to your VPS (key-based auth)

---

## Part 1: Send from Claude Code to Telegram (`tg.mjs`)

This script lets Claude Code send text messages and photos to your Telegram chat.

### Setup

1. Copy `tg.mjs` to your VPS (e.g., `/opt/your-project/tg.mjs`)

2. Set environment variables (or edit the file directly):
   ```bash
   export BOT_TOKEN="123456:ABC-DEF..."    # from @BotFather
   export CHAT_ID="987654321"              # your Telegram user/chat ID
   ```

3. To find your `CHAT_ID`:
   - Send any message to your bot
   - Visit `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates`
   - Look for `"chat":{"id": 987654321}` in the response

### Usage

```bash
# Send a text message
node tg.mjs "Deploy completed successfully"

# Send a photo with caption
node tg.mjs "Here's the screenshot" /tmp/screenshot.png
```

### From Claude Code (CLAUDE.md instruction)

Add to your project's `CLAUDE.md`:

```markdown
To notify the human via Telegram, run:
  node /path/to/tg.mjs "your message here"

To send a screenshot:
  node /path/to/tg.mjs "caption" /path/to/image.png
```

---

## Part 2: Receive from Telegram into Claude Code (Vercel Webhook)

When you send a message on Telegram, a Vercel serverless function receives it, SSHes into your VPS, writes the message to a file, and injects a pointer into Claude Code's tmux session.

### Deploy to Vercel

1. Clone this repo (or copy `api/webhook.js`, `vercel.json`, `package.json`):
   ```bash
   git clone https://github.com/mitra-ai/telegram-claude-code.git
   cd telegram-claude-code
   ```

2. Install the [Vercel CLI](https://vercel.com/docs/cli) and deploy:
   ```bash
   npm i -g vercel
   vercel
   ```

3. Set environment variables in the Vercel dashboard (Settings > Environment Variables):

   | Variable | Description |
   |----------|-------------|
   | `SSH_HOST` | Your VPS IP address |
   | `SSH_PORT` | SSH port (default: `22`) |
   | `SSH_USER` | SSH user (default: `root`) |
   | `SSH_PRIVATE_KEY` | Full contents of your SSH private key |
   | `TELEGRAM_ALLOWED_USER` | Your Telegram user ID (restricts who can send) |
   | `TMUX_SESSION` | tmux session name where Claude runs (default: `main`) |
   | `MSG_DIR` | Directory on VPS for message files (default: `/tmp/telegram_msgs`) |

4. Redeploy after setting env vars:
   ```bash
   vercel --prod
   ```

Your webhook URL will be: `https://your-project.vercel.app/api/webhook`

---

## Part 3: Register the Telegram Webhook

Tell Telegram to send all bot updates to your Vercel function:

```bash
curl -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://your-project.vercel.app/api/webhook"}'
```

Verify it worked:
```bash
curl "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getWebhookInfo"
```

You should see `"url": "https://your-project.vercel.app/api/webhook"` and `"pending_update_count": 0`.

---

## How Claude Code Uses This

### Receiving messages

When a Telegram message arrives, the webhook writes it to a file like:
```
/tmp/telegram_msgs/msg_2025-01-15T14-30-00-000Z_12345.txt
```

Then it injects into Claude's tmux session:
```
ler arquivo /tmp/telegram_msgs/msg_2025-01-15T14-30-00-000Z_12345.txt
```

Claude Code reads the file, processes the request, and responds.

### Sending messages

Claude Code runs `node tg.mjs "message"` to reply. Add this to your `CLAUDE.md`:

```markdown
## Telegram Communication

- To send a message: `node /path/to/tg.mjs "message"`
- To send a screenshot: `node /path/to/tg.mjs "caption" /path/to/file.png`
- Incoming messages arrive as: `ler arquivo /path/to/msg_*.txt`
- When you see "ler arquivo <path>", read that file to get the human's message
```

---

## What to Customize

| Item | Where | What to change |
|------|-------|----------------|
| Bot token | `tg.mjs` or env `BOT_TOKEN` | Your @BotFather token |
| Chat ID | `tg.mjs` or env `CHAT_ID` | Your Telegram chat ID |
| SSH credentials | Vercel env vars | Your VPS connection details |
| tmux session name | Vercel env `TMUX_SESSION` | Name of your tmux session |
| Message directory | Vercel env `MSG_DIR` | Where to store message files |
| Pointer text | `api/webhook.js` line with `pointer` | The text injected into tmux |
| Allowed user | Vercel env `TELEGRAM_ALLOWED_USER` | Restrict to your Telegram ID |

---

## Security Notes

- **SSH_PRIVATE_KEY**: Generate a dedicated key pair for this purpose. Never reuse your main key.
- **TELEGRAM_ALLOWED_USER**: Always set this to restrict who can send commands to your Claude instance.
- **Vercel env vars**: Use Vercel's encrypted environment variables, never commit secrets to the repo.
- The webhook always returns `200` to Telegram (even on errors) to prevent retry storms.

---

## Latency

End-to-end is typically **1-3 seconds**:
- Telegram to Vercel: ~200ms
- Vercel SSH to VPS + file write: ~500ms-1s
- tmux injection: instant
- Claude processing: depends on the task
- `tg.mjs` reply: ~200ms

---

## Troubleshooting

- **Webhook not receiving**: Check `getWebhookInfo` for errors. Ensure the URL is correct and Vercel is deployed.
- **SSH connection failed**: Verify `SSH_PRIVATE_KEY` is the full key (including `-----BEGIN/END-----` lines). Check VPS firewall allows Vercel IPs.
- **tmux session not found**: Ensure Claude Code is running in a tmux session with the name matching `TMUX_SESSION`.
- **Message not delivered**: Check Vercel function logs (`vercel logs`) for errors.

---

## Mitra Factory — system prompts dos sub-agentes

A pasta `coordenador/` deste repositório guarda o estado oficial dos prompts e da memória da Mitra Factory — o ciclo autônomo `Pesquisador → Dev → QA` que produz software production-grade dirigido por Claude Code.

```
coordenador/
├── README.md               ← quem é o coordenador, o que ele lê, como ele spawna
├── coordinator.md          ← prompt atemporal do coordenador (fonte canônica)
└── sub-agents/
    ├── pesquisador/        ← README + researcher.md
    ├── dev/                ← README + dev.md (regras da fábrica; lê system_prompt oficial do Mitra antes de codar)
    └── qa/                 ← README + qa.md (self-contained, define sparkle) + qa_report_template.md
mitra-agent-minimal/        ← vendorizado de mpbonatti/mitra-agent-minimal
├── system_prompt.md        ← system prompt oficial da plataforma Mitra (lido pelo Dev)
├── template/               ← template React + backend mitra-sdk (Chart.tsx, ui/*, lib/mitra-auth.ts)
├── AGENTS.md
└── CLAUDE.md
scripts/
└── sync-mitra-agent-minimal.sh  ← puxa última versão do repo privado mpbonatti/mitra-agent-minimal
SETUP.md                     ← instruções pra ligar a fábrica numa VPS limpa
```

Quem clonar este repo recebe:

1. **O webhook bidirecional Telegram ↔ Claude Code** (raiz do repo, partes 1-3 acima).
2. **Os system prompts atuais dos sub-agentes** da fábrica (`coordenador/`).
3. **O template oficial da plataforma Mitra vendorizado** (`mitra-agent-minimal/`) — Chart.tsx, ui/, system_prompt.md.
4. **Instruções de setup** (`SETUP.md`) para subir a fábrica numa VPS limpa.
5. (separadamente) **O projeto Mitra Autonomous Factory** que serve de banco de estado da fábrica (workspaces, pipelines, histórico de QA, fluxos de dados) — criado no passo 4 do SETUP.

A intenção é que outro usuário consiga subir uma fábrica equivalente em poucas horas: `git clone → npm install no template → preencher .env → criar projeto cérebro na plataforma Mitra → tmux + claude`.

Esta seção é viva — deve evoluir junto com a fábrica.

---

## License

MIT
