---
name: Projeto SEMPRE do zero — NUNCA copiar antigo
description: Setup de projeto novo cria pasta vazia com logos + .env. NUNCA copiar código de projeto anterior. Incidente grave 2026-04-07.
type: feedback
---

CADA sistema começa do ZERO. Coordenador cria pasta vazia com apenas logos (de /opt/mitra-factory/assets/) e .env. Dev puxa template do git e desenvolve tudo.

**Why:** Coordenador copiou projeto antigo (p-45638) pro novo Planejamento, contaminando o one-shot. Flávio considerou "roubo" — invalida indicadores da fábrica.

**How to apply:** mkdir vazio + cp logos + criar .env. NUNCA cp -R de projeto anterior. NUNCA reutilizar SFs, frontend/src, backend de outro projeto.
