# Coordinator Tasks — Controle Orçamentário (CO) até Produção

**Sistema:** CO (projeto 46125 / ws 19049 / pipeline 52)
**URL:** https://19049-46125.prod.mitralab.io/
**Incumbente:** Accountfy (principais referências: CCH Tagetik, Vena, Prophix, Longview, Planful)
**Status atual:** `preparacao_reround` · Fase A · próxima task A5
**Data criação:** 2026-04-17
**Dono:** Coordenador (Opus 4.7). Flávio aprova marcos 🔒.

Legenda: `[x]` feito · `[ ]` pendente · `[🔒]` aguardando Flávio · `[→]` em andamento · `[?]` decisão aberta

---

## FASE A — PREPARAÇÃO RE-ROUND (§19.6 Passos 0–3)

| ID | Task | Entregável | Dependências | Status |
|---|---|---|---|---|
| A0 | Criar task list global até produção | `output/coordinator-tasks_controle_orcamentario.md` (este arquivo) | — | [x] |
| A1 | Mapear sistema atual | `output/mapa_sistema_controle_orcamentario.md` + `PIPELINE.MAPA_SISTEMA` | A0 | [x] |
| A2 | Escrever historia_sistema_atual (Playwright + source) | `output/historia_sistema_atual_controle_orcamentario.md` + `PIPELINE.HISTORIA_SISTEMA_ATUAL` | A1 | [x] |
| A3 | Escrever historia_incumbente (WebFetch Accountfy+concorrentes, 15-20 URLs) | `output/historia_incumbente_controle_orcamentario.md` + `PIPELINE.HISTORIA_INCUMBENTE` | A1 | [x] |
| A4 | Escrever historia_intencionada (Flávio narra) | `output/historia_intencionada_controle_orcamentario.md` + `PIPELINE.HISTORIA_INTENCIONADA` | — | [x] |
| A5 | Consolidar tabela_historias_combinadas + ALINHAR com Flávio sugestões de melhorias/novas histórias pra V1 produção | `output/tabela_historias_combinadas_controle_orcamentario.md` + `PIPELINE.TABELA_HISTORIAS_COMBINADAS` + approval Telegram | A2+A3+A4 | [→] |
| A6 | Testar cada linha da tabela via Playwright (UI+persistência+propagação+bugs P0/P1/P2+evidências) | `output/tabela_historias_usuario_controle_orcamentario.md` + `output/evidencias/controle_orcamentario/historia_<N>/` + `PIPELINE.TABELA_HISTORIAS_USUARIO` | A5 aprovado | [ ] |
| A7 | Entregar tabela de histórias pro Flávio via Telegram (link+resumo) | msg Telegram | A6 | [ ] |
| A8 | Flávio escolhe GAPS pra V1 produção (1-a-1). Bugs entram TODOS. Consolidar gap_selection | `output/gap_selection_controle_orcamentario.md` + `PIPELINE.LISTA_FEATURES_REROUND` | A7 | [🔒] |

---

## FASE B — EXECUÇÃO: LOOP DEV ⇄ QA (§19.6 Passo 4)

Só dispara após A8 consolidado. Loop até `gap_selection` inteiro entregue.

| ID | Task | Entregável | Dependências | Status |
|---|---|---|---|---|
| B1 | Transição `preparacao_reround` → `execucao_reround` em PIPELINE | PIPELINE.FASE atualizado | A8 | [ ] |
| B2 | Dev sub-agent implementa gap_selection (dev.md + system prompt Mitra + gap_selection; TUDO, sem priorização) | Código no S3 (deployToS3) + declaração de entrega | B1 | [ ] |
| B3 | QA sub-agent valida pela tabela combinada (UI+SDK persistência+propagação) | `output/qa_reround_controle_orcamentario_r<N>.md` + linha em `HISTORICO_REROUND` | B2 | [ ] |
| B4 | Loop B2⇄B3 até gap_selection todo entregue e QA 🟢 em todas linhas | histórico com delta_PERCENT > 30 por round | B3 | [ ] |

**Detector de loop morto** (anti-regresso): 3 rounds com delta_PERCENT < 30 ou nenhum P0 fechado → pausa, pullFromS3, leitura source, refatoração de briefing do Dev, aviso Flávio.

---

## FASE C — QA IMPLANTADORA FINAL + PRODUÇÃO (§19.6 Passo 5)

| ID | Task | Entregável | Dependências | Status |
|---|---|---|---|---|
| C1 | QA Implantadora re-executa tabela INTEIRA como cliente real (implantação Dia 1 + atualização mensal; dados reais do domínio, não seed) | `output/qa_implantadora_controle_orcamentario.md` com veredito 🟢/🔴 | B4 | [ ] |
| C2a | 🟢 APROVADO → transição `execucao_reround` → `producao` + relatório final ao Flávio via Telegram | PIPELINE.FASE='producao' + msg Telegram | C1=🟢 | [ ] |
| C2b | 🔴 REPROVADO → resíduos viram novo gap_selection, volta pra B2 | gap_selection_rev.md | C1=🔴 | [ ] |

---

## TRANSVERSAIS (sempre vigentes)

- **Bússola:** ler este arquivo ANTES de cada nova tarefa, confirmar que a próxima ação pertence ao trilho até produção.
- **Comunicação:** sempre via Telegram (`node tg.mjs "msg"` a partir de /opt/mitra-factory).
- **Persistência:** todo artefato vai tanto pra `output/` quanto pra `PIPELINE.<campo>` via `runDmlMitra` (stripar 4-byte: `.replace(/[\u{10000}-\u{10FFFF}]/gu, '')` + escape `'` → `''`).
- **pullFromS3 obrigatório** antes de editar frontend existente.
- **Nunca podar MUST.** Nunca resumir prompt dos sub-agents (cat inteiro).
- **Atualizar este arquivo** a cada avanço (marcar `[x]`), criar sub-tasks conforme surgem.

---

## Log de decisões (data + fonte)

- **2026-04-17** — Flávio aprovou §19.6 v2.2 (Telegram msgs 3550–3558). Mudanças principais: estrutura 3 fases; Passo 1 com incumbente pesquisado por história (qualidade/método/amplitude) servindo de inspiração pra tabela combinada; Dev recebe TUDO do gap_selection sem priorização; QA Implantadora é gate final de produção.
- **2026-04-17** — `historia_sistema_atual` identificou 10 lacunas factuais no CO (Passo 3 "Inferir Estruturas" viola anti-magia; /fechamento é Kanban sem stepper; SF enviarEmailSendGrid é stub; ausência de 11-option dropdown fixo; sem semáforo DRE; etc).
- **2026-04-17** — `historia_incumbente` consolidada com 17+ WebFetches Accountfy + referências CCH/Vena/Prophix. Gaps marcados `⚠️ FONTE NÃO ENCONTRADA` onde a doc pública não cobria.
- **2026-04-17** — Escopo do CO V1 produção ainda aberto: depende de A5 (tabela combinada) + A7 (teste) + A8 (Flávio escolhe).

---

## Pendências abertas pra Flávio

Nenhuma agora — próximo passo é A5 (tabela combinada + sugestões) e só depois disso volta pro Flávio decidir.
