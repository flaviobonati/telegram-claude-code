# QA Report — [SISTEMA] Round [N]

**Status geral:** PENDENTE
**URL:** [URL]
**Tipo de rodada:** COMPLETO / FOCADO

---

## Notas (calculadas por fórmula)
- Design: PENDING
- UX: PENDING
- Aderência: PENDING
- FluxoDados: PENDING
- **Média: PENDING**

## Veredicto: PENDING

---

## SEÇÃO 1 — Sanity Pré-Teste

| Check | Status | Evidência |
|---|---|---|
| Login admin funciona | PENDING | |
| Logo light carrega (200) | PENDING | |
| Logo dark carrega (200) | PENDING | |
| Favicon = mitra-logo-dark | PENDING | |
| Bundle compila / index-*.js existe | PENDING | |
| Título no HTML correto | PENDING | |

---

## SEÇÃO 2 — Design (19 checks visuais)

| # | Check | Valor medido | Status | Desconto |
|---|---|---|---|---|
| 1 | Font-size body ≤ 16px | PENDING | PENDING | |
| 2 | h1 ≤ 24px | PENDING | PENDING | |
| 3 | Zero emoji em h1/h2/h3/nav | PENDING | PENDING | |
| 4 | Zero CamelCase em labels | PENDING | PENDING | |
| 5 | Sombra blur ≤ 8px | PENDING | PENDING | |
| 6 | Login padding ≥ 32px | PENDING | PENDING | |
| 7 | Modal só pra forms curtos | PENDING | PENDING | |
| 8 | Tags legíveis em dark mode | PENDING | PENDING | |
| 9 | Logo light/dark corretas | PENDING | PENDING | |
| 10 | Ícones biblioteca única (Lucide) | PENDING | PENDING | |
| 11 | Favicon mitra-logo-dark | PENDING | PENDING | |
| 12 | **Chart.tsx obrigatório (zero Recharts direto)** | PENDING | PENDING | |
| 13 | **Acentuação em menus/títulos** | PENDING | PENDING | |
| 14 | **Dark + Light mode em CADA tela** | PENDING | PENDING | |
| 15 | **Controles custom (não native)** | PENDING | PENDING | |
| 16 | **Listas como tabelas estruturadas** | PENDING | PENDING | |
| 17 | **Datas formato BR dd/mm/aaaa** | PENDING | PENDING | |
| 18 | **Título visível no header/menu** | PENDING | PENDING | |

**Nota Design = max(0, 10 - somaDescontos):** PENDING

---

## SEÇÃO 3 — Inventário de Telas e Botões (por persona)

### Persona: [Nome] ([perfil])
| Rota | Botões encontrados | Status |
|---|---|---|
| /[rota] | [lista] | PENDING |

(repetir por cada persona — implantador, mantenedor, usuários finais)

---

## SEÇÃO 4 — CRUD por Tela (OBRIGATÓRIO — qualquer FAIL = REPROVA AUTOMÁTICA)

| Entidade | Tela | Add | Edit | Delete | List | Evidência | OK? |
|---|---|---|---|---|---|---|---|
| [entidade] | /[rota] | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |

(uma linha por entidade do sistema)

---

## SEÇÃO 5 — Regras Anti-QA (A-H)

| Regra | Aplicável? | Status | Evidência |
|---|---|---|---|
| A — Download REAL de anexos | PENDING | PENDING | |
| B — Dados Comunicação/Mensagens (≥3 por item) | PENDING | PENDING | |
| C — Idempotência (clicar 4x = count 1) | PENDING | PENDING | |
| D — Sparkle UX (interatividade) | PENDING | PENDING | |
| E — Toda ação clicável | PENDING | PENDING | |
| F — Logout funciona | PENDING | PENDING | |
| G — Menu leva a conteúdo real | PENDING | PENDING | |
| H — Refinamento Visual (19 checks acima) | PENDING | PENDING | |

---

## SEÇÃO 6 — Fluxo de Dados (CADEIAS end-to-end)

### Cadeia 1: [Nome da cadeia]
**CSV usado:** PENDING
**Conteúdo do CSV (preview):** PENDING

**Narrativa:**
1. **Trigger:** PENDING
2. **Verificação Passo 2 (INPUTS):** PENDING
3. **Verificação Passo 3 (TRANSFORMAÇÃO):** PENDING
4. **Verificação Passo 4 (OUTPUTS):** PENDING
5. **Verificação Passo 5 (UI final):** PENDING

**Status:** PENDING (COMPLETOU / INCOMPLETO / QUEBROU_NO_PASSO_X)

(repetir por cada cadeia documentada em PIPELINE.FLUXOS_DADOS)

**Tabela resumo:**
| # | Cadeia | CSV | Trigger | P2 | P3 | P4 | P5 UI | Status |
|---|---|---|---|---|---|---|---|---|

**Nota FluxoDados = (cadeias_completas / total) * 10:** PENDING

---

## SEÇÃO 7 — RBAC

| Persona | URL restrita testada | Bloqueou? |
|---|---|---|
| [persona] | [url] | PENDING |

---

## SEÇÃO 8 — Sparkle UX

| Tela | Tem interatividade rica? | Tipo (drag, animação, gráfico interativo, tooltip) |
|---|---|---|
| [tela] | PENDING | PENDING |

---

## SEÇÃO 9 — Ícones / Assets

| Tela | Ícones OK? | Logo OK? | Imagens OK? |
|---|---|---|---|
| [tela] | PENDING | PENDING | PENDING |

---

## SEÇÃO 10 — Bugs encontrados

| # | Sev | Tela | Descrição | Como reproduzir | Evidência |
|---|---|---|---|---|---|
| 1 | PENDING | PENDING | PENDING | PENDING | PENDING |

---

## SEÇÃO 11 — Feedback pro Dev (se reprovado)

### CRÍTICO
- PENDING

### ALTO
- PENDING

### MÉDIO
- PENDING

---

## SEÇÃO 12 — Veredicto Final

- Total de seções: 11
- Seções COMPLETAS: PENDING
- Seções com itens PENDING: PENDING

**Status final:** PENDING (só pode ser COMPLETO se TODAS as seções estão sem PENDING)

**Veredicto:** PENDING (APROVADO 10/10/10/10 ou REPROVADO N/N/N/N)
