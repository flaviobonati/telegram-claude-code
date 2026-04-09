# Setup — Mitra Factory numa VPS nova

Este guia liga a fábrica numa VPS Linux limpa. Após esses passos, você terá um tmux com o Coordenador (Claude Code) orquestrando sub-agentes (Pesquisador, Dev, QA) que produzem sistemas verticais **production-grade 10/10/10/10** na plataforma Mitra.

## O que a fábrica precisa

- **Linux** (Debian/Ubuntu testado)
- **Node.js 20+** (Dev e QA rodam scripts `.mjs`)
- **Git**
- **tmux** (pra manter o Coordenador rodando após fechar SSH)
- **Claude Code CLI** (`npm i -g @anthropic-ai/claude-code`)
- **Playwright** (QA usa Chromium) — `npx playwright install`
- **Tokens do Mitra** (base URL + workspace token)
- **Token do Telegram** (opcional — só se quiser notificações no celular)

> ⚠️ **NUNCA rode o Coordenador como `root`.** Claude Code CLI recusa a spawnar sub-agentes quando o processo tem `loginuid=0` (checagem de segurança do próprio CLI — se não houver sessão de login "real", o spawn via `claude -p` falha silenciosamente ou cai pro Agent tool com contexto muito menor, que **não** cabe o `system_prompt.md` oficial do Mitra + `dev.md` + task). Sempre use um **usuário dedicado não-privilegiado** (ex: `mitra`, `devagent`). Ver "Passo 0" abaixo.

## Passo 0 — Criar usuário dedicado (obrigatório se você está como root)

Se você tá logado como `root` na VPS nova, crie um usuário só pra fábrica e faça login nele via SSH direto (não `su -`, que mantém `loginuid=0` do login original):

```bash
# Como root (ou sudo)
adduser mitra                                      # pode ser qualquer nome — vou chamar de "mitra"
usermod -aG sudo mitra                             # opcional, pra ele conseguir instalar pacotes globais
mkdir -p /home/mitra/.ssh
cp ~/.ssh/authorized_keys /home/mitra/.ssh/
chown -R mitra:mitra /home/mitra/.ssh
chmod 700 /home/mitra/.ssh
chmod 600 /home/mitra/.ssh/authorized_keys

# Saia do SSH como root e RELOGUE como mitra:
exit
ssh mitra@SUA-VPS

# Verifique que loginuid NÃO é 0 (deve ser o UID do mitra, tipicamente 1000+):
cat /proc/self/loginuid
```

**Importante**: `su - mitra` a partir do root NÃO resolve — o `loginuid` é herdado do primeiro login. Você **precisa** logar via SSH direto como `mitra` pra ter um `loginuid` correto. Isso é uma limitação do kernel Linux (`/proc/*/loginuid` é imutável após set). Claude Code verifica isso e recusa rodar `claude --dangerously-skip-permissions -p -` se `loginuid=0`, porque esse é o marcador de "sem sessão de login real".

> **Sintoma do bug**: se você ignorar esse passo, o Coordenador vai conseguir spawnar sub-agentes mas eles vão cair no **Agent tool** (API) em vez do **CLI** (`claude -p`). Agent tool tem janela de contexto muito menor — o Dev não consegue ler o `system_prompt.md` inteiro (2726 linhas), e o sistema acaba sendo construído com contexto insuficiente.

## Passo 1 — Clonar o repo no local canônico

A fábrica assume que todos os paths absolutos começam em `/opt/mitra-factory/`. O jeito mais simples é clonar o repo direto nesse caminho:

```bash
sudo mkdir -p /opt/mitra-factory
sudo chown "$USER:$USER" /opt/mitra-factory
git clone https://github.com/flaviobonati/telegram-claude-code.git /opt/mitra-factory
cd /opt/mitra-factory
```

Se preferir clonar em outro lugar (`~/mitra-factory`, etc.), crie um symlink:

```bash
git clone https://github.com/flaviobonati/telegram-claude-code.git ~/mitra-factory
sudo ln -s "$HOME/mitra-factory" /opt/mitra-factory
```

Depois, todas as referências a `/opt/mitra-factory/...` resolvem pro repo.

## Passo 2 — Instalar dependências do template

O template oficial do Mitra está vendorizado em `mitra-agent-minimal/template/`. Ele precisa de `node_modules` pra você poder buildar sistemas a partir dele:

```bash
cd /opt/mitra-factory/mitra-agent-minimal/template/frontend
npm install   # ~211 MB de node_modules. Demora ~2 min na primeira vez.
cd /opt/mitra-factory/mitra-agent-minimal/template/backend
npm install   # pequeno
```

## Passo 3 — Configurar variáveis de ambiente

