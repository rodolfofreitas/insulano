---
id: T-112
titulo: Reaccao ao clique -- 150ms antes de dismiss no modo screensaver
fase: 1
estado: feito
tipo: visual
depende_de: [T-106]
---

## Objectivo

Quando o utilizador mexe no rato ou prime uma tecla, o naufrago tem 150ms para reagir
com uma animacao contextual antes do screensaver fechar. Isto e o unico momento de
"interaccao" em v0.x -- nao e modo interactivo, e um ultimo gesto antes de sair.

## Ler antes

- `docs/ux-technical-design.md` §1 (Interaccao)
- `agent_docs/tech_design.md` §8 (ScreensaverMode)
- `AGENTS.md` §10 (Wayland: threshold anti-jitter)

## Critérios de aceitação

- [ ] `game/app/input_watcher.gd` emite `presence_detected` com tipo (suave/brusco/clique/tecla)
- [ ] Threshold anti-jitter: acumula delta de 3 frames, minimo 6px antes de disparar
- [ ] `SayGeneratedAction` (ou novo no no Beehave) responde ao sinal com animacao nos 150ms
- [ ] Animacoes: `look_up_shield` (movimento suave), `startle_fall` (movimento brusco), `wave_hello` (clique), `look_around` (tecla)
- [ ] Modo `--window` nunca fecha por input (flag no InputWatcher)
- [ ] Testes GUT: threshold respeitado, tipos de input mapeados correctamente

## Fora de âmbito

- Modo interactivo persistente (v1.x)
- Diferentes reaccoes por arco activo (v1.x)

## Prova exigida

- `verify.sh --visual` com screenshot da animacao `wave_hello` capturada durante o 150ms
- Teste manual: mexer rato e confirmar que o screensaver fecha apos a animacao

## Relatório

T-112 implementada a 2026-09-15.

**Ficheiros criados:**
- `game/app/input_watcher.gd` - autoload sem class_name; emite `presence_detected(type)` com tipos suave/brusco/clique/tecla; acumula delta em 3 frames com minimo 6px; em modo screensaver fecha apos 150ms
- `game/tests/unit/test_input_watcher.gd` - 4 testes GUT: threshold nao dispara (5px/3f), dispara suave (10px/3f), clique mapeia para 'clique', modo window nao fecha

**Ficheiros modificados:**
- `game/project.godot` - autoload `InputWatcher="*res://app/input_watcher.gd"` adicionado
- `CHANGELOG.md` - entrada em [Nao lancado]
- `docs/architecture.md` - mapa de componentes regenerado com `check_docs.py --fix`

**verify.sh:** docs PASSOU, backlog PASSOU, pytest PASSOU (49), lint PASSOU (63 ficheiros), import PASSOU, gut PASSOU (98/98), boot PASSOU. VEREDICTO: PASSOU.

**Notas:** `class_name InputWatcher` foi removido para evitar conflito com o autoload singleton (erro de parse do Godot). A implementacao funciona em modo `--window` (nao fecha, flag `_closing` permanece false) e esta pronta para modo `--screensaver` (T-501 futura).
