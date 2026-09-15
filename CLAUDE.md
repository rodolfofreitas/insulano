# Insulano: contexto para Claude Code

Protector de ecrã em Godot 4 com um náufrago autónomo numa ilha tropical, frases por
LLM local (Ollama) e fallback fixo. Inspirado no Johnny Castaway (Sierra, 1992), com
código e assets legalmente limpos. Projecto interno Kaeto.

## Antes de qualquer coisa

**Lê [`AGENTS.md`](AGENTS.md).** É o plano mestre: loop autónomo, Definition of Done,
fronteiras de autonomia, mapa do repositório, regras invariantes e armadilhas desta
máquina. Este ficheiro só acrescenta o que é específico do Claude Code.

## Comandos que importam

```bash
python3 scripts/backlog.py next      # próxima tarefa executável
scripts/verify.sh                    # portão único (--quick, --visual, --llm, --export, --full)
python3 scripts/check_docs.py --fix  # regenera o mapa de componentes da arquitectura
python3 scripts/llm_eval.py          # eval das frases contra o Ollama
```

## Skills e agentes deste projecto

- `/insulano-loop` para trabalhar autonomamente pelo backlog; `/insulano-task` para uma tarefa.
- `/insulano-verify` antes de afirmar que algo funciona.
- `/insulano-docs-sync` quando mexeres em contratos, ficheiros `.gd` ou comandos documentados.
- `/insulano-new-task` para acrescentar trabalho ao backlog; `/insulano-asset` para qualquer asset.
- Subagentes: `insulano-builder` (implementa), `insulano-reviewer` (revê adversarialmente),
  `insulano-verifier` (confirma o veredicto), `insulano-docs-keeper`, `insulano-llm-tuner`.
- Genéricos úteis do arsenal: `game-dev` (Godot), `prompt-engineer`, `ai-evals-engineer`.

## Regras que valem sempre aqui

- Estado real antes de afirmar: correr o comando, ler o log, abrir a imagem.
- Português de Portugal na UI, nos docs e no chat; código e identificadores em inglês.
- Sem travessões nem meias-riscas em ficheiro nenhum (o `check_docs.py` falha).
- Dentro do código de produto (`game/`), documentação `##` suficiente para um humano corrigir
  o código daqui a um ano sem ajuda (revogação de âmbito limitado da fábrica, 2026-07-27).
- Commits `tipo(T-NNN): descrição` em inglês ou português, um por tarefa, com o pre-commit activo
  (`git config core.hooksPath .githooks`).

## Direccao Visual (ADR-013)

Estilo: mix **Graveyard Keeper + Stardew Valley**. Pixel art indie original.
Nao imitar o Johnny Castaway de 1992 -- criar algo com alma propria.

| Referencia | O que trazer |
|---|---|
| Stardew Valley | charme, expressividade, paleta saturada harmoniosa, 'feito com amor' |
| Graveyard Keeper | personalidade indie, atmosfera, animacoes fluidas |
| Johnny Castaway | referencia de COMPORTAMENTO (variedade, eventos) -- NAO visual |

Sprites: ~32x48px. Paleta quente/tropical. Cada frame conta.
Ver docs/decisions.md (ADR-013) e docs/gauntlet/bars.md.

## Legal

Código base MIT (Doubi, `game/LICENSE-guy-on-island.md`), tileset Tiny Islands CC0, sprites
Character Base CC-BY (crédito obrigatório no jogo), Beehave e GUT MIT. Registo completo em
[`docs/assets-licencas.md`](docs/assets-licencas.md).
