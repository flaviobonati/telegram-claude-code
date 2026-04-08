---
name: Guia do Testador é gerado pelo Dev — Coordenador só persiste
description: Dev entrega Guia do Testador no output final. Coordenador extrai e grava em GUIAS_TESTE no banco 45173. Não é responsabilidade do QA nem do próprio Coordenador gerar.
type: feedback
---

O Dev entrega o Guia do Testador como parte do relatório final (passo a passo de implantação + trigger de cada cadeia + jornada por persona + uso do botão "Carregar Dados de Exemplo" + sparkle + features MUST mapeadas + URL/credenciais). O Coordenador só extrai o conteúdo e grava em GUIAS_TESTE no banco 45173 (ou confirma que o Dev já gravou via patchRecordMitra em PIPELINE.GUIA_TESTE).

**Why:** Em 2026-04-08, Flávio primeiro disse "o QA tem que fazer isso" e 50min depois se corrigiu: "o guia do testador pode ser gerado pelo dev, mal, eu falei errado, pode spawnar o QA". O Dev já tem o mapa de botões/rotas que acabou de implementar, então é a fonte mais barata e direta. O QA ainda valida tudo via Playwright, mas não escreve guia.

**How to apply:**
- Fluxo: Dev entrega (com guia no output) → Coordenador sanity check → Coordenador persiste GUIAS_TESTE → Spawna QA passando GUIAS_TESTE como contrato de teste
- Se Dev não entregou o guia: rejeita Dev e re-spawna pedindo
- Se Dev já gravou direto via patchRecordMitra, só confirmar via SELECT COUNT
- coordinator.md REGRA #3, qa.md e qa_report_template.md devem refletir essa ordem.
