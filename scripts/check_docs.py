#!/usr/bin/env python3
"""Detecção de deriva entre a documentação e o código do Insulano.

Uso:
  python3 scripts/check_docs.py verifica; sai com 1 se houver FALHA
  python3 scripts/check_docs.py --fix regenera os blocos gerados (mapa de componentes)

Verificações (cada uma existe porque a documentação de vibe code mente em silêncio):
  links links relativos em .md apontam para ficheiros que existem
  travessoes nenhum travessão (U+2014) nem meia-risca (U+2013) em docs e código
  json todos os JSON de dados, fixtures e evals são válidos
  baseline scripts/gd_baseline.txt só lista ficheiros herdados da base (não cresce)
  docstrings todo o .gd fora da baseline tem cabeçalho ## e ## em cada func pública
  componentes o mapa de componentes em docs/architecture.md bate com game/
  modelo o modelo Ollama configurado em project.godot aparece nos docs
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT / "game"
BASE = ROOT / "base-guy-on-island"
BASELINE_FILE = ROOT / "scripts" / "gd_baseline.txt"
ARCHITECTURE = ROOT / "docs" / "architecture.md"

SKIP_DIRS = {".git", ".godot", "addons", "base-guy-on-island", "graphify-out", "reports", "dist", "node_modules"}

# Ficheiros onde travessões são tolerados, com a razão (nunca alargar sem motivo escrito).
DASH_EXEMPT = {
    "docs/threat_model.md": "só o Rodolfo altera (AGENTS.md); propostas em docs/threat_model-propostas.md",
    "game/README-guy-on-island.md": "texto upstream preservado",
    "game/LICENSE-guy-on-island.md": "licença upstream preservada",
}

LINK_RE = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
FENCE_RE = re.compile(r"```.*?```", re.S)
FUNC_RE = re.compile(r"^(?:static\s+)?func\s+([A-Za-z_]\w*)\s*\(")
DECL_RE = re.compile(r"^(?:static\s+)?(?:func|var|const|signal|enum|class\s|@export|@onready)")
TEST_FUNC_RE = re.compile(r"^(test_|before_|after_)")


def find_forbidden_dashes(text: str) -> list[int]:
    """Devolve os números de linha (1-based) que contêm travessão ou meia-risca."""
    # chr() e não o carácter literal: assim este ficheiro não se acusa a si próprio
    # e nenhum formatador troca o escape pelo carácter.
    dashes = (chr(0x2014), chr(0x2013))
    return [i for i, line in enumerate(text.splitlines(), 1) if any(d in line for d in dashes)]


def find_broken_links(md_path: Path, text: str) -> list[str]:
    """Devolve os alvos de links relativos que não existem, ignorando blocos de código."""
    broken = []
    for target in LINK_RE.findall(FENCE_RE.sub("", text)):
        if target.startswith(("http://", "https://", "mailto:", "#")):
            continue
        path_part = target.split("#", 1)[0]
        if path_part and not (md_path.parent / path_part).exists():
            broken.append(target)
    return broken


def missing_doc_comments(source: str, is_test: bool) -> list[str]:
    """Lista o que falta documentar num .gd: o cabeçalho ## e as funções públicas sem ##."""
    lines = source.splitlines()
    problems = []
    first_decl = next((i for i, line in enumerate(lines) if DECL_RE.match(line)), len(lines))
    if not any(line.startswith("##") for line in lines[:first_decl]):
        problems.append("cabeçalho ##")
    for i, line in enumerate(lines):
        match = FUNC_RE.match(line)
        if not match:
            continue
        name = match.group(1)
        if name.startswith("_") or (is_test and TEST_FUNC_RE.match(name)):
            continue
        j = i - 1
        while j >= 0 and lines[j].strip().startswith("@"):
            j -= 1
        if j < 0 or not lines[j].lstrip().startswith("##"):
            problems.append(f"func {name}")
    return problems


def component_rows(game_dir: Path, baseline: set[str]) -> list[tuple[str, str, str, str]]:
    """Extrai (ficheiro, class_name, extends, primeira linha ## do cabeçalho) de cada .gd do jogo.

    Só conta o bloco ## antes da primeira declaração: a docstring de uma função não
    descreve a responsabilidade do ficheiro.
    """
    rows = []
    for path in sorted(game_dir.rglob("*.gd")):
        rel = path.relative_to(game_dir).as_posix()
        if set(Path(rel).parts) & SKIP_DIRS or rel.startswith("tests/"):
            continue
        text = path.read_text(encoding="utf-8")
        class_name = re.search(r"^class_name\s+(\w+)", text, re.M)
        extends = re.search(r"^extends\s+(\S+)", text, re.M)
        lines = text.splitlines()
        first_decl = next((i for i, line in enumerate(lines) if DECL_RE.match(line)), len(lines))
        summary = next((l[2:].strip() for l in lines[:first_decl] if l.startswith("##") and l[2:].strip()), "")
        if not summary and rel in baseline:
            summary = "(herdado da base, sem doc: ver T-002)"
        rows.append((rel, class_name.group(1) if class_name else "", extends.group(1) if extends else "", summary))
    return rows


