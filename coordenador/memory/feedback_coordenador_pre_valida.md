---
name: Coordenador pre-valida build antes de QA
description: Coordenador DEVE verificar via curl/grep que fixes estao no build deployado ANTES de spawnar QA. Evita rounds desperdicados.
type: feedback
---

Antes de spawnar QA, o Coordenador DEVE verificar ELE MESMO que os fixes do Dev estão no build deployado. Não confiar apenas no relatório do Dev.

**Why:** Na noite de 2026-04-07, múltiplos rounds de R&S tiveram fixes no código fonte que NÃO estavam no build deployado (dist/ velho, rebuild não feito). O QA gastava 30min de créditos para descobrir que o fix não estava lá. Se o Coordenador tivesse feito 1 curl de 10s, teria evitado.

**How to apply:**
1. Após Dev entregar, ANTES de spawnar QA:
   - `curl -s URL/assets/*.js | grep -c 'termo_do_fix'` para confirmar fix no bundle
   - Para Gemini: `curl -s URL/assets/*.js | grep -c 'generativelanguage'` + `grep -c 'thinkingConfig'` (deve ser 0)
   - Para toast: `curl -s URL/assets/*.js | grep -c 'toast\|Toast'`
2. Se fix NÃO está no bundle → re-spawnar Dev com "REBUILD LIMPO", NÃO spawnar QA
3. 10 segundos de verificação > 30 minutos de QA desperdiçado
