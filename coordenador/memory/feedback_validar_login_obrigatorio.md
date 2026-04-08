---
name: Validar login temporario e obrigatorio antes de aceitar entrega do Dev
description: CRITICO - Apos o Dev entregar, ANTES de qualquer outra coisa, abrir Playwright e testar login de CADA usuario temporario. Se nao funcionar ou SFs derem 403, nao aceitar.
type: feedback
---

Apos o Dev Agent entregar o sistema, o Coordenador DEVE:

1. Abrir Playwright e testar login com CADA usuario temporario pela interface real
2. Apos logar, clicar em pelo menos 2 telas e verificar que carregam (nao ficam em "Carregando..." infinito)
3. Se o login falhar OU as SFs derem 403, NAO aceitar a entrega — devolver pro Dev imediatamente
4. NUNCA testar login so pela SDK — isso testa o backend isolado, nao o fluxo real

O padrao correto de login temporario usa o TOKEN DE SERVICO do backend (sk_333...) configurado via VITE_MITRA_SERVICE_TOKEN no .env do frontend. O Dev deve seguir as instrucoes em developer.md secao "Usuarios Temporarios".

**Why:** Na primeira entrega do Canal de Denuncia, o login funcionava (hardcoded) mas as SFs retornavam 403 porque nao havia token valido. O QA ficou travado.

**How to apply:** Ao validar entrega do Dev via Playwright, verificar nao so que o login funciona mas que as TELAS CARREGAM com dados. Se "Carregando..." infinito, o token de servico nao esta configurado.
