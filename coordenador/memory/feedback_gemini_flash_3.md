---
name: IA da fabrica = Gemini Flash 3
description: Toda feature de IA/Sparkle dos sistemas da fabrica DEVE usar Gemini Flash 3. Chave unica pra fabrica toda sera fornecida pelo Flavio.
type: feedback
---

Regra: toda feature de IA (classificacao, sugestao, sumarizacao, sparkle) nos sistemas gerados pela fabrica DEVE chamar **Gemini Flash 3**. Nao aceitar classificador SQL/heuristico disfarcado de IA.

**Why:** Flavio descobriu que Help Desk e Canal de Denuncia implementaram "Sparkle IA" como heuristica SQL em Server Function (sem chamada LLM real). Ele quer IA de verdade e vai fornecer **uma unica chave de Gemini Flash 3 pra toda a fabrica**.

**How to apply:**
- Modelo correto: `gemini-3-flash-preview` (NAO `gemini-2.0-flash` — retorna 404 pra conta nova)
- Endpoint: `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key={KEY}`
- Chave unica da fabrica (2026-04-05): `AIzaSyD0fTbcu4CimuNklRxJmvAkLudsye5eyYA` — plantar em cada sistema como `VITE_GEMINI_API_KEY`
- Instruir Dev a integrar em TODA feature de IA
- QA deve verificar no network (DevTools/Playwright) se a chamada vai pro endpoint do Gemini — rejeitar se for so SF/SQL
- Sistemas ja entregues (Help Desk, Canal de Denuncia) precisam ser retrabalhados pra trocar o classificador heuristico por Gemini Flash 3
