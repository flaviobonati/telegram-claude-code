---
name: Spawn de sub-agent — evitar interpolacao direta no prompt
description: Prompts com backticks, curls, $(), dentro de run_in_background podem ser reinterpretados pelo bash eval. Usar variaveis ou arquivo temp.
type: feedback
---

Quando usar `run_in_background: true` no Bash tool, o comando e executado via `bash -c 'eval "..."'`. Se o prompt tem:
- Triple backticks com bash syntax
- `$(...)` interpolations
- `%{...}` (curl format specifiers)
- Backticks simples `\``

Pode haver dupla interpretacao e o claude -p morre silenciosamente (stdout = 157 bytes, so o warning de stdin).

**Incidente (04/04/2026):** 2 Devs Plan R2 e Comissoes R2 morreram com 157 bytes apos spawn com prompts contendo exemplos de curl com `%{http_code}`.

**Solucao 1:** Escrever o prompt num arquivo temp e usar variaveis:
```bash
DEV_PROMPT=$(cat /opt/mitra-factory/prompts/developer.md)
TASK_PROMPT=$(cat /tmp/prompt_task.txt)
claude -p "${DEV_PROMPT}

${TASK_PROMPT}" --dangerously-skip-permissions < /dev/null 2>&1
```

**Solucao 2:** Escapar backticks e dollars no prompt inline (dor de cabeca).

**How to apply:** 
- Para prompts complexos com curl/examples, SEMPRE escrever num arquivo temp e ler via $(cat ...) em variavel
- Usar `< /dev/null` explicito pra evitar warning de stdin
- Sempre verificar 15s apos spawn: se processo morreu com 157 bytes = bash eval falhou
