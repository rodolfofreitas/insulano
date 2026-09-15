---
id: T-802
titulo: Necessidade HIGIENE -- banho, lavar maos, fazer necessidades
fase: 8
estado: pronto
tipo: codigo
depende_de: [T-110]
---

## Objectivo
Implementar a necessidade HIGIENE no NeedsManager: range 0-100 (100 = sujo), sobe com acoes que sujam (comer lula crua, trabalhar na lama), desce com acoes de higiene (banho, lavar maos). Gera drama emocional e comportamentos comicos, nunca pune com morte.

## Ler antes
- docs/needs-system.md (principio fundamental)
- docs/actions-catalogue.md (B01 tomar banho, B02 lavar maos, B03 fazer xixi, A07 comer lula)
- game/core/needs_manager.gd (referencia de implementacao)

## Critérios de aceitação
- [ ] `game/core/needs/hygiene_need.gd` com `class_name HygieneNeed extends INeed`, range 0-100 (sujidade), taxa base +0.1/s passivo (prova: `grep -n HygieneNeed game/core/needs/hygiene_need.gd`)
- [ ] Accao B01 (tomar banho no mar): HIGIENE -= 60, TEDIO -= 10; requer WeatherService != "storm"; duracao 30s de jogo (prova: GUT)
- [ ] Accao B02 (lavar maos): HIGIENE -= 15, instantaneo, disponivel sempre junto ao oceano (prova: GUT)
- [ ] Accao B03 (fazer xixi): HIGIENE sobe +5 se nao feito em 8h jogo; accao reseta contador; CONFORTO += 20 apos (prova: GUT com timer)
- [ ] Comer lula crua (A07) adiciona HIGIENE += 10 alem dos efeitos de FOME (prova: GUT)
- [ ] Crise (HIGIENE >= 80): emote de nuvem fedorenta sobre cabeca, frases de auto-consciencia; NAO morre (prova: GUT avanca HIGIENE ate 80, verifica emote)
- [ ] `scripts/verify.sh` sem FALHOU; CHANGELOG actualizado

## Fora de âmbito
- Sprites de banho e animacoes (ver T-806)
- Integracao com shader de sujidade visual no sprite (Fase 7)
- Som de splash e agua (Fase 5 T-504 ou tarefa separada)

## Prova exigida
- Output dos testes GUT para HygieneNeed
- Log mostrando HIGIENE >= 80 com emote activo e sem morte

## Relatório
(preenchido pelo executor)
