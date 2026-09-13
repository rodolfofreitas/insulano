---
id: T-501
titulo: Modo protector de ecrã e modo janela por argumentos
fase: 5
estado: pronto
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
- [ ] Existe `game/app/screensaver_mode.gd` registado como autoload `Screensaver` (prova: `grep -n 'Screensaver=' game/project.godot`).
- [ ] `--screensaver` (depois de `--` nos argumentos do utilizador): janela em ecrã inteiro e cursor escondido (prova: teste GUT sobre a função que interpreta os argumentos e decide o modo, sem abrir janela real).
- [ ] Em modo protector o jogo sai com qualquer tecla, clique ou movimento de rato acumulado superior a 8 px, ignorando input durante o primeiro 1 s (período de graça) (prova: `game/tests/integration/test_screensaver_mode.gd` que injecta `InputEventKey`, `InputEventMouseButton` e `InputEventMouseMotion` e verifica o pedido de saída através de um sinal ou função substituível, sem terminar o processo de testes).
- [ ] Movimento de 5 px não sai; movimento de 10 px sai; tecla dentro do período de graça não sai (prova: GUT).
- [ ] `--windowed` ou ausência de argumento: janela normal e o input não termina o jogo (prova: GUT).
- [ ] Teste manual no Hyprland com o binário exportado `dist/linux/insulano.x86_64 -- --screensaver`: abre em ecrã inteiro e fecha ao mexer o rato (prova: descrição no Relatório e screenshot com a ferramenta do sistema, se possível).
- [ ] `scripts/verify.sh --export` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; README e runbook explicam os dois modos; CHANGELOG em [Não lançado].

## Fora de âmbito
- Integração com o hypridle (T-502, humana).
- Ficheiro .scr de Windows (T-507 trata só o .exe).

## Prova exigida
- Testes GUT nomeados e o relato do teste manual no Hyprland.

## Relatório
(preenchido pelo executor)
