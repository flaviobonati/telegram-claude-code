---
name: Dev smoke test via backend — NÃO Playwright
description: Dev testa SFs via executeServerFunctionMitra e listRecordsMitra antes de entregar. Playwright é só pro QA. listRecordsMitra retorna {content:[...]}.
type: feedback
---

Dev DEVE fazer smoke test via backend (SDK), NÃO via Playwright:
- Executar cada SF com executeServerFunctionMitra
- Verificar listRecordsMitra retorna {content:[...]} — SEMPRE extrair .content
- Testar login de cada persona via SF

**Why:** Dev usava Playwright pra validar (caro em tokens) ou não validava nada. Flávio determinou: Dev testa backend, QA testa frontend. listRecordsMitra retorna {content:[...]} mas Dev não tratava → todas as telas de CRUD crashavam.

**How to apply:** standard_briefing seção 6.4 (Smoke Test) e 6.5 (listRecordsMitra .content).
