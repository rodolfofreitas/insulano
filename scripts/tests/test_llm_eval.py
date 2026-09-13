"""Testes offline do scripts/llm_eval.py (não precisam do Ollama)."""

import json
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))

import llm_eval  # noqa: E402

RULES = llm_eval.load_json(ROOT / "game/data/phrase_rules.json")
CASES = llm_eval.load_json(ROOT / "game/tests/fixtures/phrase_filter_cases.json")["cases"]


@pytest.mark.parametrize("case", CASES, ids=[c["raw"][:30] for c in CASES])
def test_filter_matches_shared_fixture(case):
    cleaned = llm_eval.clean_phrase(case["raw"], RULES)
    assert cleaned == case["clean"]
    assert llm_eval.check_phrase(cleaned, RULES) == case["reason"]


def test_render_prompt_fills_every_placeholder():
    template = (ROOT / "game/data/prompts/phrase_prompt.txt").read_text(encoding="utf-8")
    context = {"hour": 9, "period": "manhã", "action": "pescar", "hunger": "ok", "weather": "sol", "holiday": "nenhuma"}
    prompt = llm_eval.render_prompt(template, context)
    assert "{" not in prompt and "}" not in prompt
    assert "pescar" in prompt


def test_render_prompt_fails_loudly_on_missing_field():
    with pytest.raises(KeyError):
        llm_eval.render_prompt("estás a {action} às {hour}h", {"action": "pescar"})


def test_percentile_nearest_rank():
    assert llm_eval.percentile([1.0, 2.0, 3.0, 4.0], 50) == 2.0
    assert llm_eval.percentile([1.0, 2.0, 3.0, 4.0], 95) == 4.0


def test_summarize_verdict_fails_on_low_pass_rate():
    results = [{"latency_s": 1.0, "reason": None}] * 8 + [{"latency_s": 1.0, "reason": "ptbr"}] * 2
    summary = llm_eval.summarize(results, RULES)
    assert summary["pass_rate"] == 0.8
    assert summary["verdict"] == "FALHOU"


def test_summarize_verdict_fails_on_slow_latency():
    results = [{"latency_s": 9.0, "reason": None}] * 10
    assert llm_eval.summarize(results, RULES)["verdict"] == "FALHOU"


def test_summarize_verdict_passes_when_fast_and_clean():
    results = [{"latency_s": 2.0, "reason": None}] * 10
    assert llm_eval.summarize(results, RULES)["verdict"] == "PASSOU"


def test_eval_cases_file_matches_prompt_placeholders():
    template = (ROOT / "game/data/prompts/phrase_prompt.txt").read_text(encoding="utf-8")
    cases = json.loads((ROOT / "evals/phrase_cases.json").read_text(encoding="utf-8"))["cases"]
    for case in cases:
        llm_eval.render_prompt(template, case["context"])
