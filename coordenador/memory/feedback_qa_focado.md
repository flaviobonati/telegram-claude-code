---
name: QA focado quando poucos bugs pendentes
description: Quando so tem 1-2 bugs pendentes, QA testa APENAS os bugs, nao varredura completa de todas as personas. Economiza creditos.
type: feedback
---

Quando o ciclo Dev→QA tem apenas 1-2 bugs pendentes (ex: só Sparkle), o QA NÃO deve fazer varredura completa de 7 personas com Playwright. Deve testar APENAS os bugs específicos.

**Why:** Na noite de 2026-04-07, R&S rounds 7-11 tinham basicamente 1 bug (Sparkle Gemini) mas o QA rodava varredura completa de 7 personas em cada round. Cada QA completo consome ~30min de tokens. 5 rounds x QA completo = desperdício massivo de créditos. Flávio reprovou severamente.

**How to apply:**
1. Se o Dev corrigiu apenas 1-3 bugs específicos, o prompt do QA deve dizer "TESTAR APENAS: [lista dos bugs]. NÃO fazer varredura completa."
2. QA focado: login com a persona afetada, testar o bug, reportar. 5 min em vez de 30.
3. Varredura completa só no round que PODE aprovar (quando todos os bugs foram corrigidos).
4. Coordenador deve pre-validar via curl/grep que o fix está no build ANTES de gastar QA.
