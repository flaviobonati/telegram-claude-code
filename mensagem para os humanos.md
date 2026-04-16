# Mensagem para os humanos — mudanças na fábrica em 2026-04-16

Quem fez: Flávio + Claude (Coordenador). Sessão de ~5 horas validando a etapa de Re-Round (production-grade) em 2 sistemas — Mitra Controle Orçamentário (CO) e Mitra Help Desk (HD). Resultado: várias mudanças no jeito da fábrica trabalhar. Esta mensagem explica em linguagem natural o que mudou e por quê.

---

## TL;DR pros pressados

7 mudanças, todas commitadas em `main`:

1. **PROIBIDO PDF pra demonstrar dados** — relatórios gerenciais agora são **HTML interativo** dentro do próprio sistema. Puppeteer/jsPDF banidos.
2. **Pesquisa profunda do incumbente, com fonte por afirmação** — toda afirmação sobre como o incumbente funciona precisa de URL da docs oficial; sem URL, é "FONTE NÃO ENCONTRADA, perguntar usuário"; proibido inventar.
3. **Lacunas viram 3-opções pro Flávio** — quando o incumbente não tem feature que o cliente precisa, o Pesquisador apresenta (a) igual incumbente / (b) sugestão player X com URL / (c) Mitra inventa. Flávio decide.
4. **Re-Round agora tem 2 fases (preparação + execução)** com 7 passos obrigatórios.
5. **Persistência de HISTÓRIA + LISTA DE FEATURES no banco da AF** — vira aba na UI pro Flávio consultar.
6. **Lista de features avaliada em 3 buckets** antes de ir pro Flávio (CORRETO / SIMPLISTA / OVERKILL) — Coordenador nunca despacha cru.
7. **QA Implantador entrega 4 seções padrão + 3 obrigatórias adicionais** (feature-a-feature 0-10 / narrativa 1ª pessoa / o que deu certo).

Tudo está no Git. Pra atualizar a Autonomous Factory de vocês: leiam `atualizar a Autonomous Factory.md` na raiz do repo.

---

## Mudança 1 — PROIBIDO PDF pra demonstração de dados (commit `599f8aa`)

**Onde:** `coordenador/coordinator.md` §19.5 + `coordenador/sub-agents/dev/dev.md` §12.16.1

**O que mudou:** quando o sistema precisa apresentar dados (Board Pack, dashboard, DRE/BP/DFC, relatório gerencial), está **proibido** gerar PDF via Puppeteer, jsPDF, html2pdf ou qualquer biblioteca. Em vez disso, o Dev cria uma **rota HTML interativa** dentro do próprio sistema (ex: `/board-pack/Q1-2026`) com tabelas, gráficos, comentários, drill-down e dark/light mode. Quando o usuário precisa "PDF de verdade" pra reunião, ele usa **Ctrl+P → Salvar como PDF** do próprio browser (CSS `@media print` deixa formatado).

**Exceção única:** documentos legais/fiscais de formato fixo (NF-e, contratos assinados, recibos, boletos) — esses podem ser PDF, mas usando lib server-side simples, **não Puppeteer**.

**Por quê:** da última vez que tentamos Board Pack PDF a fábrica perdeu rounds inteiros tentando fazer Puppeteer funcionar (limitação de fontes, sem interatividade, dark mode quebra, performance ruim, frágil em produção). HTML interativo é "muito mais bonito" (palavras do Flávio) e respeita o resto do sistema.

**Como vocês usam:** se o briefing do sub-agente mencionar "PDF de relatório", o Coordenador agora SUBSTITUI por "rota HTML + share via URL autenticada ou Imprimir do browser". O Dev tem regra explícita pra rejeitar Puppeteer/jsPDF. O QA reprova se vir.

---

## Mudança 2 — Pesquisa profunda do incumbente, com fonte por afirmação (commit deste push)

**Onde:** `coordenador/coordinator.md` §19.6.A + `coordenador/sub-agents/reround/reround_researcher.md` §3 Fase 1

**O que mudou:** antes de spawnar o Re-Pesquisador (modo SCOPING) ou de produzir a história Dia 1, o Coordenador agora **exige** um arquivo `pesquisa_<incumbente>_deep.md` com pesquisa profunda. Regras:

- **Fonte por afirmação:** cada fato sobre o incumbente DEVE vir com URL da docs oficial (`help.<x>.com`, `support.<x>.com`, `docs.<x>.com`). Sem URL = fato inválido.
- **Proibido inventar:** onde não achar fonte, escrever EXPLICITAMENTE `⚠️ FONTE NÃO ENCONTRADA — perguntar ao Flávio`. Lista vai pro Flávio decidir junto.
- **Profundidade mínima:** 15-20 WebFetches por sistema incumbente. Pesquisa rasa = rejeitada.

