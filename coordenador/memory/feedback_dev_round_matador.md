---
name: Round pos-QA matador (buglist completo)
description: Apos QA reprovar, mandar TODOS os bugs no mesmo round (com buglist obrigatorio). Dev nao entrega ate 100% DONE. Mundo perfeito = 2 rounds totais.
type: feedback
---

Quando QA reprova, Coordenador manda TODOS os N bugs no mesmo round Dev (nunca parcial). Buglist obrigatorio em frontend/buglist.md com Status PENDING -> IN_PROGRESS -> DONE com arquivo:linha. Dev nao entrega ate 100% DONE.

**Why:** mandar parcial garante R3, R4, R5. Mandar tudo = round matador. Mundo perfeito = QA pega tudo + Dev resolve tudo = 2 rounds totais (Dev R1 -> QA reprova -> Dev R2 mata -> QA R2 aprova). Aceitavel = 3 rounds com 1-2 excecoes. Acima eh falha do Coordenador.

**How to apply:**
- Coordenador.md REGRA #3C
- Toda task pra Dev pos-QA inclui o relatorio completo de bugs do QA
- Buglist obrigatorio com smoke test por bug
- Validar 100% DONE antes de spawnar QA novamente
