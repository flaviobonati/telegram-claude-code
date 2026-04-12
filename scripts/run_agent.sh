#!/bin/bash
# scripts/run_agent.sh — helper que spawna um sub-agente Claude Code em background
#
# Uso:
#   ./scripts/run_agent.sh <prompt_file> <output_file>
#
# Lê o prompt do arquivo via stdin (evita escape hell de aspas em argv),
# pipe pra `claude -p -` em dangerously-skip-permissions mode, e redireciona
# stdout+stderr pro output_file. Deve ser invocado em background pelo
# Coordenador via `run_in_background: true` na tool Bash.
#
# Padrão de invocação pelo Coordenador:
#   cat coordenador/sub-agents/dev/dev.md /tmp/task_dev.md > /tmp/prompt_dev_full.md
#   /opt/mitra-factory/scripts/run_agent.sh /tmp/prompt_dev_full.md /tmp/out_dev.txt

set -euo pipefail

PROMPT_FILE="${1:?usage: run_agent.sh <prompt_file> <output_file>}"
OUTPUT_FILE="${2:?usage: run_agent.sh <prompt_file> <output_file>}"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "ERRO: prompt file '$PROMPT_FILE' nao existe" >&2
  exit 1
fi

claude --dangerously-skip-permissions -p - < "$PROMPT_FILE" > "$OUTPUT_FILE" 2>&1
