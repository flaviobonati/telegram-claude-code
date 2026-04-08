---
name: Desligar cron quando nao tiver agente rodando
description: Quando todos os sub-agents terminarem, deletar o cron de monitoramento pra nao pingar o coordenador inutilmente.
type: feedback
---

Quando nao tiver nenhum sub-agent rodando (ps claude -p = 0) E nao espera spawnar tao cedo (aguardando humano), DELETAR o cron de monitoramento via CronDelete.

**Why:** O cron a cada 2min pinga o coordenador e consome contexto/ciclos a toa. So faz sentido ter cron quando tem trabalho pra monitorar.

**How to apply:**
- Apos mover sistemas pra pre_aprovacao e aguardando feedback humano: CronDelete
- Antes de spawnar novo sub-agent: CronCreate com intervalo de 2min
- Padrao: cron so existe quando ha trabalho ativo
