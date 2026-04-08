---
name: QA visual pesado eh padrao
description: QA visual exaustivo (pagina por pagina, elemento por elemento, screenshots) eh o fluxo PADRAO da fabrica, nao excecao. Flavio exigiu 2026-04-06.
type: feedback
---

QA visual exaustivo (varredura pagina por pagina, elemento por elemento com medicoes CSS) eh o fluxo PADRAO de toda rodada de QA. Nao eh "QA pesado especial" — eh O QA.

**Why:** Flavio testou manualmente e achou bugs visuais que 3 rounds de QA + 5 rounds de Advogado nao pegaram (logo 144px, dark mode nao funciona, emojis em titulos). QA rapido/checklist nao funciona pra design.

**How to apply:**
- Todo QA spawned DEVE incluir varredura visual exaustiva como parte integral (nao separada)
- Cada tela de cada persona: screenshot + medicao de font-size, padding, shadow, cores, logo, emojis
- Dark mode E light mode em cada tela
- Output inclui valores CSS medidos, nao so "PASS/FAIL"
- Nunca mais spawnar "QA rapido" que so checa funcionalidade
