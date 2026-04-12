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

PROMPT_FILE="${1:?usage: run_agent.sh <prompt_file> <output_file> [timeout_minutes]}"
OUTPUT_FILE="${2:?usage: run_agent.sh <prompt_file> <output_file> [timeout_minutes]}"
TIMEOUT_MIN="${3:-25}"  # default 25 minutos

if [ ! -f "$PROMPT_FILE" ]; then
  echo "ERRO: prompt file '$PROMPT_FILE' nao existe" >&2
  exit 1
fi

# timeout previne agentes que ficam stuck indefinidamente (incidente HD Re-Round 2026-04-12)
# Se o agente nao terminar em TIMEOUT_MIN minutos, eh morto com SIGTERM
timeout --signal=SIGTERM "${TIMEOUT_MIN}m" claude --dangerously-skip-permissions -p - < "$PROMPT_FILE" > "$OUTPUT_FILE" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 124 ]; then
  echo "" >> "$OUTPUT_FILE"
  echo "=== TIMEOUT: agente morto apos ${TIMEOUT_MIN} minutos sem concluir ===" >> "$OUTPUT_FILE"
fi

exit $EXIT_CODE
