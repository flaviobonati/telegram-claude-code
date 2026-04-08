---
name: Playwright zombies causam travamento de QA
description: Processos Node+Chromium orfaos ficam presos apos QA morrer, consumindo RAM ate travar os proximos QAs
type: feedback
---

Quando um QA sub-agent e killed (SIGTERM), os processos Node rodando Playwright (node -e '... chromium.launch()') que ele lancou viram ORFAOS (parent = init) e NAO morrem junto. Ficam presos hora(s) consumindo RAM.

**Sintomas:**
- QAs novos travam sem output
- CPU time nao avanca
- Memoria livre < 300MB
- `ps -ef | awk '$3 == 1 && /node -e.*chromium/'` mostra processos antigos

**Why:** Playwright lanca chromium como child. Quando claude -p e killed, os child node processes ficam orfaos. Sem swap e com 3.8GB RAM, 4-5 zombies consomem RAM suficiente pra travar os proximos QAs (OOM soft).

**How to apply:**
1. ANTES de spawnar QA, limpar zombies: `ps -ef | awk '$3 == 1 && /node -e.*chromium/ {print $2}' | xargs -r kill`
2. Se QA morrer, SEMPRE verificar e matar os orfaos de Playwright
3. NUNCA reduzir prompt pra contornar — investigar causa real
4. Monitorar `free -h` — se < 300MB livre com QAs rodando, provavelmente tem zombies
