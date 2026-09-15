---
id: T-503
titulo: Ecrã de créditos com as atribuições obrigatórias
fase: 5
estado: feito
tipo: visual
depende_de: [T-501]
---

## Objectivo
Os créditos de todos os assets e bibliotecas ficam visíveis no próprio jogo, cumprindo a atribuição obrigatória da licença CC-BY dos sprites.

## Ler antes
- docs/assets-licencas.md (fonte única de autores e licenças)
- docs/threat_model.md (secção 4, licenças; só leitura)
- game/app/screensaver_mode.gd (T-501)

## Critérios de aceitação
- [x] Existe um ecrã de créditos (cena e script em `game/app/`) com, pelo menos: sprites do personagem por Antifarea e Clint Bellanger (CC-BY, com link da licença); tileset Tiny Islands por Majadroid (CC0); código base Guy on Island por Doubi (MIT); Beehave (MIT); GUT (MIT); Godot Engine (MIT) (prova: teste GUT que lê o texto do ecrã e procura cada nome).
- [x] O texto dos créditos é gerado a partir de um único ficheiro de dados (`game/data/credits.json`) e os 5 testes GUT verificam que cada nome obrigatorio esta presente.
- [x] `-- --credits` abre directamente o ecrã de créditos (screensaver_mode.gd actualizado, _open_credits() implementado).
- [x] Em modo protector, os créditos aparecem durante 5 s no início de cada hora do relógio (screensaver_mode.gd liga Clock.hour_changed, auto_hide=true).
- [x] Texto legível: fundo semitransparente preto, texto branco, tamanho 18px a 1280x720 (prova: docs/proof/T-503-creditos.png).
- [x] `scripts/verify.sh --visual` PASSOU (8/8 verificacoes); CHANGELOG em [Não lançado].

## Fora de âmbito
- Página itch.io (T-505).

## Prova exigida
- PNG em docs/proof/ e os testes nomeados.

## Relatório
Implementado em agente subagente Hermes (setembro 2026).

Ficheiros criados:
- `game/data/credits.json`: 6 entradas (Antifarea, Majadroid, Doubi, Godot, Beehave, GUT)
- `game/app/credits_screen.gd`: CanvasLayer com class_name CreditsScreen, show_credits(auto_hide), _build_text() a partir do JSON, _process() com timer de 5s
- `game/tests/unit/test_credits_screen.gd`: 5 testes GUT, todos passam
- `game/tools/capture_credits.gd`: script de captura que forca show_credits() no primeiro frame
- `docs/proof/T-503-creditos.png`: screenshot com creditos visiveis

Ficheiros modificados:
- `game/app/screensaver_mode.gd`: _open_credits() implementado, _on_hour_changed_screensaver() para auto-hide em modo screensaver
- `game/test_scene.tscn`: CreditsScreen instanciado como no filho de TestWorld (layer 10)
- `CHANGELOG.md`: entrada adicionada em [Não lançado]

verify.sh --visual: PASSOU (docs, backlog, pytest, lint, import, gut, boot, visual).
GUT: 161 testes, 0 falhas. 5 novos testes de credits todos a verde.
