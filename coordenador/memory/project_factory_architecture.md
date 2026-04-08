---
name: Arquitetura atual da Fabrica Autonoma
description: Agentes ativos e decisoes arquiteturais da fabrica - Coordenador, Pesquisador, Dev, QA
type: project
---

A Fabrica Autonoma Mitra tem 4 agentes efetivos:
1. **Coordenador** (eu) - unico ponto de contato com Flavio, orquestra pipeline, grava no banco (projeto 45173)
2. **Pesquisador** - pesquisa verticais, tambem faz escopo (absorveu o Escopador)
3. **Dev Agent** - desenvolve sistemas no Mitra
4. **QA Agent** - testa e avalia (absorveu o Eval Agent)

**Why:** Flavio simplificou de 6 agentes pra 4 apos experiencia com thread anterior. Eval foi absorvido pelo QA, Escopador pelo Pesquisador. Menos handoff = menos perda de contexto.

**How to apply:** Nao referenciar Eval ou Escopador como agentes separados. Os arquivos eval.md e scoper.md em /opt/mitra-factory/prompts/ estao descontinuados. Prompt do coordenador fica so local (nao vai pro banco AGENTES).
