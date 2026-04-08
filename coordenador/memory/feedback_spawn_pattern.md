---
name: Padrao correto de spawn de sub-agents
description: Nunca usar & no bash para spawnar agents - usar run_in_background do Bash tool
type: feedback
---

Ao spawnar sub-agents via `claude -p`, NUNCA usar `&` no final do comando bash. Isso faz o Bash tool capturar apenas o echo e perder todo o output do agent.

**Why:** Na primeira tentativa de spawnar o Dev Agent, usamos `& DEV_PID=$!` e o output capturado foi apenas "Dev Agent spawned with PID: 46633" — zero output do agent real.

**How to apply:** Usar o parametro `run_in_background: true` do Bash tool. O comando deve ser simplesmente:
```
claude -p "$(cat /opt/mitra-factory/prompts/[agente].md) ..." --dangerously-skip-permissions 2>&1
```
Sem `&`, sem `nohup`, sem redirecionamento manual. O Bash tool cuida do background.
