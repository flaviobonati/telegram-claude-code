---
name: Anti deploy cruzado
description: Regras para evitar que um projeto seja deployado em cima de outro. Incidente real em 03/04/2026.
type: feedback
---

## Incidente (03-04/Abr 2026)
Canal de Denúncia foi deployado em cima do Help Desk. Causa raiz:
1. Path genérico `/tmp/pkg/` usado por múltiplos projetos
2. Tar sem estrutura correta (`src/frontend/` + `output/`) — deploy retornava sucesso mas não atualizava index.html
3. Projeto órfão p-45374 (Canal antigo) deixou lixo no /tmp

## Regras (OBRIGATÓRIO)

### Path de staging
- SEMPRE usar `/tmp/pkg-{PROJECT_ID}/deploy.tar.gz`
- NUNCA `/tmp/pkg/` genérico
- NUNCA reutilizar path de outro projeto

### Estrutura do tar (CRÍTICO)
```
src/
  frontend/    ← código fonte completo (sem node_modules/dist)
output/        ← conteúdo do frontend/dist/
```
- `cd /tmp/pkg-{PROJECT_ID} && tar -czf deploy.tar.gz src output`
- ERRADO: colocar só o dist na raiz do tar (deploy "sucede" mas não atualiza)

### Validação no deploy.mjs
- Verificar que tarPath contém o PROJECT_ID correto
- Logar `[ANTI-DEPLOY-CRUZADO] Projeto: X | Tar: Y` antes de deployar

### Verificação pós-deploy
- `curl -s https://{wsId}-{pjId}.prod.mitralab.io/ | grep "<title>"` deve mostrar o título CORRETO
- VALIDAR project ID no .env, no deploy, e no branding da URL

## Scripts atualizados
- deploy.mjs de p-45490, p-45502, p-45504 corrigidos
- subagent_standard_briefing.md atualizado
- Dev agent (AGENTES tabela, projeto 45173) sincronizado com novo briefing

**Why:** Deploy cruzado destrói produto e gera retrabalho massivo.
**How to apply:** Antes de qualquer deploy, verificar path + estrutura + project ID. Após deploy, curl no título.
