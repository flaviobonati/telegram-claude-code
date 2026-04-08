---
name: Workers NÃO na primeira leva do Dev
description: Digital Workers são construídos DEPOIS do sistema core funcionar, usando construtor nativo do Mitra. Dev NÃO implementa workers.
type: feedback
---

Workers NÃO entram na primeira leva do Dev. O Mitra tem construtor nativo de workers.

**Why:** Dev tentava implementar workers no one-shot e entrava em loop infinito tentando montar automações. Workers são pós-MVP.

**How to apply:** researcher.md documenta workers mas NÃO inclui nas histórias. developer.md/standard_briefing tem regra explícita. Features com TEM_WORKER ficam documentadas mas não implementadas.
