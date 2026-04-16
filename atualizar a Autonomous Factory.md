# Atualizar a Autonomous Factory

Este guia é pro **Claudinho da Autonomous Factory** (a instância que cada usuário roda na própria VPS) puxar mudanças que o Flávio liberou no repo `telegram-claude-code`. A AF é **individualizada** — cada usuário tem uma instância própria com banco, projeto e workspace separados — mas o **código** (prompts + scripts + templates) é compartilhado via Git.

---

## TL;DR (90% dos casos)

Quando a mudança é **só em prompts** (`coordenador/coordinator.md`, `coordenador/sub-agents/*.md`, `mitra-agent-minimal/system_prompt.md`):

```bash
cd /opt/mitra-factory
git pull
# Reinicia o Coordenador no tmux pra ele recarregar os prompts na próxima sessão
tmux send-keys -t mitra-coord:0 'C-c' Enter   # mata o claude code atual
tmux send-keys -t mitra-coord:0 'claude --dangerously-skip-permissions' Enter
```

Pronto. A próxima vez que o Coordenador for invocado (via Telegram ou direto no tmux), ele já lê as regras novas.

> **Por quê funciona:** o Coordenador lê `coordenador/coordinator.md` e os prompts dos sub-agentes a cada sessão (instrução `auto memory` no início manda ler `prompts/coordinator.md`). Não há cache persistente — basta o arquivo no disco estar atualizado.

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
# Não precisa rebuild de nada. Reinicia só o tmux do Coordenador:
tmux send-keys -t mitra-coord:0 'C-c' Enter
sleep 2
tmux send-keys -t mitra-coord:0 'claude --dangerously-skip-permissions' Enter
```

Se o nome da sessão tmux for diferente, ajusta `mitra-coord:0` pro nome real (ex: `tmux ls` pra ver).

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

## Quando precisar matar/reiniciar o Coordenador no tmux

Se você não sabe se o Coordenador tá numa conversa ativa, **não mate cego** — pode interromper trabalho de meio-rodada. Verifica primeiro:

```bash
# Atacha no tmux e olha o que tá acontecendo:
tmux attach -t mitra-coord
# (Ctrl+B, depois D pra detachar sem matar)
```

Se tiver conversa ativa, pede pro Coordenador "salva o que tá fazendo, vou reiniciar pra puxar prompt novo" via Telegram, espera ele confirmar, e aí reinicia.

---

## Validação pós-atualização

Depois do `git pull` + restart, manda no Telegram:

> "Quais são as 3 mudanças mais recentes nos prompts da fábrica?"

O Coordenador deve responder citando os últimos 3 commits. Se ele citar algo de antes do `git pull`, **não pegou** — repita o restart do tmux.

---

## Branches e conflitos

**A `main` é a branch canônica.** Não trabalhe em outras branches a menos que combinado com Flávio. Se `git pull` der conflito, você provavelmente editou um prompt local — `git stash` pra guardar, `git pull` pra atualizar, depois `git stash pop` e resolver à mão.

**Nunca faça `git push --force` sem combinar.** Os colegas perdem trabalho.

---

## Ajuda

Se a AF não pegar a mudança mesmo após `git pull` + restart:

1. Confirma que o `git pull` rodou no diretório certo: `cd /opt/mitra-factory && git log -1 --oneline` deve mostrar o commit novo
2. Confirma que o tmux foi mesmo reiniciado: `tmux attach -t mitra-coord` e veja se há prompt novo do Claude Code (não a conversa antiga)
3. Confirma que o Coordenador está lendo o arquivo certo: pede pra ele rodar `head -3 /opt/mitra-factory/coordenador/coordinator.md`

Se ainda não funcionar, fala com Flávio.
