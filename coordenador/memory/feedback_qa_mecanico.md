---
name: QA mecânico — inventário + teste botão por botão
description: QA faz inventário de rotas/botões, depois testa CADA botão. Nota = passaram/total. Tabela de cobertura obrigatória. Validado 2026-04-07.
type: feedback
---

QA em 3 fases:
1. INVENTÁRIO: listar todas rotas + todos botões de cada tela
2. TESTE MECÂNICO: clicar cada botão, preencher forms, verificar DOM
3. RELATÓRIO: tabela cobertura (rota | total | testados | passaram | falharam)

Nota UX = (botões passaram / total) * 10. Impossível mentir.

**Why:** QA narrativo dava 10/10/10 falso — escrevia "cliquei e funcionou" sem testar. Flávio encontrou 9 bugs óbvios que QA R1 não pegou. QA R3 mecânico encontrou todos.

**How to apply:** qa.md seção "Round COMPLETO" com 3 fases. Ainda precisa de 3 tentativas consistentes + aprovação do Flávio pra considerar validado.
