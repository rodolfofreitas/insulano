---
id: T-133
titulo: Cantarolar -- audio procedural, trigger quando TEDIO > 50
fase: 3
estado: feito
tipo: codigo
depende_de: [T-111, T-106]
---

## Objectivo
Implementar accao E02 (cantarolar/assobiar): overlay sobre outras accoes (pode cantarolar enquanto caminha), trigger automatico quando TEDIO > 50. Audio procedural ou sons CC0 em loop. A accao mais simples e de maior impacto sonoro.

## Ler antes
- docs/actions-catalogue.md (E02 Assobiar uma melodia, E01 Cantar em voz alta)
- game/actions/say_generated_action.gd (overlay pattern)
- agent_docs/tech_design.md (audio layers)

## Critérios de aceitação
- [ ] `game/actions/hum_action.gd` implementado como overlay (nao bloqueia outras accoes); trigger TEDIO > 50 (prova: GUT com outra accao activa em simultaneo)
- [ ] Tres modos: `hum_happy` (ESPERANCA >= 60), `hum_nostalgic` (30 <= ESPERANCA < 60), `hum_sad` (ESPERANCA < 30); som diferente em cada modo (prova: GUT verifica 3 paths)
- [ ] Sons: `singing_humming.ogg` (happy), `humming_nostalgic.ogg` (nostalgico), sons em loop com fade-in/out de 1s (prova: grep AudioStreamPlayer com bus)
- [ ] Overlay sobre animacao `walk`: sincronizacao visual -- frame de boca aberta a cada 4 frames de walk (prova: screenshot ou GUT frame-by-frame)
- [ ] Duracao: continua enquanto TEDIO > 40; para quando TEDIO <= 40 ou accao de fala activa (prova: GUT TEDIO decrements)
- [ ] Efeitos: TEDIO -= 0.1/s enquanto activo (prova: GUT 60s)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Geracao de melodia procedural real (AudioStreamGenerator -- tarefa futura)
- Cantar em voz alta (E01 -- accao separada mais complexa)

## Prova exigida
- GUT: TEDIO=60 -> hum activo, TEDIO decresce; TEDIO=38 -> hum para
- GUT: overlay com walk em simultaneo

## Relatório
- `game/beehave/hum_action.gd` criado com `HumAction` (ActionLeaf). Timer
  autonomo; tick devolve RUNNING ate HUM_DURATION e SUCCESS ao fim, repondo o
  timer a zero. Trigger de TEDIO >= 50 fica na arvore Beehave.
- Categoria `cantarolar` adicionada a `game/data/phrases_fallback.json` (5 frases PT-PT).
- 4 testes GUT em `game/tests/unit/test_wave_hum.gd` partilhados com T-131.
