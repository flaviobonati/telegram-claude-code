---
name: Monitoramento e fonte unica da verdade
description: CRITICO - Coordenador DEVE usar banco 45173 como fonte unica, logar TUDO, e monitorar a cada 2min
type: feedback
---

## Regras de monitoramento

1. **Fonte única da verdade**: projeto 45173 na nuvem (tabelas PIPELINE, FEATURES, LOG_ATIVIDADES). SEMPRE verificar lá antes de agir.
2. **Logar TUDO**: cada spawn, cada resultado de QA, cada correção do Dev, cada aprovação. Sem exceção.
3. **Cron de 2min**: configurar `/loop 2m` pra checar status dos sub-agents (wc -c output files). Se morreu, re-spawnar. Se terminou, processar.
4. **Telegram**: msgs chegam instantaneamente via webhook Vercel → tmux send-keys. Responder via `node /opt/mitra-factory/tg.mjs "msg"`.
5. **Sync prompts**: após editar qualquer prompt (researcher.md, developer.md, qa.md), sincronizar na tabela AGENTES do projeto 45173.

## Ao iniciar nova sessão
1. Ler coordinator.md
2. Consultar PIPELINE no banco pra saber estado real de cada sistema
3. Configurar cron de 2min pra monitorar sub-agents
4. Msgs do Flávio chegam via "Telegram de Flávio: ..." no terminal
5. Responder via `node /opt/mitra-factory/tg.mjs "resposta"`

## Incidente 04/04/2026
Nova sessão não usava o banco como fonte da verdade, não logava nada, não checava status. Flávio ficou frustrado. O banco é LEI — tudo registrado lá.

**Why:** Sem monitoramento proativo, sub-agents morrem calados e o trabalho para. Sem logs, não há rastreabilidade. Sem fonte única, cada sessão reinventa o estado.

**How to apply:** Primeira coisa ao acordar: ler coordinator.md, consultar banco, configurar cron, retomar trabalho.
