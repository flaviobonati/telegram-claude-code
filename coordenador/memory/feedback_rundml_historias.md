---
name: Usar runDmlMitra para campos problematicos
description: updateRecordMitra ignora silenciosamente HISTORIAS_USUARIO e PROJETO_MITRA_ID - sempre usar runDmlMitra com SQL direto para esses campos
type: feedback
---

Sempre usar `runDmlMitra` com SQL direto para gravar os campos HISTORIAS_USUARIO e PROJETO_MITRA_ID no PIPELINE. O `updateRecordMitra` aceita o request sem erro mas nao persiste o valor.

**Why:** Descoberto na primeira pesquisa (Canal de Denuncia). HISTORIAS_USUARIO tem ~20k chars e o updateRecordMitra ignora silenciosamente. PROJETO_MITRA_ID da NullPointer no updateRecordMitra quando o campo era null antes.

**How to apply:** Ao gravar resultados do Pesquisador ou setup do Dev, usar runDmlMitra para esses campos. Escapar aspas simples com '' no SQL. Os demais campos do PIPELINE podem continuar usando updateRecordMitra, mas na duvida, runDmlMitra e mais confiavel.
