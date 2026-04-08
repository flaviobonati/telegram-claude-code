---
name: QA output trunca - sempre pedir relatório completo
description: O claude -p corta output grande. Sempre instruir QA a retornar relatório COMPLETO e verificar tamanho > 1000 bytes.
type: feedback
---

O `claude -p` trunca output quando o agente gera muito texto. O QA frequentemente retorna só um resumo de 100-500 bytes em vez do relatório completo de 10KB+.

**Why:** Em múltiplos ciclos de QA, o output voltou truncado (150-500 bytes) com só um resumo, perdendo bugs, features e feedback detalhado.

**How to apply:**
1. Sempre incluir no prompt do QA: "CRÍTICO — OUTPUT: Relatório COMPLETO no output. TODAS as seções. NÃO resuma."
2. Ao receber output, verificar se > 1000 bytes. Se < 1000, provavelmente truncou — re-spawnar pedindo relatório completo
3. Histórias de usuário: passar via arquivo (Read tool), não no shell — evita problemas de encoding e tamanho
