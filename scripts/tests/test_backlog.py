"""Testes do scripts/backlog.py: parsing, validação e selecção da próxima tarefa."""

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))

import backlog  # noqa: E402


def make(id_, estado="pronto", fase=1, deps=None, relatorio="(preenchido pelo executor)"):
    deps_txt = ", ".join(deps or [])
    return (
        f"---\nid: {id_}\ntitulo: tarefa {id_}\nfase: {fase}\nestado: {estado}\n"
        f"tipo: codigo\ndepende_de: [{deps_txt}]\n---\n\n## Objectivo\nx\n\n"
        f"## Critérios de aceitação\n- [ ] y\n\n## Relatório\n{relatorio}\n"
    )


def load(*texts):
    tasks = {}
    for text in texts:
        task = backlog.parse_task(text)
        tasks[task["id"]] = task
    return tasks


def test_parse_task_reads_frontmatter_lists_and_sections():
    task = backlog.parse_task(make("T-101", deps=["T-001", "T-002"]))
    assert task["fase"] == 1
    assert task["depende_de"] == ["T-001", "T-002"]
    assert "Objectivo" in task["sections"]


def test_parse_task_empty_dependency_list():
    assert backlog.parse_task(make("T-001"))["depende_de"] == []


def test_next_task_respects_dependencies_and_order():
    tasks = load(make("T-001", estado="feito", fase=0, relatorio="feito, testes verdes"),
                 make("T-102", deps=["T-101"]), make("T-101", deps=["T-001"]))
    assert backlog.next_task(tasks)["id"] == "T-101"


def test_next_task_skips_humano_and_blocked():
    tasks = load(make("T-001", estado="humano", fase=0), make("T-002", estado="bloqueado", fase=0, relatorio="3 tentativas"))
    assert backlog.next_task(tasks) is None


def test_next_task_resumes_in_progress_first():
    tasks = load(make("T-101"), make("T-205", estado="em-curso", fase=2))
    assert backlog.next_task(tasks)["id"] == "T-205"


def test_validate_flags_unknown_dependency_and_state():
    tasks = load(make("T-101", estado="talvez", deps=["T-999"]))
    errors = " | ".join(backlog.validate(tasks, {"T-101": "T-101-x.md"}))
    assert "T-999" in errors and "talvez" in errors


def test_validate_requires_report_when_done():
    tasks = load(make("T-101", estado="feito"))
    errors = backlog.validate(tasks, {"T-101": "T-101-x.md"})
    assert any("Relatório" in e for e in errors)


def test_validate_detects_cycles():
    tasks = load(make("T-101", deps=["T-102"]), make("T-102", deps=["T-101"]))
    errors = backlog.validate(tasks, {"T-101": "T-101-a.md", "T-102": "T-102-b.md"})
    assert any("ciclo" in e for e in errors)


def test_validate_filename_must_match_id():
    tasks = load(make("T-101"))
    assert any("nome" in e for e in backlog.validate(tasks, {"T-101": "T-102-errado.md"}))


def test_validate_only_one_in_progress():
    tasks = load(make("T-101", estado="em-curso"), make("T-102", estado="em-curso"))
    errors = backlog.validate(tasks, {"T-101": "T-101-a.md", "T-102": "T-102-b.md"})
    assert any("em-curso" in e for e in errors)
