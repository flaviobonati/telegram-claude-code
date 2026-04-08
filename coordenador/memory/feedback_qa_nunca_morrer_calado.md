---
name: QA nunca pode morrer calado
description: Se QA encontrar bloqueio, deve parar e reportar imediatamente. Coordenador corrige e re-spawna.
type: feedback
---

O QA Agent NUNCA pode retornar output vazio. Se encontrar qualquer bloqueio (login falha, pagina em branco, erro 403):

1. Para imediatamente
2. Reporta o bloqueio com screenshot e descricao
3. Retorna o relatorio parcial

O Coordenador recebe, corrige o problema, e re-spawna o QA. O QA nao tenta contornar nem continuar testando com problema.

**Why:** Na primeira execucao do QA no Canal de Denuncia, ele travou no login (que nao funcionava), tentou logar com todas as personas, todas falharam, e retornou output vazio (1 byte). O Coordenador nao soube que o QA falhou ate ver os screenshots manualmente. Flavio ficou frustrado com razao.

**How to apply:** Prompt do QA atualizado com "Regra #1: NUNCA morrer calado". Alem disso, o Coordenador deve validar login via Playwright ANTES de spawnar o QA — se o login nao funciona, nao adianta spawnar QA.
