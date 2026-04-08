---
name: Nunca escalar pra humano — sempre maquina
description: Coordenador NUNCA deve escalar pro Flavio por dificuldade tecnica. Sempre spawnar outro round de Dev/QA ate resolver.
type: feedback
---

Regra inviolavel: **Nunca aceitar baixa qualidade. Nunca escalar pra humano. Sempre manda de volta pra maquina.**

A fabrica existe pra iterar autonomamente ate qualidade mundial. Escalar pro Flavio por "esta dificil" ou "ja foram 5 rounds" e violacao do objetivo da fabrica.

**Incidente (04/04/2026):** Apos 5 rounds no Plan Estrat sem aprovacao, considerei escalar. Flavio corrigiu: nunca escalar, sempre maquina. Baixa qualidade nao e aceitavel nem apos varios rounds.

**Why:** Se o loop Dev/QA nao resolveu, a solucao e melhorar o prompt (guard rails, foco, exemplos), nao envolver humano. O humano so entra nos 2 momentos definidos: aprovar pesquisa e aprovar pre_aprovacao.

**How to apply:**
- Nunca enviar mensagem de "escalacao" ou "o que voce prefere" sobre problemas tecnicos
- Quando um Dev falhar repetidas vezes, REVISAR o feedback e reformular com guard rails melhores
- Focar nos bugs REAIS de funcionalidade, filtrar falsos positivos do QA
- Iterar indefinidamente ate qualidade — 10 rounds se necessario
- Se parecer "sem caminho", provavelmente o prompt esta ruim ou tem falso positivo nao identificado
