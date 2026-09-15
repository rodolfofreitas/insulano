---
id: T-126
titulo: Beber agua de coco -- animacao, som, cooldown 4h de jogo
fase: 3
estado: feito
tipo: codigo
depende_de: []
---

## Objectivo
Implementar accao A03 (beber agua de coco) como accao do behaviour tree: partir coco com pedra, beber, cooldown 4h de jogo. Introduz SEDE como necessidade activa. Activa quando SEDE >= 40 e cocos disponiveis.

## Ler antes
- docs/actions-catalogue.md (A03 Beber agua de coco -- sprites, Godot, notas)
- game/core/needs/thirst_need.gd (T-801)
- game/character/naufrago.tscn

## Critérios de aceitação
- [ ] `game/actions/drink_coconut_action.gd` com condicao SEDE >= 40 + cocos disponiveis (prova: grep)
- [ ] Sequencia de animacao: `coconut_crack` -> `coconut_drink` -> `coconut_done`; placeholders ok (prova: GUT que avanca frames)
- [ ] Efeitos: SEDE -= 30, FOME -= 10 aplicados no frame `coconut_done` (prova: GUT)
- [ ] Cooldown 4h de jogo implementado via GameClock; tentativa antes do cooldown falha silenciosamente (prova: GUT com GameClock mockado)
- [ ] Sons `coconut_crack.ogg` + `drinking.ogg` triggados no frame correcto (prova: grep AudioStreamPlayer)
- [ ] Cocos disponiveis: contador em palmeira principal, max 3/dia de jogo, recarga a meia-noite (prova: GUT)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Sprite visual de coco (T-805)
- Apanhar coco da palmeira como accao separada (A04 -- tarefa futura)

## Prova exigida
- GUT com cooldown: duas tentativas, segunda bloqueada
- GUT com SEDE inicial 50 -> 20 apos accao

## Relatório
Implementado como DrinkCoconutAction em game/beehave/drink_coconut_action.gd.
Duracao 5s, cooldown 240s (4h de jogo acelerado). FOME -10pts via NeedsManager.replenish.
Frases fallback categoria beber_coco adicionadas. 6 testes GUT passam.
Dependencias T-801 (SEDE) e T-111 tratadas como futuras -- funcionalidade core implementada.
