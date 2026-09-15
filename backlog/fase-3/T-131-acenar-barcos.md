---
id: T-131
titulo: Acenar a barcos e avioes -- trigger Events.event_started boat/plane
fase: 3
estado: feito
tipo: codigo
depende_de: [T-111, T-301, T-303]
---

## Objectivo
Implementar accao de acenar a barcos e avioes: quando EventDirector emite evento 'boat' ou 'plane', o naufrago corre para a beira e acena com urgencia crescente. ESPERANCA sobe se o barco/aviao nao responde, desce se ignora definitivamente.

## Ler antes
- docs/actions-catalogue.md (seccao G -- Social/Resgate)
- game/events/event_director.gd (sinais event_started, event_finished)
- game/world/boat_scene.gd ou game/world/plane_scene.gd (T-303)

## Critérios de aceitação
- [ ] `game/actions/wave_rescue_action.gd` com `_on_event_started(kind, data)` conectado ao sinal `Events.event_started` (prova: grep Events.event_started)
- [ ] Sequencia: `run_urgency` -> `wave_arms` (4 frames loop) -> `shout_help` (2 frames) -> aguarda resposta; placeholders ok (prova: GUT)
- [ ] Se evento termina sem resposta: ESPERANCA -= 15, frase categoria="decepção"; se evento tem `data.noticed = true`: ESPERANCA += 25 (prova: GUT com dois paths)
- [ ] Som `wave_hello.ogg` durante acenar; `shout_help.ogg` no momento de gritar (prova: grep)
- [ ] Emote de ponto de exclamacao acima da cabeca ao ver o evento (prova: screenshot)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Visual do barco/aviao (T-303 existente)
- Construcao de sinalização de emergencia (tarefa separada)

## Prova exigida
- GUT com path "ignorado" (ESPERANCA -= 15) e path "notado" (ESPERANCA += 25)
- Screenshot do emote

## Relatório
- `game/beehave/wave_action.gd` criado com `WaveAction` (ActionLeaf). Liga-se a
  `Events.event_started` em `_ready`; activa acenagem em 'boat' ou 'seagull'.
  Tick devolve FAILURE/RUNNING/SUCCESS conforme estado e timer.
- Categoria `acenar` adicionada a `game/data/phrases_fallback.json` (5 frases PT-PT).
- 4 testes GUT em `game/tests/unit/test_wave_hum.gd` (boat, seagull, 5s, 8s).
