---
name: Nunca quebrar em bug-por-vez — Opus 4.6 aguenta lote completo
description: Quando Dev entrega incompleto, nao reduzir escopo. Melhorar guard rails e explicacao.
type: feedback
---

Opus 4.6 (modelo usado em toda a fabrica) lida com lotes grandes de correcoes sem problema. Nunca quebrar em "1 bug por vez" quando um Dev entrega incompleto.

**Incidente (04/04/2026):** Dev Plan R2 corrigiu apenas 2 de 13 bugs. Meu instinto foi considerar dividir em correcoes menores. Flavio corrigiu: nunca fazer isso. Opus 4.6 aguenta.

**Why:** Quebrar tarefas aumenta loops = mais tempo. A solucao correta quando Dev entrega incompleto e:
1. Analisar o output (ou falta de output) pra entender o que faltou
2. Melhorar os GUARD RAILS do prompt: instrucoes mais especificas, validacao obrigatoria, exemplos do que esperar
3. Explicar MELHOR a tarefa no prompt da proxima rodada
4. Exigir evidencia (curl/Playwright) de cada correcao

**How to apply:**
- Manter prompts com lote completo de bugs
- Quando Dev falhar, reforcar guard rails (validacao obrigatoria, output especifico, exemplos)
- Nao reduzir escopo por instinto — confiar no Opus 4.6
- Otimizar por menos loops, nao por menos escopo por loop
