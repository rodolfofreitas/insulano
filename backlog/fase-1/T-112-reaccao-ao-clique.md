---
id: T-112
titulo: Reaccao ao clique -- 150ms antes de dismiss no modo screensaver
fase: 1
estado: pronto
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