**Por quê:** numa rodada anterior o Pesquisador descreveu features do Accountfy baseado em adivinhação ("o sistema sugere quando bate com pattern", "conta nova vira filha automaticamente"). Flávio rejeitou. Repetimos com pesquisa profunda direto em `help.accountfy.com` e produzimos um arquivo de 162 linhas com 30+ URLs e veredicto preciso de o que existe / o que não existe. Diferença abissal de qualidade.

**Como vocês usam:** quando o seu Coordenador for rodar Re-Round, ele agora vai antes spawnar um agente de pesquisa profunda (WebSearch + WebFetch direto na docs do incumbente) e validar fonte por fonte. Resultado: sistemas mais fiéis ao incumbente, menos rounds desperdiçados.

---

## Mudança 3 — Lacunas viram 3-opções pro Flávio (mesmo commit)

**Onde:** mesma seção da Mudança 2.

**O que mudou:** quando a pesquisa identifica que o incumbente **não tem** uma feature que o cliente precisa (lacuna), o Pesquisador agora **não inventa solução Mitra do nada**. Ele:

1. Pesquisa 2-3 outros players do mesmo mercado (ex: pra Accountfy → Adaptive Insights, Anaplan, Vena, Workday Adaptive, Oracle FCC, OneStream)
2. Documenta como cada player resolve, com URL
3. Apresenta pro Flávio em formato 3-opções:
   - (a) IGUAL INCUMBENTE (não fazer)
   - (b) SUGESTÃO PLAYER X (com URL)
   - (c) SUGESTÃO MITRA INVENTADA

Flávio decide qual. **Coordenador nunca escolhe sozinho.**

**Por quê:** Flávio explicitou em mensagem do dia 16/abr: "pesquisar outros players que fazem essa parte e colocar sugestão baseada em algum player que viu — aumenta muito minha confiança". Esse formato cortou ~10 idas-e-voltas que aconteceriam se o Coordenador chutasse uma solução.

---

## Mudança 4 — Re-Round agora tem 2 fases (preparação + execução), 7 passos (commit `b6819da` + `7afcf4d`)

**Onde:** `coordenador/coordinator.md` §19.6 + `§5` (máquina de estados)

**O que mudou:** o Re-Round virou explicitamente um processo de **2 fases**:

- **Fase 1 — Preparação (passos 0–4):** Coordenador escreve história Dia 1, valida com Usuário, spawna Re-Pesquisador modo SCOPING (mapeia features do incumbente), avalia em 3 buckets, valida lista com Usuário
- **Fase 2 — Execução (passos 5–6):** loop Dev ⇄ Re-Pesquisador modo TESTING (ele testa CADA feature via Playwright vs lista aprovada, dá nota 0-10 por feature, calcula % production-ready), e por fim QA Implantador roda a história Dia 1 inteira pela UI como se fosse cliente real

A máquina de estados agora tem 2 status separados (`preparacao_reround` e `execucao_reround`) e cada round grava 1 linha em `HISTORICO_REROUND` (banco da AF) com fase, gaps, notas e veredicto.

**Por quê:** misturar preparação com execução escondia falhas — a fábrica achava que estava "rodando Re-Round" quando na verdade estava só pesquisando, ou estava só testando sem ter alinhado a história. Separar deixou cada fase auditável.

---

## Mudança 5 — Persistência de HISTÓRIA + LISTA DE FEATURES no banco da AF (commit `7afcf4d`)

**Onde:** `coordenador/coordinator.md` §19.6 Passos 0 e 2

**O que mudou:** o Coordenador agora **grava** dois conteúdos grandes (TEXT) na tabela `PIPELINE` do banco da AF:

- `HISTORIA_IMPLANTACAO` (Passo 0) — a história de usuário Dia 1 inteira (markdown, 30k+ chars)
- `LISTA_FEATURES_REROUND` (Passo 2) — a lista de features mapeadas do incumbente com descrições

Ambas viram **abas na UI da AF** pro Flávio consultar a qualquer momento (sem precisar abrir o tmux do Coordenador).

**Detalhe técnico importante:** TEXT-grande NÃO persiste via `patchRecord` (corta). Tem que usar `runDmlMitra` com UPDATE direto + stripar emojis 4-byte (caracteres `\u{10000}-\u{10FFFF}`) que o MySQL standard recusa. O Coordenador faz isso automaticamente.

**Por quê:** sem persistir, cada conversa nova precisava reconstruir o contexto. E o Flávio quer poder abrir a AF no celular e ler a história de qualquer projeto sem precisar mexer no terminal.

---

## Mudança 6 — Lista de features avaliada em 3 buckets antes do Flávio (commit `7afcf4d`)

