---
name: Regras de design obrigatórias para todo sistema
description: Todo sistema deve ter dark/light mode, logo Mitra, cards flat, Chart.tsx, controles custom, tabelas, datas BR, acentuação
type: feedback
---

O Flávio quer design FUTURISTA em todo sistema. Regras obrigatórias:

1. Dark mode + Light mode com toggle sol/lua (lucide Sun/Moon). Light é padrão.
2. Logo Mitra oficial: /opt/mitra-factory/assets/mitra-logo-light.svg (light) e mitra-logo-dark.svg (dark). NUNCA logo genérica.
3. Cards FLAT sem sombra excessiva. Border sutil + background sólido.
4. Gráficos: APENAS Chart.tsx do template (ShadcnBarChart, etc). NUNCA Recharts direto.
5. Controles custom: NUNCA select/date/checkbox nativo do browser.
6. Listas: SEMPRE tabelas estruturadas (header fixo, hover, ações, busca, filtros, paginação). NUNCA cards centralizados.
7. Datas formato brasileiro: dd/mm/aaaa.
8. Acentuação correta em TODOS os textos e dados sample.
9. Cada perfil deve ver tela DIFERENTE (sidebar e home diferentes).
10. Referência visual: Linear, Vercel, Notion.

**Why:** O Flávio achou o design do primeiro sistema "antigo". Definiu essas regras como padrão permanente.

**How to apply:** Incluir essas regras no prompt de CADA Dev spawn. O QA tem /opt/mitra-factory/output/design_reference.md como checklist.
