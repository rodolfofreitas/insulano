---
id: T-132
titulo: Rezar/meditar -- animacao joelhos, melhora ESPERANCA +10
fase: 3
estado: pronto
tipo: codigo
depende_de: [T-111]
---

## Objectivo
Implementar accao F01 (rezar de manha) e meditacao: o naufrago ajoelha-se, fecha os olhos, reza ou medita em silencio. Trigger automatico de manha (hora 6-7) ou quando ESPERANCA <= 30. Accao com muito caracter e expressividade.

## Ler antes
- docs/actions-catalogue.md (F01 Rezar de manha, F10 Fazer paz com a situacao)
- game/world/game_clock.gd
- game/core/needs_manager.gd (ESPERANCA)

## Critérios de aceitação
- [ ] `game/actions/pray_action.gd` com dois modes: `pray_morning` (hora 6-7) e `pray_desperate` (ESPERANCA <= 30); cooldown 12h jogo por mode (prova: grep modes)
- [ ] Animacao `kneel_pray` (3 frames) + `pray_loop` (2 frames loop); particulas de paz/luz opcionales em modo normal (prova: GUT)
- [ ] Duracao: 30-60s de jogo; interrompivel por evento critico de FOME >= 90 (prova: GUT)
- [ ] Efeitos: ESPERANCA += 10, SOLIDAO -= 5 em modo normal; ESPERANCA += 3, emocao="desespero" em modo desesperado (prova: GUT ambos modes)
- [ ] Sons: `prayer_ambient.ogg` em modo normal, `prayer_desperate.ogg` em modo desesperado (prova: grep)
- [ ] Frase LLM categoria="espiritualidade" ao terminar (prova: GUT mock)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Sprites redesenhados (Fase 7)
- Rituais mais complexos (accao F10 e outras -- tarefa separada)

## Prova exigida
- GUT: ESPERANCA=25 -> pray_desperate activo -> ESPERANCA sobe
- GUT: hora=6.5 -> pray_morning activo

## Relatório
(preenchido pelo executor)
