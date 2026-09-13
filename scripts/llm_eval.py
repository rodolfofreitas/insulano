#!/usr/bin/env python3
"""Eval das frases geradas pelo Ollama para o Insulano.

Mede o que é mensurável numa frase de náufrago: se chega a tempo, se está em
português de Portugal, se respeita o comprimento e se não tem conteúdo proibido.
A qualidade literária não se mede aqui (é juízo humano, ver agent_docs/testing.md).

Fontes únicas (as mesmas que o jogo usa, para o eval nunca divergir do jogo):
  game/data/prompts/phrase_prompt.txt   template do prompt
  game/data/phrase_rules.json           regras de filtro e limiares do eval
  evals/phrase_cases.json               contextos a testar

Uso:
  python3 scripts/llm_eval.py [--model NOME] [--url URL] [--samples N] [--proof]

Saída: PASSOU (exit 0), FALHOU (exit 1), INDETERMINADO (exit 3, Ollama ou modelo
indisponível; nunca conta como passou).
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RULES_PATH = ROOT / "game/data/phrase_rules.json"
PROMPT_PATH = ROOT / "game/data/prompts/phrase_prompt.txt"
CASES_PATH = ROOT / "evals/phrase_cases.json"
DEFAULT_MODEL = "llama3.1:8b"
DEFAULT_URL = "http://127.0.0.1:11434"


def load_json(path: Path) -> dict:
    """Lê um ficheiro JSON em UTF-8."""
    return json.loads(Path(path).read_text(encoding="utf-8"))


def clean_phrase(raw: str, rules: dict) -> str:
    """Normaliza a resposta crua: primeira linha, sem espaços nem aspas nas pontas."""
    text = raw.strip()
    if not text:
        return ""
    text = text.splitlines()[0]
    return text.strip(rules["strip_chars"] + " \t").strip()


def check_phrase(text: str, rules: dict) -> str | None:
    """Devolve o motivo de rejeição (empty, english, ptbr, forbidden, too_short, too_long) ou None."""
    if not text:
        return "empty"
    if any(re.search(p, text) for p in rules["english_patterns"]):
        return "english"
    if any(re.search(p, text) for p in rules["ptbr_patterns"]):
        return "ptbr"
    lower = text.lower()
    if any(word in lower for word in rules["forbidden_substrings"]):
        return "forbidden"
    words = len(text.split())
    if words < rules["min_words"]:
        return "too_short"
    if words > rules["max_words"] or len(text) > rules["max_chars"]:
        return "too_long"
    return None


def render_prompt(template: str, context: dict) -> str:
    """Preenche o template; um campo em falta levanta KeyError (falhar alto, nunca prompt meio vazio)."""
    return template.format(**context)


def percentile(values: list[float], p: float) -> float:
    """Percentil pelo método nearest-rank."""
    ordered = sorted(values)
    rank = max(math.ceil(p / 100 * len(ordered)), 1)
    return ordered[rank - 1]


def summarize(results: list[dict], rules: dict) -> dict:
    """Agrega resultados e decide o veredicto contra os limiares de rules['eval']."""
    limits = rules["eval"]
    latencies = [r["latency_s"] for r in results]
    passed = sum(1 for r in results if r["reason"] is None)
    reasons: dict[str, int] = {}
    for r in results:
        if r["reason"]:
            reasons[r["reason"]] = reasons.get(r["reason"], 0) + 1
    summary = {
        "samples": len(results),
        "pass_rate": round(passed / len(results), 4) if results else 0.0,
        "latency_p50_s": round(percentile(latencies, 50), 2) if latencies else None,
        "latency_p95_s": round(percentile(latencies, 95), 2) if latencies else None,
        "rejections": reasons,
    }
    ok = (
        bool(results)
        and summary["pass_rate"] >= limits["pass_rate_min"]
        and summary["latency_p50_s"] <= limits["latency_p50_max_s"]
        and summary["latency_p95_s"] <= limits["latency_p95_max_s"]
    )
    summary["verdict"] = "PASSOU" if ok else "FALHOU"
    return summary


def configured_model() -> str:
    """Modelo definido em game/project.godot (insulano/llm/model) ou o defeito medido."""
    project = (ROOT / "game/project.godot").read_text(encoding="utf-8")
    match = re.search(r'^llm/model="([^"]+)"', project, re.M)
    return match.group(1) if match else DEFAULT_MODEL


def _post(url: str, payload: dict, timeout: float) -> dict:
    request = urllib.request.Request(
        url, data=json.dumps(payload).encode("utf-8"), headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return json.load(response)


def main() -> int:
    """Corre o eval completo contra o Ollama e grava o relatório."""
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--model", default=None)
    parser.add_argument("--url", default=DEFAULT_URL)
    parser.add_argument("--samples", type=int, default=None)
    parser.add_argument("--proof", action="store_true", help="copia o resumo para docs/proof/")
    args = parser.parse_args()

    rules, template = load_json(RULES_PATH), PROMPT_PATH.read_text(encoding="utf-8")
    cases = load_json(CASES_PATH)["cases"]
    model = args.model or configured_model()
    samples = args.samples or rules["eval"]["samples_per_case"]

    try:
        with urllib.request.urlopen(f"{args.url}/api/tags", timeout=3) as response:
            installed = [m["name"] for m in json.load(response)["models"]]
    except (urllib.error.URLError, TimeoutError, OSError) as err:
        print(f"INDETERMINADO: Ollama não responde em {args.url} ({err})")
        return 3
    if model not in installed:
        print(f"INDETERMINADO: modelo {model} não instalado. Instalados: {', '.join(installed)}")
        return 3

    options = {"temperature": 0.8, "top_p": 0.9, "num_predict": 40}
    # Aquecimento fora da contagem: a primeira chamada inclui carregar o modelo em memória.
    _post(f"{args.url}/api/generate", {"model": model, "prompt": "Olá.", "stream": False, "keep_alive": "10m", "options": options}, 120)

    results = []
    for case in cases:
        prompt = render_prompt(template, case["context"])
        for _ in range(samples):
            started = time.monotonic()
            try:
                body = _post(
                    f"{args.url}/api/generate",
                    {"model": model, "prompt": prompt, "stream": False, "keep_alive": "10m", "options": options},
                    rules["timeout_s"],
                )
                latency, raw = time.monotonic() - started, body.get("response", "")
                cleaned = clean_phrase(raw, rules)
                reason = check_phrase(cleaned, rules)
            except (urllib.error.URLError, TimeoutError, OSError):
                latency, raw, cleaned, reason = rules["timeout_s"], "", "", "timeout"
            results.append({"case": case["id"], "latency_s": round(latency, 2), "raw": raw, "clean": cleaned, "reason": reason})
            print(f"{case['id']:<16} {latency:5.2f}s {reason or 'ok':<10} {cleaned}")

    summary = summarize(results, rules)
    report = {"model": model, "date": datetime.now().isoformat(timespec="seconds"), "summary": summary, "results": results}
    reports = ROOT / "reports"
    reports.mkdir(exist_ok=True)
    out = reports / f"llm-eval-{datetime.now():%Y%m%d-%H%M%S}.json"
    out.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    if args.proof:
        proof = ROOT / "docs/proof" / f"llm-eval-{model.replace(':', '_')}-{datetime.now():%Y-%m-%d}.json"
        proof.parent.mkdir(parents=True, exist_ok=True)
        proof.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"model": model, **summary}, ensure_ascii=False))
    print(f"llm_eval: {summary['verdict']} (relatório {out.relative_to(ROOT)})")
    return 0 if summary["verdict"] == "PASSOU" else 1


if __name__ == "__main__":
    sys.exit(main())
