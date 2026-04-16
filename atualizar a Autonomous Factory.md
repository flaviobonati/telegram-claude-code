# Atualizar a Autonomous Factory

Este guia é pro **Claudinho da Autonomous Factory** (a instância que cada usuário roda na própria VPS) puxar mudanças que o Flávio liberou no repo `telegram-claude-code`. A AF é **individualizada** — cada usuário tem uma instância própria com banco, projeto e workspace separados — mas o **código** (prompts + scripts + templates) é compartilhado via Git.

---

## TL;DR (90% dos casos)

Quando a mudança é **só em prompts** (`coordenador/coordinator.md`, `coordenador/sub-agents/*.md`, `mitra-agent-minimal/system_prompt.md`):

```bash
cd /opt/mitra-factory
git pull
```

Só isso. Os prompts (`.md`) são lidos do disco sob demanda — o Claude Code não cacheia conteúdo entre invocações. Próxima conversa nova com o Coordenador já usa os prompts atualizados.

**Quer forçar releitura na conversa CORRENTE** (sem esperar uma sessão nova)? Manda no Telegram pro seu Coordenador:

> "Lê o `coordenador/coordinator.md` atualizado e me resume quais foram as mudanças."

Ele relê do disco e ajusta. Sem precisar matar/reiniciar tmux.

**Quando reiniciar o tmux faz sentido:** só se o Claude Code da AF travou, ficou inconsistente, ou você quer começar uma sessão totalmente limpa por algum outro motivo. Não é necessário pra puxar prompt novo.

---

## Estrutura: o que tem back-end e o que tem front-end

A AF tem **dois lados** que podem precisar de atualização:

### Back-end da AF — prompts + scripts

**O que conta como back-end:**
- `coordenador/coordinator.md` — system prompt do Coordenador
- `coordenador/sub-agents/dev/dev.md` — prompt do Dev Agent
- `coordenador/sub-agents/qa/qa.md` — prompt do QA Agent
- `coordenador/sub-agents/qa/qa_report_template.md` — template de relatório QA
- `coordenador/sub-agents/reround/reround_researcher.md` — prompt do Re-Round (3 modos)
- `coordenador/sub-agents/pesquisador/researcher.md` + `researcher_custom.md` — prompts do Pesquisador
- `prompts/` — symlinks pros arquivos acima (alguns scripts referenciam `prompts/qa.md` etc)
- `tg.mjs` — script Telegram bidirecional

**Como atualizar:**
```bash
cd /opt/mitra-factory
git pull
```

Pronto. Não precisa rebuild, restart de tmux nem nada. Próxima invocação do Coordenador (e dos sub-agentes spawnados por ele) já lê o arquivo novo do disco. Se quiser que a conversa atual aplique imediatamente, peça pro Coordenador reler: "Lê o `coordenador/coordinator.md` atualizado".

### Front-end da AF — template do Dev Agent

**O que conta como front-end:**
- `mitra-agent-minimal/system_prompt.md` — system prompt do Dev Agent (regras de SDK Mitra, padrões de código)
- `mitra-agent-minimal/AGENTS.md` — guia de boot do Dev
- `mitra-agent-minimal/CLAUDE.md` — instruções específicas do Claude Code
- `mitra-agent-minimal/template/backend/` — código backend padrão que o Dev clona pra cada projeto novo
- `mitra-agent-minimal/template/frontend/` — código frontend padrão que o Dev clona pra cada projeto novo

**Como atualizar:**

| Tipo de mudança | O que fazer |
|---|---|
| **Mudou só `system_prompt.md` ou `AGENTS.md` ou `CLAUDE.md`** | `git pull` resolve. Próximo Dev spawnado já lê o novo. **Sistemas existentes não são afetados** (eles já receberam o briefing anterior). |
| **Mudou `template/backend/` ou `template/frontend/`** | `git pull` resolve **pro próximo sistema novo**. **Sistemas existentes NÃO recebem a mudança automaticamente** — eles têm o template antigo já clonado no banco da AF do usuário (S3/storage). Pra propagar a mudança em sistema existente, é preciso rodar `pullFromS3` no Dev daquele sistema, aplicar o diff manual, e `deployToS3`. **Não fazer em massa** — cada sistema é uma decisão. |
| **Mudou pacote npm de `template/frontend/package.json`** | `git pull` + se for sistema novo, próximo build já pega. Pra sistema existente, mesma regra acima. |

---

## Validação pós-atualização

Depois do `git pull`, manda no Telegram pro seu Coordenador:

> "Lê o `coordenador/coordinator.md` atualizado e me cita as 3 mudanças mais recentes do `git log`."

Ele deve responder citando os últimos commits incluindo o seu `git pull`. Se citar algo antigo, é porque ainda não releu o arquivo — peça explicitamente pra ele rodar `Read` no arquivo, ou abra uma conversa nova.

---

## Branches e conflitos

**A `main` é a branch canônica.** Não trabalhe em outras branches a menos que combinado com Flávio. Se `git pull` der conflito, você provavelmente editou um prompt local — `git stash` pra guardar, `git pull` pra atualizar, depois `git stash pop` e resolver à mão.

**Nunca faça `git push --force` sem combinar.** Os colegas perdem trabalho.

---

## Ajuda

Se a AF não pegar a mudança mesmo após `git pull`:

1. Confirma que o `git pull` rodou no diretório certo: `cd /opt/mitra-factory && git log -1 --oneline` deve mostrar o commit novo no topo
2. Confirma que o Coordenador está lendo o arquivo certo: pede pra ele rodar `head -3 /opt/mitra-factory/coordenador/coordinator.md` e te mandar a saída
3. Se a conversa atual do Coordenador já carregou o `coordinator.md` antigo na memória da sessão, peça pra ele reler explicitamente (`Read coordenador/coordinator.md`) ou abra uma conversa nova

Se ainda não funcionar, fala com Flávio.
