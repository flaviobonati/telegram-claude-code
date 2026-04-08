---
name: Ordem obrigatória — Implantador > Mantenedor > Usuários
description: Histórias de usuário SEMPRE na ordem: 1o Implantador (setup), 2o Mantenedor (dia a dia), 3o Usuários finais. GUIAS_TESTE segue mesma ordem.
type: feedback
---

Ordem INVIOLÁVEL nas histórias de usuário:
1o) IMPLANTADOR — como configura o sistema do zero (cada cadastro, cada entidade, cada vinculação)
2o) MANTENEDOR — como mantém no dia a dia (ajustes, novos cadastros)
3o) USUÁRIOS FINAIS — como cada persona usa o sistema já configurado

**Why:** Sem Implantador, Dev cria features desconexas (SPIFF sem vínculo com produto, campanha sem indicador). Sistema fica "apresentação de features" em vez de produto usável. Aconteceu em Comissões, Planejamento, Help Desk — 100% do trabalho perdido.

**How to apply:** researcher.md tem ordem obrigatória. coordinator.md tem cruzamento features x histórias. GUIAS_TESTE segue mesma ordem (Flávio testa implantação primeiro).
