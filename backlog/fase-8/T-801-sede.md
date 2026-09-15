---
id: T-801
titulo: Necessidade SEDE -- agua de coco, chuva, destilar agua do mar
fase: 8
estado: pronto
tipo: codigo
depende_de: [T-110]
---

## Objectivo
Implementar a necessidade SEDE no NeedsManager: range 0-100, sobe passivamente, desce com accoes de hidratacao (beber agua de coco, apanhar agua da chuva, destilar agua do mar). O naufrago nunca morre de sede -- a crise gera comportamento expressivo e comico.

## Ler antes
- docs/needs-system.md (seccao 1, principio fundamental)
- docs/actions-catalogue.md (A03 beber agua de coco, A05 destilar agua, A08 recolher chuva)
- game/core/needs_manager.gd (classe INeed, implementacao de FOME como referencia)

## Critérios de aceitação
- [ ] `game/core/needs/thirst_need.gd` criado com `class_name ThirstNeed extends INeed`, range 0-100, taxa base +0.4/s passivo (prova: `grep -n ThirstNeed game/core/needs/thirst_need.gd`)
- [ ] SEDE registada no NeedsManager e exposta como sinal `need_changed("sede", valor)` (prova: teste GUT que escuta o sinal e avanca 10s)
- [ ] Accao A03 (beber agua de coco): SEDE -= 30, FOME -= 10, cooldown 4h de jogo; falha se SEDE < 20 (prova: GUT com estado inicial SEDE=50)
- [ ] Accao A05 (destilar agua): SEDE -= 50, ESPERANCA += 5; requer fogueira activa + 2 conchas; timer 120s (prova: GUT mock fogueira)
- [ ] Accao A08 (recolher chuva): SEDE -= 40; so activa quando WeatherService.current == "rain"; SEDE >= 70 activa automaticamente (prova: GUT mock WeatherService)
- [ ] Crise (SEDE == 100): comportamento expressivo -- frase LLM com categoria="sede_crise", alucinacao comica visivel no idle (emote balao agua); naufrago NAO morre (prova: GUT avanca SEDE ate 100, verifica frase emitida e estado "vivo")
- [ ] `scripts/verify.sh` sem FALHOU; CHANGELOG actualizado

## Fora de âmbito
- Sprites e animacoes para accoes de sede (ver T-805)
- Novos sprites de coco ou concha (Fase 7 / T-703)
- Integracao com sistema de inventario de cocos (tarefa separada)

## Prova exigida
- Output de `python3 scripts/backlog.py check` sem erros
- Resultado dos testes GUT para ThirstNeed colado no Relatorio
- Screenshot ou log mostrando SEDE a atingir 100 sem game over

## Relatório
(preenchido pelo executor)
