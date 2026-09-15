---
id: T-128
titulo: Xingar o oceano -- frase LLM categoria='furia', animacao bracos ao ar
fase: 3
estado: pronto
tipo: codigo
depende_de: [T-106, T-111]
---

## Objectivo
Implementar accao C02 (xingar o oceano): o naufrago vai ate a beira-mar, levanta os bracos, xinga expressivamente com frase LLM de furia. Activa quando TEDIO >= 55 ou FOME >= 70. Accao de descompressao emocional comica.

## Ler antes
- docs/actions-catalogue.md (C02 Xingar o oceano)
- game/llm/phrase_filter.gd (categorias de frase)
- game/actions/say_generated_action.gd (referencia de accao com LLM)

## Critérios de aceitação
- [ ] `game/actions/scold_ocean_action.gd` com condicao TEDIO >= 55 ou FOME >= 70 (prova: grep condicao)
- [ ] AnimationPlayer: `scold_ocean` = `walk_to_water` + `raise_arms` (4 frames) + `shout_fist` (2 frames loop 3x) + `slump` (2 frames); placeholders ok (prova: GUT)
- [ ] Frase LLM com `categoria="furia"` e contexto `{"alvo": "oceano", "necessidade": [nome_necessidade_mais_alta]}`; frase aparece no speech bubble (prova: GUT mock LLM + inspecao do bubble)
- [ ] Som `shout_frustrated.ogg` durante `shout_fist` (prova: grep)
- [ ] Efeitos: TEDIO -= 20, SOLIDAO -= 5 (o desabafo ajuda) (prova: GUT)
- [ ] Accao tem cooldown 2h de jogo (prova: GUT cooldown)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Redesenho de sprites de xingar (Fase 7)
- Resposta do oceano (evento separado, catalogado como futuro)

## Prova exigida
- GUT com frase de furia gerada e TEDIO reduzido
- Screenshot do speech bubble com xingamento

## Relatório
(preenchido pelo executor)
