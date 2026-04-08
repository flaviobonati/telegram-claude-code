---
name: Cron não bloqueante
description: CronCreate roda quando REPL está idle, não bloqueia. Manter prompts leves.
type: feedback
---

## Como funciona o CronCreate
- Jobs disparam APENAS quando o REPL está idle (não durante uma query)
- Não bloqueia a sessão
- Session-only (morre quando Claude sai) — mas no tmux a sessão persiste

## Boas práticas
1. Prompt do cron deve ser LEVE — checar status, tail em arquivos, decidir ação
2. NÃO fazer trabalho pesado no cron — spawnar Agent se precisar de algo grande
3. Intervalo de 2min funciona bem para monitoramento
4. Sempre ter um cron de monitoramento rodando enquanto há agents em background

## Anti-patterns
- NUNCA usar sleep no bash para simular cron
- NUNCA usar & no bash para background (usar run_in_background do Bash tool)
- Crons de sessão morrem se a sessão morrer — gravar estado no banco 45173 como safety net

**Why:** Crons bloqueantes impedem interação com Flavio via Telegram.
**How to apply:** Usar CronCreate com prompt leve. Trabalho pesado vai pra Agent tool.
