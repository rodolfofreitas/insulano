---
id: T-402
titulo: Cenas de feriado para Natal e Ano Novo
fase: 4
estado: pronto
tipo: visual
depende_de: [T-401, T-202, T-106]
---

## Objectivo
No Natal a ilha tem decoração e o náufrago usa gorro; na véspera e no dia de Ano Novo há fogos de artifício à noite; nesses dias as frases misturam as do `holidays.json` com as geradas pelo LLM com o contexto do feriado.

## Ler antes
- game/world/holiday_calendar.gd (T-401) e game/data/holidays.json
- game/world/day_night.gd (T-202)
- a acção de fala gerada (T-106) e o PromptBuilder (T-102)
- docs/assets-licencas.md

## Critérios de aceitação
- [ ] Existe um nó de cenas de feriado (por exemplo `game/world/holiday_scenes.gd`) que, ao arrancar e à mudança de dia, consulta `HolidayCalendar.holidays_on` com a data do `Clock` e activa a cena indicada pelo campo `scene` (prova: teste de integração GUT com `INSULANO_FAKE_TIME` equivalente para 25 de Dezembro e para um dia normal).
- [ ] Natal (`christmas` e `christmas_eve`): gorro sobre o personagem e pelo menos um elemento decorativo na ilha, desenhados em código ou em PNG criado nesta tarefa e registado em `docs/assets-licencas.md` (prova: screenshot e diff do registo).
- [ ] Ano Novo (`fireworks` e `fireworks_eve`): fogos de artifício com partículas, só visíveis de noite (a partir das 20h) (prova: GUT verifica `emitting` às 21h e não às 13h).
- [ ] Em dia de feriado, o contexto enviado ao LLM tem `holiday` preenchido com o `name`, e pelo menos 1 em cada 3 frases vem do campo `phrases` do feriado (prova: GUT com RNG de seed fixa).
- [ ] Screenshots inspeccionados: `docs/proof/T-402-natal-21h.png` (INSULANO_FAKE_TIME=2026-12-25T21:00), `docs/proof/T-402-ano-novo-23h.png` (2026-12-31T23:30) e `docs/proof/T-402-dia-normal.png` (2026-09-13T21:00, sem decoração).
- [ ] `scripts/verify.sh --visual` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; CHANGELOG em [Não lançado].

## Fora de âmbito
- Neve (a ilha é tropical; a frase já brinca com isso).
- Cenas de Carnaval, Páscoa e Dia do Trabalhador (tarefa futura, os dados já existem).

## Prova exigida
- Os 3 PNG em docs/proof/ com a descrição de cada um e os testes GUT nomeados.

## Relatório
(preenchido pelo executor)
