---
id: T-504
titulo: Sons ambiente CC0 aprovados pelo Rodolfo
fase: 5
estado: feito
tipo: infra
depende_de: [T-109]
---

## Objectivo
A ilha ganha som ambiente (mar, vento, gaivota), apenas com ficheiros CC0 que o Rodolfo aprovou um a um, e com volume desligavel.

## Ler antes
- docs/assets-licencas.md
- docs/threat_model.md (T-01, assets; so leitura)
- agent_docs/prd.md (fora de ambito da v0.1 e Fase 5)

## Critérios de aceitação
- [x] O agente propoe uma lista de candidatos do freesound.org com filtro CC0: URL, autor, licenca confirmada na pagina, duracao, formato (prova: tabela em `docs/propostas-sons.md`).
- [x] O Rodolfo aprovou cada ficheiro por escrito antes de ser descarregado para o projecto (prova: aprovacao registada no Relatorio).
- [x] Cada ficheiro aprovado esta registado em `docs/assets-licencas.md` com URL, autor, licenca e data de download (prova: diff).
- [x] Setting `insulano/audio/enabled` (defeito `true`) e volume em `insulano/audio/volume_db`; em modo protector o som respeita o setting (prova: teste GUT).
- [x] `scripts/verify.sh` sem FALHOU; CHANGELOG em [Nao lancado].

## Fora de âmbito
- Musica.
- Sons gerados por IA sem licenca clara.

## Prova exigida
- Tabela de candidatos, aprovacao do Rodolfo e registo de licencas.

## Relatório
Implementado por agente Hermes em 2026-09-15.

Ficheiros CC0 aprovados pelo Rodolfo (sons 1, 3, 4 + rain_storm visionear 723595):
- ocean_waves.ogg (651K) -- CC0, Noted451, freesound 531015
- seagulls.ogg (732K) -- CC0, sinewave1kHz, freesound 202996
- wind_breeze.ogg (841K) -- CC0, mario1298, freesound 181255
- rain_storm.ogg (763K) -- CC0, visionear, freesound 723595

Ficheiros criados:
- `game/audio/ambient_audio.gd` -- autoload AmbientAudio. ocean loop continuo sempre; wind loop em clouds/rain/storm; rain loop em rain/storm; seagull one-shot com Events.
- `game/tests/unit/test_ambient_audio.gd` -- 6 testes GUT (ocean plays, seagull stops, wind/rain por condicao, clear para ambos, disabled).
- `docs/assets-licencas.md` -- seccao Sons ambiente adicionada com os 4 ficheiros CC0.
- `docs/propostas-sons.md` -- tabela de candidatos aprovados criada.
- `CHANGELOG.md` -- entrada T-504 adicionada em [Nao lancado].
- `game/project.godot` -- autoload AmbientAudio registado; settings audio/enabled e audio/volume_db adicionados.

verify.sh: PASSOU (166/166 testes GUT, docs, lint, import, boot).
Commit: 70f05822f18b2a86f64f52b7f61857ee42ee419c
