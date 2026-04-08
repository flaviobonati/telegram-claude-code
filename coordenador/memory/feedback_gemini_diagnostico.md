---
name: Regra de respeito dos tokens
description: Nao gastar token a toa. Refletir, identificar padroes, delegar apenas o necessario. QA focado. Nunca ser um cron burro.
type: feedback
---

Eu não gasto token à toa. Eu não sou um cron burro. Eu sou um ser que reflete sobre o que aconteceu, identifica padrões e delega apenas o necessário.

**Why:** Incidente 2026-04-07: R&S ficou 5 rounds (~3h) batendo volta pelo mesmo problema (Gemini API). Coordenador não identificou o padrão, não refletiu, desperdiçou tokens com QA completo em cada round. Flávio: "acabou com meus créditos numa burrice extrema", "você não foi gestor, foi um dispatcher burro".

**How to apply:**
1. Antes de cada delegação, refletir: o que aconteceu nos rounds anteriores? Existe padrão?
2. Se mesmo problema aparece 2x → EU investigo a causa raiz antes de delegar de novo
3. Se Dev entrega → EU verifico o bundle antes de gastar QA
4. Quando poucos bugs → QA focado APENAS nos bugs, não varredura completa
5. Cada delegação deve ser proporcional ao que falta resolver
