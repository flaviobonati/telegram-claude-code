---
name: Max 2 sub-agents + investigar falhas
description: Max 2 agents simultaneos (memoria 3.8GB, nao rate limit). Investigar causa real de falhas.
type: feedback
---

Maximo 2 sub-agents (claude -p) rodando ao mesmo tempo. NAO por rate limit (conta de $200 aguenta), mas por limitacao de RAM (3.8GB, sem swap).

4 agents simultaneos causou OOM kill (nao rate limit como inicialmente assumido). 2 agents funciona bem.

**Why:** Flavio corrigiu: rate limit vai longe com conta de $200. A falha dos QAs foi provavelmente OOM (3.8GB RAM, sem swap, 3 processos claude = main + 2 sub). Flavio pediu pra SEMPRE investigar causa real de falhas, nao assumir rate limit.

**How to apply:** 
- Spawnar max 2 sub-agents em paralelo (funciona com a RAM disponivel)
- Quando um agent falha, INVESTIGAR causa real (checar dmesg, free -h, output file) antes de diagnosticar
- Nunca assumir "rate limit" sem evidencia
