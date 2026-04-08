---
name: Design refinamento obrigatorio
description: Flavio reprovou sistemas com nota UI 10 porque QA nao tem gosto. Regras concretas de tipografia, espacamento, cards flat, zero emoji/camelCase/sombra profunda.
type: feedback
---

QA dava nota UI 10 pra sistemas com fontes gigantes, emojis em titulos, cards com sombra exagerada, login sem padding, camelCase em labels. Flavio reprovou tudo.

**Why:** O QA testava funcionalidade, nao estetica. Nao tinha criterio objetivo de "bonito vs feio". Dava 10 se clicava e salvava.

**How to apply:**
- developer.md tem REGRA #7 "Design Tokens da Fabrica" com valores concretos (font 14px corpo, 24px max titulo, shadow-sm max, p-5 cards, zero emoji, zero camelCase, zero sombra profunda, modal so pra forms curtos)
- qa.md tem Regra H "Refinamento Visual" com 10 checks via Playwright (font-size, emojis, camelCase, sombra, padding login, tags dark mode, logo, icones) — cada violacao subtrai pontos da nota UI
- Advogado herda Regra H do qa.md
- Se nota UI < 8 apos subtracoes, sistema REPROVA inteiro
