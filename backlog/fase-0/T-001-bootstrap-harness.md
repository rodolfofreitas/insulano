---
id: T-001
titulo: Bootstrap do projecto game/ e do harness de verificação
fase: 0
estado: feito
tipo: infra
depende_de: []
---

## Objectivo
Existir um projecto Godot jogável em `game/` com um portão de verificação que um agente corre
sozinho e que prova arranque, testes, lint, documentação e imagem real.

## Ler antes
- `AGENTS.md`, `docs/decisions.md` (ADR-004 a ADR-010)

## Critérios de aceitação
- [x] `game/project.godot` abre no Godot 4.7.2 (`godot --headless --path game --import` sem SCRIPT ERROR)
- [x] GUT 9.7.1 em `game/addons/gut`, testes unit e integration a passar em headless
- [x] `game/tools/boot_smoke.gd` passa: fome desce e personagem mexe-se em 30 s simulados
- [x] `game/tools/capture.gd` grava PNG 1280x720 com a ilha e o personagem
- [x] `scripts/verify.sh`, `check_docs.py`, `backlog.py`, `llm_eval.py`, `export.sh` com testes pytest
- [x] Eval do LLM corrido contra o modelo instalado, resultado em `docs/proof/`

## Fora de âmbito
- Corrigir lint ou bugs do código herdado (T-002, T-003)
- Export templates (T-004)

## Prova exigida
- `docs/proof/T-001-arranque.png`, `docs/proof/llm-eval-llama3.1_8b-2026-09-13.json`, saída do `verify.sh`

## Relatório
Executado a 2026-09-13 (sessão Claude Code do Rodolfo).

- Godot 4.7.2 instalado via mise, fixado em `mise.toml`.
- Base copiada para `game/` sem `.git` nem screenshots; licença e README upstream preservados com sufixo
  `-guy-on-island`. Nome do projecto `Insulano`, renderer `gl_compatibility`, export para `../dist/`.
- `data/` movido para `game/data/`; `holidays.yaml` convertido para `holidays.json` com datas móveis por Páscoa.
- GUT 9.7.1: 9 testes unitários de caracterização (`Need`, `Direction`) e 2 de integração da cena principal.
- `boot_smoke.gd`: primeira versão media a fome final e falhou de forma intermitente (o personagem come);
  corrigido para medir a fome mínima com seed fixa.
- `capture.gd`: primeira versão usava a janela e saiu 1280x1413 porque o Hyprland ignora `--resolution`;
  corrigido para SubViewport fixo, confirmado 1280x720.
- Eval `llama3.1:8b` (CPU): 24 amostras, 95,8% aceites, p50 2,82 s, p95 4,42 s, veredicto PASSOU.
  Problemas de qualidade vistos e passados à T-108: próclise brasileira ("pode me ajudar") e frases sem sentido.
- `gdlint` na base: 79 problemas herdados, 21 ficheiros; ficaram em `scripts/gd_baseline.txt` (T-002).
- Achados fora do repositório, reportados ao Rodolfo: Ollama em CPU e publicado em `0.0.0.0:11434`
  (contradiz T-03 do threat model, ver `docs/threat_model-propostas.md`).
