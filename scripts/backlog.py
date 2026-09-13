#!/usr/bin/env python3
"""Backlog do Insulano: o estado persistente do loop autónomo.

Uso:
  python3 scripts/backlog.py list        tabela de tarefas e a próxima executável
  python3 scripts/backlog.py next        imprime a próxima tarefa (exit 3 se não houver)
  python3 scripts/backlog.py check       valida o backlog (exit 1 se inválido)
  python3 scripts/backlog.py show T-105  imprime o ficheiro da tarefa

Formato e regras: backlog/README.md.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKLOG = ROOT / "backlog"

STATES = {"pronto", "em-curso", "feito", "bloqueado", "humano"}
TYPES = {"codigo", "visual", "docs", "infra"}
REQUIRED = ("id", "titulo", "fase", "estado", "tipo", "depende_de")
REPORT_PLACEHOLDER = "(preenchido pelo executor"


def parse_task(text: str) -> dict:
    """Lê o frontmatter (subconjunto simples de YAML) e as secções ## de uma tarefa."""
    match = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if not match:
        raise ValueError("frontmatter --- em falta")
    task: dict = {}
    for raw in match.group(1).splitlines():
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        key, _, value = raw.partition(":")
        value = re.sub(r"\s+#.*$", "", value).strip()
        if value.startswith("[") and value.endswith("]"):
            task[key.strip()] = [v.strip() for v in value[1:-1].split(",") if v.strip()]
        elif re.fullmatch(r"-?\d+", value):
            task[key.strip()] = int(value)
        else:
            task[key.strip()] = value.strip("\"'")
    sections: dict[str, str] = {}
    current = None
    for line in match.group(2).splitlines():
        heading = re.match(r"^##\s+(.+?)\s*$", line)
        if heading:
            current = heading.group(1)
            sections[current] = ""
        elif current is not None:
            sections[current] += line + "\n"
    task["sections"] = {k: v.strip() for k, v in sections.items()}
    return task


def _report_filled(task: dict) -> bool:
    report = task["sections"].get("Relatório", "")
    return bool(report) and not report.startswith(REPORT_PLACEHOLDER)


def validate(tasks: dict[str, dict], filenames: dict[str, str]) -> list[str]:
    """Devolve a lista de erros do backlog (vazia quando é válido)."""
    errors = []
    for tid, task in sorted(tasks.items()):
        for key in REQUIRED:
            if key not in task:
                errors.append(f"{tid}: campo obrigatório '{key}' em falta")
        if not filenames.get(tid, "").startswith(f"{tid}-"):
            errors.append(f"{tid}: o nome do ficheiro '{filenames.get(tid)}' tem de começar por '{tid}-'")
        if task.get("estado") not in STATES:
            errors.append(f"{tid}: estado inválido '{task.get('estado')}' (válidos: {', '.join(sorted(STATES))})")
        if task.get("tipo") not in TYPES:
            errors.append(f"{tid}: tipo inválido '{task.get('tipo')}' (válidos: {', '.join(sorted(TYPES))})")
        if "Critérios de aceitação" not in task["sections"]:
            errors.append(f"{tid}: secção 'Critérios de aceitação' em falta")
        for dep in task.get("depende_de", []):
            if dep not in tasks:
                errors.append(f"{tid}: depende de {dep}, que não existe")
            elif task.get("estado") == "feito" and tasks[dep].get("estado") != "feito":
                errors.append(f"{tid}: está feito mas a dependência {dep} não está")
        if task.get("estado") in {"feito", "bloqueado"} and not _report_filled(task):
            errors.append(f"{tid}: estado {task.get('estado')} exige a secção Relatório preenchida")
    in_progress = sorted(t for t, v in tasks.items() if v.get("estado") == "em-curso")
    if len(in_progress) > 1:
        errors.append(f"mais de uma tarefa em-curso: {', '.join(in_progress)}")
    errors.extend(_find_cycles(tasks))
    return errors


def _find_cycles(tasks: dict[str, dict]) -> list[str]:
    errors, state = [], {}

    def visit(tid: str, path: list[str]) -> None:
        if state.get(tid) == "done" or tid not in tasks:
            return
        if state.get(tid) == "visiting":
            cycle = path[path.index(tid):] + [tid]
            errors.append("ciclo de dependências: " + " -> ".join(cycle))
            return
        state[tid] = "visiting"
        for dep in tasks[tid].get("depende_de", []):
            visit(dep, path + [tid])
        state[tid] = "done"

    for tid in sorted(tasks):
        visit(tid, [])
    return errors


def next_task(tasks: dict[str, dict]) -> dict | None:
    """Tarefa em-curso, senão a pronta de menor (fase, id) com dependências todas feitas."""
    for task in tasks.values():
        if task.get("estado") == "em-curso":
            return task
    ready = [
        t for t in tasks.values()
        if t.get("estado") == "pronto"
        and all(tasks.get(d, {}).get("estado") == "feito" for d in t.get("depende_de", []))
    ]
    return min(ready, key=lambda t: (t.get("fase", 99), t["id"]), default=None)


def load_all(directory: Path = BACKLOG) -> tuple[dict[str, dict], dict[str, str], list[str]]:
    """Carrega todas as tarefas T-*.md; devolve tarefas, nomes de ficheiro e erros de parsing."""
    tasks, filenames, errors = {}, {}, []
    for path in sorted(directory.rglob("T-*.md")):
        try:
            task = parse_task(path.read_text(encoding="utf-8"))
        except ValueError as err:
            errors.append(f"{path.name}: {err}")
            continue
        task["path"] = path.relative_to(ROOT).as_posix()
        if task.get("id") in tasks:
            errors.append(f"{task['id']}: id duplicado ({path.name})")
        tasks[task.get("id", path.stem)] = task
        filenames[task.get("id", path.stem)] = path.name
    return tasks, filenames, errors


def main(argv: list[str]) -> int:
    """Ponto de entrada da linha de comandos."""
    command = argv[0] if argv else "list"
    tasks, filenames, parse_errors = load_all()
    if command == "check":
        errors = parse_errors + validate(tasks, filenames)
        for err in errors:
            print("FALHA  [backlog] " + err)
        print(f"backlog: {'FALHOU' if errors else 'PASSOU'} ({len(tasks)} tarefas, {len(errors)} erros)")
        return 1 if errors else 0
    if command == "next":
        task = next_task(tasks)
        if task is None:
            waiting = sorted(t for t, v in tasks.items() if v.get("estado") in {"humano", "bloqueado"})
            print("nenhuma tarefa executável; à espera do Rodolfo: " + (", ".join(waiting) or "nada"))
            return 3
        print(f"{task['id']}\t{task['path']}\t{task['titulo']}")
        return 0
    if command == "show" and len(argv) > 1:
        task = tasks.get(argv[1])
        if task is None:
            print(f"tarefa {argv[1]} não existe")
            return 1
        print((ROOT / task["path"]).read_text(encoding="utf-8"))
        return 0
    if command == "list":
        for task in sorted(tasks.values(), key=lambda t: (t.get("fase", 99), t["id"])):
            deps = ",".join(task.get("depende_de", [])) or "-"
            print(f"{task['id']}  F{task.get('fase')}  {task.get('estado', '?'):<10} {task.get('tipo', '?'):<7} deps={deps:<24} {task.get('titulo')}")
        nxt = next_task(tasks)
        print(f"\npróxima: {nxt['id'] if nxt else 'nenhuma'}")
        return 0
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
