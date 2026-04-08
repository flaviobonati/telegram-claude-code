---
name: Dev afirma OK sem validar — exigir curl pos-deploy
description: Dev agent tem habito de afirmar que uma correcao esta feita sem validar via curl/Playwright apos deploy. Exigir evidencia.
type: feedback
---

Padrao observado: Dev agent olha o codigo local, ve que o import/componente esta la, e afirma "ja estava OK". Mas o bundle de producao pode ter conteudo diferente (build falhou silenciosamente, SVG nao copiado pro public/, etc).

**Incidente 1 (04/04/2026):** Dev Planejamento Estrategico afirmou "Logo Mitra ja estava OK — Layout.tsx e LoginPage.tsx ja usavam /mitra-logo-dark.svg". QA R2 validou via curl: os SVGs NAO estavam em frontend/public/ nem servidos. Logo ausente completamente. Reprovacao 5/4/6.

**Incidente 2 (04/04/2026):** Dev Help Desk R1 afirmou "logo ja estava correto". QA R2 verificou e reprovou por logo generica. Dev R2 finalmente corrigiu de verdade.

**Why:** Dev confia no codigo fonte sem verificar se o bundle de producao carregou o arquivo. Build pode falhar silenciosamente ou o asset nao ir pro output.

**How to apply:** Em TODOS os prompts de Dev daqui pra frente, incluir instrucao explicita:
- Se for afirmar que algo esta OK, DEVE incluir no output o resultado de curl do asset/HTML.
- Para SVGs: curl URL/arquivo.svg DEVE retornar 200 com conteudo SVG.
- Para refs no HTML: curl URL/ | grep <ref> DEVE achar.
- Coordenador deve verificar via Playwright/curl antes de spawnar QA.