A fábrica usa **dois arquivos `.env` separados** por segurança (ver `coordinator.md` princípio 8.11):

### 3.1. `.env.coordinator` — variáveis da fábrica (obrigatório)

Vive em `/opt/mitra-factory/.env.coordinator`. Contém tokens do Mitra. É carregado **explicitamente** pelo Coordenador via `dotenv.config({ path: '/opt/mitra-factory/.env.coordinator' })` — nunca fica exposto como `.env` puro pra evitar que scripts de sub-agente o carreguem por acidente e contaminem o banco da fábrica.

```bash
cd /opt/mitra-factory
cp .env.coordinator.example .env.coordinator
$EDITOR .env.coordinator
```

Variáveis:

| Variável | O que é | Como obter |
|---|---|---|
| `MITRA_BASE_URL` | URL da API Mitra (ex: `https://newmitra.mitrasheet.com:8080`) | Fornecido pelo Mitra |
| `MITRA_BASE_URL_INTEGRATIONS` | Geralmente igual ao `MITRA_BASE_URL` | — |
| `FACTORY_PROJECT_ID` | ID do projeto da Fábrica Autônoma (o cérebro da fábrica) | Criado conforme Passo 4 |
| `FACTORY_WORKSPACE_ID` | ID do workspace onde o projeto da fábrica vive | Painel Mitra |
| `FACTORY_TOKEN` | Token do workspace do cérebro | Painel Mitra → Workspace → Tokens |
| `DEV_WORKSPACE_ID` | ID do workspace de desenvolvimento (separado do cérebro) | Painel Mitra |
| `DEV_WORKSPACE_TOKEN` | Token do workspace de desenvolvimento | Painel Mitra |
| `GEMINI_API_KEY` | (opcional) Gemini pra sistemas com IA opcional | Google AI Studio |

### 3.2. `.env` — variáveis do webhook do Telegram (opcional)

Só preencha se for usar o webhook bidirecional Telegram ↔ fábrica (Passo 8). Vive em `/opt/mitra-factory/.env` (a raiz do repo).

```bash
cd /opt/mitra-factory
cp .env.example .env
$EDITOR .env
```

Variáveis:

| Variável | O que é |
|---|---|
| `BOT_TOKEN` | Token do bot do Telegram (obtido via @BotFather) |
| `CHAT_ID` | Chat ID do usuário que conversa com a fábrica (obtido via @userinfobot) |
| `SSH_HOST` / `SSH_PORT` / `SSH_USER` / `SSH_PRIVATE_KEY` | Dados pra o webhook da Vercel fazer SSH na VPS e entregar mensagens |
| `TELEGRAM_ALLOWED_USER` | ID do usuário autorizado a falar com o bot |
| `TMUX_SESSION` | Nome da sessão tmux onde o Coordenador está rodando (padrão `main`) |
| `MSG_DIR` | Onde gravar as mensagens recebidas (padrão `/tmp/telegram_msgs`) |

## Passo 4 — Criar o projeto da Autonomous Factory (cérebro)

A fábrica precisa de um **projeto Mitra dedicado** pra guardar o estado dos sistemas em andamento (tabelas `PIPELINE`, `HISTORICO_QA`, `LOG_ATIVIDADES`, `FEATURES`, `AGENTES`, etc.). Crie esse projeto na plataforma Mitra **uma única vez** e grave o ID em `FACTORY_PROJECT_ID`.

O schema do banco está descrito no `coordenador/coordinator.md` seção **5. O sistema cérebro (Autonomous Factory)** — tabelas `PIPELINE`, `FEATURES`, `HISTORICO_QA`, `LOG_ATIVIDADES`, `INTERACOES`, `AGENTES`, `GUIAS_TESTE`, `SECOND_BRAIN`, `OPORTUNIDADES` (+ `HUMILHACAO_FABRICA` descontinuada). Crie o projeto pela UI do Mitra e use a SDK (`runDdlMitra`, `createServerFunctionMitra`) pra popular esquema + SFs base. Um script `setup-factory-brain.mjs` ainda não existe — é um TODO documentado em `coordinator.md` e deve ser criado quando alguém for subir uma fábrica do zero pela primeira vez.

> **Importante:** se você NÃO está partindo do zero e já tem um projeto cérebro em uso, use `pullFromS3Mitra` (documentado em `coordenador/sub-agents/dev/dev.md` seção 3.3) pra recuperar o estado.

## Passo 5 — Instalar Claude Code CLI

```bash
npm i -g @anthropic-ai/claude-code
claude --version
```

Autenticar com sua conta Anthropic:

```bash
claude auth login
```

## Passo 6 — (Opcional) Instalar Playwright pro QA

