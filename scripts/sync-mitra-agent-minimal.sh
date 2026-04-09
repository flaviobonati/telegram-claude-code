#!/bin/bash
# scripts/sync-mitra-agent-minimal.sh
#
# Puxa a última versão de mpbonatti/mitra-agent-minimal e atualiza a pasta
# `mitra-agent-minimal/` vendorizada no repo. Rode isso de tempos em tempos
# pra manter o template e o system_prompt.md sincronizados com a plataforma.
#
# Requer: variável de ambiente GH_TOKEN com acesso ao repo privado
# mpbonatti/mitra-agent-minimal.
#
# Uso:
#   export GH_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#   ./scripts/sync-mitra-agent-minimal.sh

set -euo pipefail

if [ -z "${GH_TOKEN:-}" ]; then
  echo "ERRO: GH_TOKEN não definido." >&2
  echo "Exporte o token com acesso ao repo privado mpbonatti/mitra-agent-minimal:" >&2
  echo "  export GH_TOKEN=ghp_xxxxxxxx" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_DIR="$REPO_ROOT/mitra-agent-minimal"
TMP_CLONE="$(mktemp -d)"

trap 'rm -rf "$TMP_CLONE"' EXIT

echo "Clonando mpbonatti/mitra-agent-minimal em $TMP_CLONE ..."
git clone --depth 1 "https://${GH_TOKEN}@github.com/mpbonatti/mitra-agent-minimal.git" "$TMP_CLONE" 2>&1 | tail -5

echo "Removendo .git do clone temporário..."
rm -rf "$TMP_CLONE/.git"

echo "Substituindo $VENDOR_DIR ..."
rm -rf "$VENDOR_DIR"
mkdir -p "$VENDOR_DIR"
cp -a "$TMP_CLONE/." "$VENDOR_DIR/"

echo ""
echo "=== Diff resumo ==="
cd "$REPO_ROOT"
git status --short mitra-agent-minimal/ 2>/dev/null || true

echo ""
echo "Pronto. Revise o diff e commit:"
echo "  git add mitra-agent-minimal/"
echo "  git commit -m 'Sync mitra-agent-minimal com a versão oficial'"
