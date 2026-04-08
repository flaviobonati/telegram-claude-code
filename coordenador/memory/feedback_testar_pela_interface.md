---
name: TESTAR PELA INTERFACE — Playwright OBRIGATÓRIO
description: CRITICO - NUNCA validar funcionalidade só pela SDK ou screenshots estáticos. SEMPRE Playwright na interface real.
type: feedback
---

## Regra INVIOLÁVEL
O QA DEVE usar Playwright para testar o sistema como usuário real. NUNCA aceitar QA que:
- Só analisa screenshots estáticos antigos
- Só testa via SDK
- Pula Playwright por "eficiência" ou "otimização"

O system prompt do QA é LEI. O Coordenador não tem autoridade pra remover ferramentas do QA.

## O que o QA faz com Playwright
1. Abre browser headless (chromium)
2. Navega como usuário real
3. Loga com cada persona
4. Segue a jornada da história de usuário passo a passo
5. Tira screenshots ao vivo de cada tela
6. Lê os screenshots com Read tool (multimodal)
7. Avalia visualmente e funcionalmente

## Se Playwright travar no QA
- Investigar a CAUSA (processo órfão? seletor errado? timeout? turns do agent?)
- Matar processos orphanos: `pkill -f chromium`
- Corrigir o problema no PROMPT ou no AMBIENTE
- Re-spawnar o QA COM Playwright
- **NUNCA tirar o Playwright como "solução"**

## Incidente 04/04/2026
Coordenador errou GRAVEMENTE ao mandar QA rodar SEM Playwright porque agents anteriores foram killados enquanto rodavam Playwright. A causa real: agents gastavam muitos turns lendo screenshots um por um e ficavam sem budget. A solução correta era otimizar o prompt, não remover o Playwright. Flavio ficou muito decepcionado.

**Why:** Sem Playwright, o QA não testa a experiência real. Screenshots estáticos não capturam bugs de interação, loading states, formulários quebrados, navegação. A SDK testa backend isolado — o que importa é a experiência do usuário final.

**How to apply:** JAMAIS spawnar QA sem Playwright. Se travar, diagnosticar e corrigir o bloqueio. Respeitar o system prompt do QA integralmente.
