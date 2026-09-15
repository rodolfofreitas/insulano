#!/usr/bin/env bash
# Portão único de verificação do Insulano.
# Vocabulário (partilhado com o qa-gate da fábrica): PASSOU, AVISOS, FALHOU, INDETERMINADO.
#
# Uso: scripts/verify.sh [--quick | --full] [--visual] [--llm] [--export]
#   (sem flags)  docs, backlog, pytest, lint, import, testes GUT, smoke de arranque
#   --quick      docs, backlog, pytest, lint            (é o que o pre-commit corre)
#   --visual     + screenshot real em reports/verify-latest.png (abre uma janela ~5 s)
#   --llm        + eval das frases e teste ao vivo (game/tests/live/) contra o Ollama local
#   --export     + export Linux e arranque do binário exportado
#   --full       tudo o que está acima
#
# Saída: 0 se PASSOU ou AVISOS, 1 se FALHOU, 3 se INDETERMINADO (algo não pôde ser
# verificado; nunca é tratado como passou). Resumo gravado em reports/verify-last.txt.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
mkdir -p reports

QUICK=0 VISUAL=0 LLM=0 EXPORT=0
for arg in "$@"; do
  case "$arg" in
    --quick) QUICK=1 ;;
    --visual) VISUAL=1 ;;
    --llm) LLM=1 ;;
    --export) EXPORT=1 ;;
    --full) VISUAL=1 LLM=1 EXPORT=1 ;;
    *) echo "flag desconhecida: $arg"; exit 2 ;;
  esac
done

RESULTS=()
HAS_FAIL=0 HAS_WARN=0 HAS_INDET=0

record() {
  RESULTS+=("$(printf '%-12s %-14s %s' "$1" "$2" "$3")")
  case "$2" in
    FALHOU) HAS_FAIL=1 ;;
    AVISOS) HAS_WARN=1 ;;
    INDETERMINADO) HAS_INDET=1 ;;
  esac
  printf '>> %-12s %-14s %s\n' "$1" "$2" "$3"
}

# Erros de script que os códigos de saída do Godot escondem (o motor sai com 0 mesmo assim).
log_has_script_errors() {
  grep -E -q 'SCRIPT ERROR|Parse Error|GUT ERROR|Failed to load script|Invalid call' "$1"
}

GODOT="$(mise which godot 2>/dev/null || command -v godot || true)"
GDTOOLKIT=(uvx --quiet --from 'gdtoolkit==4.*')

# 1. Documentação contra código
if python3 scripts/check_docs.py > reports/check_docs.log 2>&1; then
  record docs PASSOU "scripts/check_docs.py"
else
  record docs FALHOU "ver reports/check_docs.log"; grep FALHA reports/check_docs.log | head -20
fi

# 2. Backlog
if python3 scripts/backlog.py check > reports/backlog.log 2>&1; then
  record backlog PASSOU "$(tail -1 reports/backlog.log)"
else
  record backlog FALHOU "ver reports/backlog.log"; grep FALHA reports/backlog.log | head -20
fi

# 3. Testes dos scripts do harness
if uvx --quiet --with pillow pytest -q scripts/tests > reports/pytest.log 2>&1; then
  record pytest PASSOU "$(tail -1 reports/pytest.log)"
else
  record pytest FALHOU "ver reports/pytest.log"; tail -15 reports/pytest.log
fi

# 4. Lint e formatação: estrito no código do Insulano, informativo no herdado da base
mapfile -t BASELINE < <(grep -v -E '^\s*(#|$)' scripts/gd_baseline.txt | sed 's|^|game/|')
mapfile -t ALL_GD < <(find game -name '*.gd' -not -path 'game/addons/*' -not -path 'game/.godot/*' | sort)
OWN_GD=()
for f in "${ALL_GD[@]}"; do
  [[ " ${BASELINE[*]} " == *" $f "* ]] || OWN_GD+=("$f")
