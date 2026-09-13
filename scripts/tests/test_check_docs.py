"""Testes do scripts/check_docs.py: detecção de deriva entre docs e código."""

import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))

import check_docs # noqa: E402


def test_forbidden_dashes_reports_line_numbers():
    text = "linha boa\nlinha com — travessão\noutra – meia-risca\n"
    assert check_docs.find_forbidden_dashes(text) == [2, 3]


def test_broken_links_ignores_external_and_anchors(tmp_path):
    (tmp_path / "existe.md").write_text("ok", encoding="utf-8")
    md = tmp_path / "doc.md"
    text = "[a](existe.md) [b](falta.md) [c](https://x.pt) [d](#seccao) [e](existe.md#topo)"
    assert check_docs.find_broken_links(md, text) == ["falta.md"]


def test_doc_comments_ok_when_header_and_public_funcs_documented():
    source = (
        "extends Node\n## Faz uma coisa.\n\n## Devolve dois.\nfunc two() -> int:\n\treturn 2\n\n"
        "func _private() -> void:\n\tpass\n"
    )
    assert check_docs.missing_doc_comments(source, is_test=False) == []


def test_doc_comments_flags_missing_header_and_public_func():
    source = "extends Node\n\nfunc two() -> int:\n\treturn 2\n"
    assert check_docs.missing_doc_comments(source, is_test=False) == ["cabeçalho ##", "func two"]


def test_doc_comments_allow_annotations_between_doc_and_func():
    source = "extends Node\n## Classe.\n\n## Doc.\n@rpc\nfunc ping() -> void:\n\tpass\n"
    assert check_docs.missing_doc_comments(source, is_test=False) == []


def test_doc_comments_skip_test_functions_in_test_files():
    source = "extends GutTest\n## Testes.\n\nfunc test_x() -> void:\n\tpass\n\nfunc before_each() -> void:\n\tpass\n"
    assert check_docs.missing_doc_comments(source, is_test=True) == []


def test_component_rows_read_class_name_extends_and_summary(tmp_path):
    game = tmp_path / "game"
    (game / "llm").mkdir(parents=True)
    (game / "addons/x").mkdir(parents=True)
    (game / "llm/bridge.gd").write_text(
        "extends Node\nclass_name LLMBridge\n## Ponte para o Ollama.\n## Segunda linha.\n", encoding="utf-8"
    )
    (game / "addons/x/ignored.gd").write_text("extends Node\n", encoding="utf-8")
    rows = check_docs.component_rows(game, baseline=set())
    assert rows == [("llm/bridge.gd", "LLMBridge", "Node", "Ponte para o Ollama.")]


def test_component_rows_ignore_function_docstrings_as_summary(tmp_path):
    game = tmp_path / "game"
    game.mkdir()
    (game / "need.gd").write_text(
        "extends Resource\nclass_name Need\n\n@export var name: String\n\n## Decreases the value.\nfunc decrease() -> void:\n\tpass\n",
        encoding="utf-8",
    )
    rows = check_docs.component_rows(game, baseline={"need.gd"})
    assert rows == [("need.gd", "Need", "Resource", "(herdado da base, sem doc: ver T-002)")]


def test_replace_between_markers_swaps_only_the_block():
    text = "antes\n<!-- gerado:x:inicio -->\nvelho\n<!-- gerado:x:fim -->\ndepois\n"
    out = check_docs.replace_between_markers(text, "x", "novo")
    assert out == "antes\n<!-- gerado:x:inicio -->\nnovo\n<!-- gerado:x:fim -->\ndepois\n"


def test_replace_between_markers_requires_markers():
    with pytest.raises(ValueError):
        check_docs.replace_between_markers("sem marcadores", "x", "novo")


def test_baseline_entries_must_exist_in_upstream_base(tmp_path):
    base = tmp_path / "base"
    (base / "guy").mkdir(parents=True)
    (base / "guy/guy.gd").write_text("", encoding="utf-8")
    problems = check_docs.baseline_violations({"guy/guy.gd", "llm/novo.gd"}, base)
    assert problems == ["llm/novo.gd"]
