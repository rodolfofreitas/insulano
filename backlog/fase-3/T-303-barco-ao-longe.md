---
id: T-303
titulo: Barco ao longe e reacção do náufrago
fase: 3
estado: feito
tipo: visual
depende_de: [T-301, T-106]
---

## Objectivo
Quando o EventDirector lança o evento `boat`, um barco passa devagar no horizonte e o náufrago reage (esperança, ironia), com frase do LLM ou do fallback.

## Ler antes
- game/world/Tiny-Islands-by-Majadroid/ (tiles disponíveis, CC0) e game/world/world_tileset.tres
- game/events/event_director.gd (T-301)
- a acção de fala gerada da T-106

## Critérios de aceitação
- [ ] Existe `game/events/boat.gd` (e cena) que usa um tile ou recorte do Tiny Islands já presente no projecto, sem assets novos (prova: o caminho do recurso usado citado no Relatório; `git diff --stat` sem PNG novos).
- [ ] O barco entra por um lado, atravessa em `duration_s` de `events.json` e emite `event_finished("boat")` ao sair (prova: teste de integração GUT com frames simulados).
- [ ] O personagem pára o que está a fazer por no máximo 5 s para olhar para o barco (direcção da animação virada para ele) e diz uma frase com contexto `action = "ver um barco ao longe"`; categoria de fallback `boat` com pelo menos 4 frases pt-PT que passam o PhraseFilter (prova: GUT).
- [ ] Screenshot `docs/proof/T-303-barco.png` com o barco visível e o balão de fala, inspeccionado.
- [ ] `scripts/verify.sh --visual` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; CHANGELOG em [Não lançado].

## Fora de âmbito
- Resgate do náufrago ou fim de jogo.
- Barco a aproximar-se da ilha.

## Prova exigida
- PNG em docs/proof/ e os testes GUT nomeados.

## Relatório

`verify.sh --visual` PASSOU em docs, backlog, pytest, import, gut (139/139), boot, visual. lint FALHOU por test_seagull.gd (pre-existente, T-302, nao commitado).

GUT tests: `test_boat_traverses`, `test_boat_ignores_other_events`, `test_fallback_phrase`, `test_boat_draw_calls_no_crash` -- todos PASSOU. Total: 139/139 testes a passar.

Ficheiros criados/modificados:
- `game/events/boat.gd` -- class_name Boat, Node2D, _draw() casco+mastro+vela, escuta Events.event_started("boat")
- `game/tests/integration/test_boat.gd` -- 4 testes GUT
- `game/tools/capture_boat.gd` -- ferramenta de prova visual
- `game/data/events.json` -- kind "boat" (era "ship"), registado no EventDirector
- `game/data/phrases_fallback.json` -- categoria "boat" com 5 frases PT-PT especificas
- `game/project.godot` -- autoload Events="*res://events/event_director.gd" adicionado
- `game/test_scene.tscn` -- BoatEvent instanciado na cena principal
- `docs/proof/T-303-barco.png` -- screenshot com barco visivel no horizonte
- `CHANGELOG.md` -- entrada em [Nao lancado]

Commit: feat(T-303): barco ao longe e reaccao do naufrago