**Onde:** `coordenador/coordinator.md` §19.6 Passo 3

**O que mudou:** o Coordenador NUNCA mais despacha a lista de features do SCOPING crua pro Usuário. Antes de enviar, classifica cada item em 3 buckets:

- ✅ **CORRETO** — feature alinhada com a história, cliente real precisa
- 🤏 **SIMPLISTA** — descrição rasa, falta granularidade, precisa Re-Pesquisador detalhar mais
- ⚠️ **OVERKILL** — extrapola a história Dia 1 ou é vaidade vs necessidade real

Mensagem Telegram chega pro Flávio com 3 seções claras + recomendação final do Coordenador (entra como está / volta pro Passo 2 com ajustes).

**Por quê:** sem essa avaliação, o Flávio recebia lista crua e tinha que avaliar sozinho — perdia o valor de ter o Coordenador no meio. Agora ele só decide "concordo com sua avaliação?" em vez de "essa lista tá boa?".

---

## Mudança 7 — QA Implantador entrega 4 seções padrão + 3 obrigatórias adicionais (commits `1368b7c` + `ccf5f6e` + `7afcf4d`)

**Onde:** `coordenador/sub-agents/reround/reround_researcher.md` §2.1 modo IMPLANTADOR + `coordenador/coordinator.md` §19.6 Passo 6

**O que mudou:** o último passo do Re-Round (Passo 6 — QA Implantador) é o validador final antes do sistema ir pro Usuário testar. Ele agora obrigatoriamente:

- Lê **`qa.md` INTEIRO + `reround_researcher.md` INTEIRO + coordinator.md §19.6 Passo 6 + história Dia 1 + último QA + último HISTORICO_REROUND**
- Executa a história Dia 1 **EXCLUSIVAMENTE pela UI via Playwright** (SDK proibido pra disparar ação; SDK só pra SELECT verificar persistência APÓS ação na UI)
- **Cria entidades NOVAS pela UI** (não confia em seed)

Entrega relatório com **4 seções padrão** (Visual / Funcional / Performance / Vocabulário) + **3 seções obrigatórias adicionais**:

- **E) FEATURE-A-FEATURE com nota 0-10** — tabela com TODA feature MUST e nota individual
- **F) NARRATIVA passo-a-passo da implantação** em 1ª pessoa, click-a-click pela UI
- **G) O QUE DEU CERTO** — wins do sistema (calibrar confiança, não só ver bugs)

**Sem essas 3 seções (E, F, G) → relatório REJEITADO pelo Coordenador.**

**Por quê:** rounds anteriores tiveram QA que validou backend perfeito mas o wizard estava totalmente desalinhado com a história, ou listou só problemas e mascarou que o sistema estava 80% bom. Forçar narrativa em 1ª pessoa + nota por feature + seção de wins corrigiu os dois.

---

## O que NÃO mudou (mas vocês podem precisar saber)

- **Estrutura do repo:** continua a mesma. `coordenador/` tem os prompts, `mitra-agent-minimal/` tem o template do Dev Agent, `tg.mjs` faz Telegram bidirecional.
- **Como rodar a fábrica:** continua igual — Coordenador no tmux, Telegram pra interagir, sub-agentes spawnados via `claude -p`.
- **Banco da AF:** continua individualizado por instância. Mudanças nos prompts (back-end) não tocam o banco.
- **Template do Dev Agent** (`mitra-agent-minimal/template/`) é vendorizado LOCAL no repo da fábrica, NÃO em S3. `git pull` atualiza o template local. `createProjectMitra` copia esse template pra cada projeto novo que a fábrica cria. **Sistemas já existentes não recebem update automático do template** — recebem a versão que estava vigente no momento da criação. Pra trazer mudanças do template pra um sistema existente, num round futuro, o Dev Agent tem que copiar manualmente os arquivos novos do `template/` pro working dir do projeto. `pullFromS3Mitra` NÃO serve pra isso (ele traz o bundle deployado, não o template).

---

## Como vocês colocam tudo isso na AF de vocês

Está em `atualizar a Autonomous Factory.md` na raiz do repo. TL;DR:

```bash
cd /opt/mitra-factory
git pull
```

Só isso. Os prompts (`.md`) são lidos do disco sob demanda — sem cache. Próxima conversa nova com o Coordenador de vocês já roda no padrão novo. Se quiser que a conversa ATUAL já aplique, peça via Telegram: "Lê o `coordenador/coordinator.md` atualizado e me resume o que mudou".

---

## Quem é a referência

Flávio (`@flaviobonati` no GitHub). Se algo aqui não fizer sentido pra vocês ou conflitar com como a AF de vocês trabalha, fala com ele primeiro antes de divergir do que está documentado.