O QA roda browsers headless pra testar sistemas. Precisa do Chromium:

```bash
cd /opt/mitra-factory
npx playwright install chromium
```

## Passo 7 — Iniciar o Coordenador em tmux

O Coordenador é um processo `claude` rodando em tmux que lê os prompts, fala com o Telegram, e spawna sub-agentes:

```bash
tmux new -s mitra-factory
cd /opt/mitra-factory
claude  # entra no REPL do Claude Code. Primeira instrução já lê coordenador/coordinator.md.
```

Detach do tmux: `Ctrl-b d`. Re-attach: `tmux attach -t mitra-factory`.

## Passo 8 — (Opcional) Configurar webhook do Telegram

Se você quer conversar com a fábrica pelo Telegram:

```bash
cd /opt/mitra-factory
# Configura o webhook no Telegram apontando pro endpoint Vercel (ver api/webhook.js)
# Deploy do webhook:
vercel --prod
```

Ver `api/webhook.js` + `tg.mjs` pra detalhes da integração Telegram.

## Passo 9 — Manutenção: sincronizar `mitra-agent-minimal`

A pasta `mitra-agent-minimal/` é uma cópia vendorizada do repo privado `mpbonatti/mitra-agent-minimal`. Pra atualizar:

```bash
export GH_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
./scripts/sync-mitra-agent-minimal.sh
git add mitra-agent-minimal/
git commit -m "Sync mitra-agent-minimal com a versão oficial"
git push
```

Após a sincronização, se o template teve mudanças em `package.json`, rode `npm install` de novo dentro de `mitra-agent-minimal/template/frontend/`.

## Verificação final

Dentro do tmux com o Claude rodando, peça ao Coordenador pra fazer um check rápido:

```
Lista o estado atual dos sistemas no PIPELINE do cérebro da fábrica.
```

Se ele responder com uma lista de pipelines (mesmo que vazia numa VPS nova), o Coordenador está funcionando, conectado ao Mitra, e pronto pra começar a construir sistemas.

## Troubleshooting

| Problema | Causa provável | Fix |
|---|---|---|
| Dev spawnado cai no **Agent tool** em vez do CLI, contexto minúsculo, não consegue ler `system_prompt.md` inteiro | Coordenador rodando como `root` (`loginuid=0`) — Claude Code CLI recusa `claude -p` sem sessão de login real | Ver **Passo 0** — criar usuário dedicado e logar via SSH direto (`su -` não resolve). Verificar: `cat /proc/self/loginuid` deve retornar UID >= 1000, nunca 0 |
| `claude -p` falha silenciosamente ou retorna output ~157 bytes | Mesma causa: `loginuid=0` OU escape hell no prompt inline | 1. Verificar `cat /proc/self/loginuid`. 2. Sempre usar `scripts/run_agent.sh` que lê prompt via stdin (`-p -`), nunca inline |
| `ECONNREFUSED` ao chamar SDK | Token errado ou `MITRA_BASE_URL` incorreto | Verificar `.env.coordinator` |
| `Cannot find module 'mitra-sdk'` | Esqueceu de rodar `npm install` no `mitra-agent-minimal/template/backend/` | Rodar |
| `Cannot find module 'recharts'` no build | Esqueceu de rodar `npm install` no `mitra-agent-minimal/template/frontend/` | Rodar |
| Claude não lê `coordinator.md` | Permissões ou CWD errado | `cd /opt/mitra-factory && claude` |
| Playwright abre chromium mas crasha | Dependências do sistema faltando | `sudo npx playwright install-deps chromium` |
| `scripts/sync-mitra-agent-minimal.sh` 401 | `GH_TOKEN` sem acesso ao repo privado | Gerar novo token com escopo `repo` |
| `Data too long for column 'SYSTEM_PROMPT'` ao atualizar tabela `AGENTES` do cérebro | Coluna criada como `TEXT` (65535 bytes), mas `coordinator.md` atual tem 68k+ bytes | `ALTER TABLE AGENTES MODIFY COLUMN SYSTEM_PROMPT LONGTEXT` (já feito na fábrica de referência — adicionar ao schema ao criar o cérebro) |

## Arquitetura em uma linha

```
Telegram → webhook.js (Vercel) → tmux na VPS → Coordenador (claude -p lendo coordinator.md) →
spawna Pesquisador / Dev / QA via run_agent.sh → cada sub-agente roda claude --dangerously-skip-permissions
com prompts de sub-agents/*/*.md + task específica → Dev usa mitra-agent-minimal/template/ +
mitra-agent-minimal/system_prompt.md → SDK Mitra (createProject, createServerFunction, deployToS3) →
sistema live em https://{wsId}-{pjId}.prod.mitralab.io
```
