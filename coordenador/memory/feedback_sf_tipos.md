---
name: SF tipos corretos — JS nunca pra leitura
description: SF SQL pra leitura (~8ms), INTEGRATION pra API externa (~500ms), JS só pra lógica complexa (~2000ms E2B). JS pra SELECT = rejeição imediata.
type: feedback
---

Server Functions têm 3 tipos com custos diferentes:
- REST (listRecordsMitra, etc.) = CRUD simples, nem precisa SF (~5ms)
- SF SQL = queries, mutações (~8ms)
- SF INTEGRATION = API externa (~500ms)
- SF JAVASCRIPT = lógica complexa (~2000ms, sobe E2B)

**Why:** Dev Planejamento criou 24 de 41 SFs como JavaScript (incluindo listarObjetivos, listarIndicadores). Cada operação levava 20s em vez de 8ms. Flávio classificou como "crime".

**How to apply:** Regra no standard_briefing seção 6.1. Checklist pré-entrega item 6. Coordenador verifica listServerFunctionsMitra antes de aceitar.
