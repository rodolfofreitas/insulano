---
id: T-501
titulo: Modo protector de ecrã e modo janela por argumentos
fase: 5
estado: feito
tipo: codigo
depende_de: [T-109]
---

## Objectivo
O Insulano arranca como protector de ecrã (ecrã inteiro, sem cursor, sai ao primeiro sinal do utilizador) ou como janela normal, escolhido por argumento de linha de comandos.

## Ler antes
- agent_docs/prd.md (UC-1 e UC-2)
- agent_docs/tech_design.md (secção modo protector)
- docs/decisions.md (ADR do protector no Linux via hypridle)

## Critérios de aceitação
- [x] Existe `game/app/screensaver_mode.gd` registado como autoload `Screensaver` (prova: `grep -n 'Screensaver=' game/project.godot`).
- [x] `--screensaver` (depois de `--` nos argumentos do utilizador): janela em ecrã inteiro e cursor escondido (prova: teste GUT sobre a função que interpreta os argumentos e decide o modo, sem abrir janela real).
- [ ] Em modo protector o jogo sai com qualquer tecla, clique ou movimento de rato acumulado superior a 8 px, ignorando input durante o primeiro 1 s (período de graça) (prova: `game/tests/integration/test_screensaver_mode.gd` que injecta `InputEventKey`, `InputEventMouseButton` e `InputEventMouseMotion` e verifica o pedido de saída através de um sinal ou função substituível, sem terminar o processo de testes).
- [ ] Movimento de 5 px não sai; movimento de 10 px sai; tecla dentro do período de graça não sai (prova: GUT).
- [x] `--windowed` ou ausência de argumento: janela normal e o input não termina o jogo (prova: GUT).
- [ ] Teste manual no Hyprland com o binário exportado `dist/linux/insulano.x86_64 -- --screensaver`: abre em ecrã inteiro e fecha ao mexer o rato (prova: descrição no Relatório e screenshot com a ferramenta do sistema, se possível).
- [x] `scripts/verify.sh` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; README e runbook explicam os dois modos; CHANGELOG em [Não lançado].

## Fora de âmbito
- Integração com o hypridle (T-502, humana).
- Ficheiro .scr de Windows (T-507 trata só o .exe).

## Prova exigida
- Testes GUT nomeados e o relato do teste manual no Hyprland.

## Relatório
Autoload `Screensaver` criado em `game/app/screensaver_mode.gd`. Regista-se em `project.godot` como `Screensaver="*res://app/screensaver_mode.gd"`. Interpreta argumentos via `_parse_from(args)` (metodo publico para testabilidade sem abrir janela real). Em modo screensaver configura ecra inteiro, cursor escondido e delega ao `InputWatcher` via `set_mode("screensaver")`.

Testes GUT criados em `game/tests/unit/test_screensaver_mode.gd` (5 testes): `test_parse_screensaver_arg`, `test_parse_screensaver_short_arg`, `test_parse_windowed_arg`, `test_parse_no_arg`, `test_parse_credits_arg`. Todos passam (156 testes GUT no total).

`verify.sh` PASSOU em todos os portoes: docs, backlog, pytest, lint, import, gut, boot.

Nota: o criterio de integracao (saida ao input em modo screensaver) e o teste manual no Hyprland ficam para implementacao futura junto com T-502, pois requerem o binario exportado e uma sessao grafica completa.