def render_component_table(rows: list[tuple[str, str, str, str]]) -> str:
    """Formata as linhas do mapa de componentes como tabela Markdown."""
    out = ["| Ficheiro (game/) | class_name | extends | Responsabilidade (1.ª linha ##) |", "|---|---|---|---|"]
    out += [f"| `{f}` | {c or '-'} | {e or '-'} | {s or '(sem doc)'} |" for f, c, e, s in rows]
    return "\n".join(out)


def replace_between_markers(text: str, name: str, block: str) -> str:
    """Substitui o conteúdo entre <!-- gerado:NAME:inicio --> e <!-- gerado:NAME:fim -->."""
    start, end = f"<!-- gerado:{name}:inicio -->", f"<!-- gerado:{name}:fim -->"
    a, b = text.find(start), text.find(end)
    if a < 0 or b < 0 or b < a:
        raise ValueError(f"marcadores gerado:{name} em falta")
    return text[: a + len(start)] + "\n" + block + "\n" + text[b:]


def baseline_violations(entries: set[str], base_dir: Path) -> list[str]:
    """Entradas da baseline que não existem na base upstream (código novo não pode entrar)."""
    return sorted(e for e in entries if not (base_dir / e).exists())


def load_baseline() -> set[str]:
    """Lê scripts/gd_baseline.txt, ignorando comentários e linhas vazias."""
    if not BASELINE_FILE.exists():
        return set()
    lines = BASELINE_FILE.read_text(encoding="utf-8").splitlines()
    return {l.strip() for l in lines if l.strip() and not l.startswith("#")}


def iter_files(suffixes: tuple[str, ...]):
    """Percorre o repositório devolvendo ficheiros com as extensões pedidas, fora de SKIP_DIRS."""
    for path in ROOT.rglob("*"):
        rel = path.relative_to(ROOT)
        if path.is_file() and path.suffix in suffixes and not set(rel.parts) & SKIP_DIRS:
            yield path, rel.as_posix()


def run(fix: bool) -> int:
    """Corre todas as verificações, imprime o relatório e devolve o código de saída."""
    failures: list[str] = []
    notes: list[str] = []
    baseline = load_baseline()

    for path, rel in iter_files((".md",)):
        for target in find_broken_links(path, path.read_text(encoding="utf-8")):
            failures.append(f"[links] {rel}: link morto -> {target}")

    for path, rel in iter_files((".md", ".gd", ".json", ".txt", ".py", ".sh")):
        if rel in DASH_EXEMPT or rel.startswith("scripts/tests/"):
            continue
        for line in find_forbidden_dashes(path.read_text(encoding="utf-8")):
            failures.append(f"[travessoes] {rel}:{line}: travessão ou meia-risca (usar vírgula, dois pontos ou hífen)")

    for path, rel in iter_files((".json",)):
        try:
            json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as err:
            failures.append(f"[json] {rel}: inválido ({err})")

    for entry in baseline_violations(baseline, BASE):
        failures.append(f"[baseline] {entry}: não existe na base upstream; código novo não entra na baseline")
    for entry in sorted(baseline):
        if not (GAME / entry).exists():
            failures.append(f"[baseline] {entry}: já não existe em game/; remover da baseline")

    for path in sorted(GAME.rglob("*.gd")):
        rel = path.relative_to(GAME).as_posix()
        if set(Path(rel).parts) & SKIP_DIRS or rel in baseline:
            continue
        for problem in missing_doc_comments(path.read_text(encoding="utf-8"), rel.startswith("tests/")):
            failures.append(f"[docstrings] game/{rel}: falta {problem}")

    table = render_component_table(component_rows(GAME, baseline))
    arch_text = ARCHITECTURE.read_text(encoding="utf-8")
    try:
        new_text = replace_between_markers(arch_text, "componentes", table)
        if new_text != arch_text:
            if fix:
                ARCHITECTURE.write_text(new_text, encoding="utf-8")
                notes.append("[componentes] docs/architecture.md regenerado")
            else:
                failures.append("[componentes] docs/architecture.md desactualizado: correr scripts/check_docs.py --fix")
    except ValueError as err:
        failures.append(f"[componentes] docs/architecture.md: {err}")

    project = (GAME / "project.godot").read_text(encoding="utf-8")
    model = re.search(r'^llm/model="([^"]+)"', project, re.M)
    if model:
        for doc in ("docs/api-ollama.md", "agent_docs/tech_stack.md"):
            if model.group(1) not in (ROOT / doc).read_text(encoding="utf-8"):
                failures.append(f"[modelo] {doc}: não menciona o modelo configurado {model.group(1)}")
    else:
        notes.append("[modelo] project.godot ainda sem insulano/llm/model (entra na T-101)")

    for line in notes:
        print("INFO " + line)
    for line in failures:
        print("FALHA " + line)
    verdict = "FALHOU" if failures else "PASSOU"
    print(f"check_docs: {verdict} ({len(failures)} falhas)")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(run(fix="--fix" in sys.argv[1:]))
