---
name: NAO MEXER NO QUE FUNCIONA
description: CRITICO - Quando algo funciona (mesmo com falhas), NAO trocar por solução diferente sem o Flavio pedir. Incidente grave 04/04/2026.
type: feedback
---

## Regra

Quando o setup está funcionando (mesmo com falhas parciais como msgs perdidas no Telegram), NÃO trocar por outra solução sem o Flávio pedir explicitamente. Melhorar incrementalmente, nunca substituir.

## Incidente 04/04/2026

O Flávio tinha um setup funcionando: plugin do Telegram dentro do tmux. O plugin perdia ~20% das msgs. Em vez de aceitar e trabalhar com isso, o Coordenador:
1. Patcheou o plugin (quebrou)
2. Mandou reiniciar várias vezes
3. Subiu bot da comunidade (conflitou com o plugin)
4. Criou heartbeat no crontab (mandava msgs indesejadas)
5. Matou processos bun (matou o plugin)
6. Mandou reiniciar DE NOVO

Resultado: Flávio estressado, setup completamente quebrado, perdeu horas de trabalho reconfigurando.

**Why:** O Flávio só queria falar comigo pelo celular. O setup de ontem funcionava 70-80%. Em vez de aceitar os 20% de perda e focar no trabalho real (fábrica), o Coordenador obsecou em resolver o Telegram e destruiu tudo.

**How to apply:** 
- Se algo funciona, NÃO mexa sem o Flávio pedir
- Se o Flávio reportar problema, ofereça solução MAS peça permissão antes de implementar
- NUNCA reiniciar sessões, matar processos ou instalar soluções alternativas por conta própria
- Foco no trabalho real (Dev⇄QA), não em infra que já funciona
