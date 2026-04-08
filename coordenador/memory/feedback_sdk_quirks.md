---
name: Quirks e capacidades do mitra-sdk
description: Armadilhas da SDK que causam erros silenciosos + capacidades que nao sao obvias
type: feedback
---

## Erros silenciosos:
1. `runQueryMitra` precisa de `{ projectId, sql: 'SELECT ...' }`. NAO aceita `{ tableName, filters }` — da erro "sql is required".
2. `updateRecordMitra` ignora silenciosamente campos TEXT grandes (ex: HISTORIAS_USUARIO ~20k chars) e campos que eram null (ex: PROJETO_MITRA_ID). Usar `runDmlMitra` nesses casos.
3. `createRecordMitra` e `createRecordsBatchMitra` funcionam normalmente com `{ tableName, data }`.
4. `runDmlMitra` aceita INSERT/UPDATE/DELETE. `runQueryMitra` aceita apenas SELECT.
5. Para criar projeto no workspace de dev (19103), precisa reconfigurar SDK com token do workspace 19103 ANTES de chamar `createProjectMitra`.

## Capacidades do Mitra (NAO limitar):
- **Email**: SDK tem funcao nativa de notificacao por email (`sendEmailMitra` ou similar)
- **Real-time**: Usar polling em vez de WebSocket — funciona pra collision detection, dashboards ao vivo
- **Chatbot/IA**: SF JAVASCRIPT pode chamar LLMs externas via integracao
- **Integracoes**: SDK conecta com qualquer API via createIntegrationMitra
- **Cron**: SFs podem ter cron de 5min+

**Why:** O Flavio corrigiu o Coordenador quando ele limitou features achando que o Mitra nao fazia (email, WebSocket, chatbot). O Mitra e mais capaz do que parece.

**How to apply:** Nunca remover features por achar que o Mitra nao suporta. Na duvida, manter e deixar o Dev resolver. O filtro de viabilidade do Pesquisador deve focar em "roda no browser?" e nao em limitacoes de SDK.
