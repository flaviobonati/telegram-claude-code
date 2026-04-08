---
name: PIPELINE_ID obrigatorio em LOG_ATIVIDADES
description: Toda entrada de log vinculada a um sistema do pipeline precisa preencher PIPELINE_ID alem de VERTICAL
type: feedback
---

A tabela LOG_ATIVIDADES tem coluna PIPELINE_ID (int). Toda entrada vinculada a um sistema do pipeline DEVE preencher esse campo.

**Incidente (05/04/2026):** Coordenador estava gravando LOG_ATIVIDADES com AGENTE, ACAO, DETALHES, VERTICAL, TIMESTAMP_LOG — mas NAO estava preenchendo PIPELINE_ID. Outra thread (desenvolvendo frontend do 45173) reportou isso como gap.

**Why:** Frontend da autonomous factory precisa filtrar logs por projeto (pipeline_id), nao por nome (vertical texto). Nome pode mudar, id nao.

**How to apply:** Ao criar entrada em LOG_ATIVIDADES para um sistema especifico, incluir `PIPELINE_ID: [id do pipeline]`. Entradas gerais (ex: 'retomada', 'sync_prompts') podem ficar sem. Mesma regra vale pra INTERACOES, HISTORICO_QA, GUIAS_TESTE.
