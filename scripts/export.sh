#!/usr/bin/env bash
# Export Linux e Windows headless do Insulano e arranque do binário Linux exportado.
# Saída: 0 PASSOU, 1 FALHOU, 3 INDETERMINADO (export templates em falta).
# Instalação dos templates: docs/runbook.md, secção "Export templates".
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
mkdir -p reports dist/linux

GODOT="$(mise which godot 2>/dev/null || command -v godot || true)"
if [ -z "$GODOT" ]; then
  echo "FALHOU: Godot não encontrado (correr 'mise install')"
  exit 1
fi

# "4.7.2.stable.official.ed1daf0bf" -> "4.7.2.stable", o nome da pasta dos templates.
VERSION="$("$GODOT" --version | sed -E 's/\.(official|custom_build|mono).*$//')"
TEMPLATES="$HOME/.local/share/godot/export_templates/$VERSION"
if [ ! -f "$TEMPLATES/linux_release.x86_64" ]; then
  echo "INDETERMINADO: faltam export templates em $TEMPLATES"
  exit 3
fi

"$GODOT" --headless --path game --export-release "Linux" "$ROOT/dist/linux/insulano.x86_64" > reports/export.log 2>&1
if [ ! -x dist/linux/insulano.x86_64 ]; then
  echo "FALHOU: export não produziu dist/linux/insulano.x86_64 (ver reports/export.log)"
  exit 1
fi

timeout 60 dist/linux/insulano.x86_64 --headless --quit-after 600 > reports/export-run.log 2>&1
if grep -E -q 'SCRIPT ERROR|Parse Error|Failed to load script' reports/export-run.log; then
  echo "FALHOU: o binário exportado tem erros de script (ver reports/export-run.log)"
  exit 1
fi
echo "PASSOU: dist/linux/insulano.x86_64 exportado e arrancou 600 frames sem erros de script"

# --- Export Windows ---
mkdir -p dist/windows

# Verificar template Windows
if [ ! -f "$TEMPLATES/windows_release_x86_64.exe" ]; then
  echo "INDETERMINADO: faltam export templates Windows em $TEMPLATES"
  exit 3
fi

echo ">> export Windows"
"$GODOT" --headless --path game --export-release 'Windows Desktop' "$ROOT/dist/windows/insulano.exe" > reports/export-windows.log 2>&1
if [ $? -ne 0 ]; then
  echo "FALHOU: export Windows (ver reports/export-windows.log)"
  exit 1
fi

# Verificar que o ficheiro existe
if [ ! -f dist/windows/insulano.exe ]; then
  echo "FALHOU: insulano.exe nao encontrado"
  exit 1
fi
echo "PASSOU: dist/windows/insulano.exe"