done
if "${GDTOOLKIT[@]}" gdlint "${OWN_GD[@]}" > reports/gdlint.log 2>&1 \
   && "${GDTOOLKIT[@]}" gdformat --check "${OWN_GD[@]}" >> reports/gdlint.log 2>&1; then
  inherited=0
  if [ "${#BASELINE[@]}" -gt 0 ]; then
    inherited=$("${GDTOOLKIT[@]}" gdlint "${BASELINE[@]}" 2>&1 | grep -c 'Error:' || true)
  fi
  if [ "${inherited:-0}" -gt 0 ]; then
    record lint AVISOS "${#OWN_GD[@]} ficheiros próprios limpos; $inherited problemas herdados na baseline (T-002)"
  else
    record lint PASSOU "${#OWN_GD[@]} ficheiros próprios limpos"
  fi
else
  record lint FALHOU "ver reports/gdlint.log (corrigir com: uvx --from 'gdtoolkit==4.*' gdformat <ficheiro>)"
  grep -E 'Error|would reformat' reports/gdlint.log | head -20
fi

if [ "$QUICK" -eq 0 ]; then
  if [ -z "$GODOT" ]; then
    record godot FALHOU "Godot não encontrado: correr 'mise install' na raiz do repositório"
  else
    # 5. Import (gera .godot/ e a cache de classes; rápido quando já existe)
    timeout 300 "$GODOT" --headless --path game --import > reports/import.log 2>&1
    if log_has_script_errors reports/import.log; then
      record import FALHOU "erros de script no import, ver reports/import.log"
    else
      record import PASSOU "godot --import"
    fi

    # 6. Testes GUT (unit + integration)
    timeout 300 "$GODOT" --headless --path game -s res://addons/gut/gut_cmdln.gd \
      -gconfig=res://.gutconfig.json -gjunit_xml_file="$ROOT/reports/gut-junit.xml" > reports/gut.log 2>&1
    gut_exit=$?
    gut_totals="$(grep -E '^(Tests|Passing Tests|Failing Tests|Errors)' reports/gut.log | tr -s ' ' | paste -sd ';' -)"
    if [ "$gut_exit" -eq 0 ] && ! log_has_script_errors reports/gut.log; then
      record gut PASSOU "$gut_totals"
    else
      record gut FALHOU "exit=$gut_exit; $gut_totals; ver reports/gut.log"
      grep -E 'Failed|GUT ERROR|SCRIPT ERROR' reports/gut.log | head -20
    fi

    # 7. Smoke de arranque (90 s de jogo simulados). INSULANO_LLM_URL para uma
    # porta morta (T-106): força o SayGeneratedAction a cair sempre no
    # fallback, sem depender de nenhum Ollama real a responder (nem sequer
    # a existir) para esta prova ser determinística.
    # INSULANO_FAKE_TIME=10:00 (T-203): garante hora diurna para que o personagem
    # nao durma durante o smoke de arranque (IsNightCondition devolve FAILURE).
    INSULANO_LLM_URL="http://127.0.0.1:9" \
    INSULANO_FAKE_TIME="2026-01-15T10:00" \
      timeout 300 "$GODOT" --headless --fixed-fps 60 --path game -s res://tools/boot_smoke.gd > reports/boot.log 2>&1
    boot_exit=$?
    if [ "$boot_exit" -eq 0 ] && ! log_has_script_errors reports/boot.log; then
      record boot PASSOU "$(grep BOOT_SMOKE reports/boot.log)"
    else
      record boot FALHOU "exit=$boot_exit; $(grep BOOT_SMOKE reports/boot.log); ver reports/boot.log"
    fi

    # 8. Prova visual
    if [ "$VISUAL" -eq 1 ]; then
      rm -f reports/verify-latest.png
      timeout 120 "$GODOT" --rendering-driver opengl3 --fixed-fps 60 --path game \
        -s res://tools/capture.gd -- --out="$ROOT/reports/verify-latest.png" --frames=300 > reports/capture.log 2>&1
      if [ -s reports/verify-latest.png ] && ! log_has_script_errors reports/capture.log; then
        record visual PASSOU "reports/verify-latest.png (inspeccionar a imagem antes de declarar feito)"
      elif [ -z "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ]; then
        record visual INDETERMINADO "sem sessão gráfica; screenshot impossível"
      else
        record visual FALHOU "captura falhou, ver reports/capture.log"
      fi
    fi
  fi
fi

# 9. Eval do LLM e teste ao vivo do LLMBridge (game/tests/live/, fora do .gutconfig.json)
if [ "$LLM" -eq 1 ]; then
  python3 scripts/llm_eval.py > reports/llm_eval.log 2>&1
  case $? in
    0) record llm PASSOU "$(tail -2 reports/llm_eval.log | head -1)" ;;
    3) record llm INDETERMINADO "$(grep INDETERMINADO reports/llm_eval.log)" ;;
    *) record llm FALHOU "$(tail -2 reports/llm_eval.log | head -1)" ;;
  esac

  if [ -z "$GODOT" ]; then
    record llm_live FALHOU "Godot não encontrado: correr 'mise install' na raiz do repositório"
  else
    # -gconfig= (vazio) ignora o .gutconfig.json de propósito: tests/live/ não
    # está nos seus "dirs" e o teste ao vivo nunca deve correr por defeito.
    timeout 300 "$GODOT" --headless --path game -s res://addons/gut/gut_cmdln.gd \
      -gconfig= -gdir=res://tests/live -ginclude_subdirs -gprefix=test_ -gsuffix=.gd \
      -gexit -gexit_on_success -gignore_pause -ghide_orphans \
      -gjunit_xml_file="$ROOT/reports/gut-live-junit.xml" > reports/gut-live.log 2>&1
    live_exit=$?
    live_totals="$(grep -E '^(Tests|Passing Tests|Failing Tests|Errors|Risky/Pending)' reports/gut-live.log | tr -s ' ' | paste -sd ';' -)"
    # O GUT sai com 0 quando o único teste se marca pending() (Ollama parado):
    # "Risky/Pending" > 0 nos totais significa que o teste nunca chegou a correr
    # contra o Ollama a sério, por isso não conta como PASSOU (nunca se trata
    # pending como passou; cabeçalho do script, linhas 13-14).
    live_pending="$(printf '%s' "$live_totals" | grep -oE 'Risky/Pending [0-9]+' | grep -oE '[0-9]+$')"
    if [ "$live_exit" -eq 0 ] && ! log_has_script_errors reports/gut-live.log; then
      if [ "${live_pending:-0}" -gt 0 ]; then
        record llm_live INDETERMINADO "teste ao vivo saltado (Ollama não respondeu); $live_totals"
      else
        record llm_live PASSOU "$live_totals"
      fi
    else
      record llm_live FALHOU "exit=$live_exit; $live_totals; ver reports/gut-live.log"
      grep -E 'Failed|GUT ERROR|SCRIPT ERROR' reports/gut-live.log | head -20
    fi
  fi
fi

# 10. Export Linux
if [ "$EXPORT" -eq 1 ]; then
  scripts/export.sh > reports/export-verify.log 2>&1
  case $? in
    0) record export PASSOU "$(tail -1 reports/export-verify.log)" ;;
    3) record export INDETERMINADO "$(grep INDETERMINADO reports/export-verify.log)" ;;
    *) record export FALHOU "ver reports/export-verify.log" ;;
  esac
fi

if [ "$HAS_FAIL" -eq 1 ]; then VERDICT=FALHOU CODE=1
elif [ "$HAS_INDET" -eq 1 ]; then VERDICT=INDETERMINADO CODE=3
elif [ "$HAS_WARN" -eq 1 ]; then VERDICT=AVISOS CODE=0
else VERDICT=PASSOU CODE=0
fi

{
  echo "verify.sh $* | $(date -Iseconds) | commit $(git rev-parse --short HEAD 2>/dev/null)"
  printf '%s\n' "${RESULTS[@]}"
  echo "VEREDICTO: $VERDICT"
} | tee reports/verify-last.txt | tail -n +2 | sed '1i\\n==== resumo ===='
exit "$CODE"
