---
id: T-129
titulo: Dancar de alegria -- trigger ESPERANCA > 80, animacao de danca
fase: 3
estado: pronto
tipo: codigo
depende_de: [T-111, T-804]
---

## Objectivo
Implementar accao D07 (dancar sozinho na praia): trigger automatico quando ESPERANCA >= 80, o naufrago danca espontaneamente em dois estilos (shuffle e samba improvisado), com emocao maxima. A accao mais divertida visualmente.

## Ler antes
- docs/actions-catalogue.md (D07 Dancar sozinho na praia -- 14 frames, 2 estilos)
- docs/needs-system.md (ESPERANCA, estado extase)
- game/character/naufrago.tscn

## Critérios de aceitação
- [ ] `game/actions/dance_joy_action.gd` com trigger automatico ESPERANCA >= 80 (prova: grep trigger)
- [ ] Dois estilos de danca: `dance_shuffle` (7 frames loop) e `dance_samba` (7 frames loop); estilo escolhido aleatoriamente (prova: GUT que verifica os dois paths)
- [ ] Duracao: 20-40s aleatorio; pode ser interrompido por crise de FOME >= 85 (prova: GUT interrupcao)
- [ ] Sons: `humming_dance.ogg` em loop durante a danca (prova: grep)
- [ ] Efeitos: TEDIO -= 30, SOLIDAO -= 15, MOVIMENTO -= 35 ao terminar (prova: GUT)
- [ ] Frase LLM categoria="alegria" gerada no inicio da danca (prova: GUT mock)
- [ ] Emote musical note flutuante durante a danca (prova: screenshot docs/proof/T-129-dance.png)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Sprites de danca redesenhados a 32x48 (Fase 7)
- Danca em grupo com companheiro imaginario (accao futura)

## Prova exigida
- GUT: ESPERANCA=85 -> danca activa, TEDIO reduzido ao terminar
- Screenshot em docs/proof/T-129-dance.png

## Relatório
(preenchido pelo executor)
