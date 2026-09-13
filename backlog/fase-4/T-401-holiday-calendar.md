---
id: T-401
titulo: HolidayCalendar com datas fixas e móveis pela Páscoa
fase: 4
estado: pronto
tipo: codigo
depende_de: [T-001]
---

## Objectivo
O jogo sabe se hoje é um dia especial, incluindo feriados móveis (Carnaval, Páscoa) calculados em código a partir de `game/data/holidays.json`.

## Ler antes
- game/data/holidays.json (formato já existente: rule.type fixed ou easter com offset_days)
- agent_docs/tech_design.md (secção HolidayCalendar)
- agent_docs/code_patterns.md (funções estáticas puras, dados em game/data)

## Critérios de aceitação
- [ ] Existe `game/world/holiday_calendar.gd` com `class_name HolidayCalendar` e as funções `static func easter_sunday(year: int) -> Dictionary` (algoritmo de Meeus/Butcher, devolve `{year, month, day}`) e `static func holidays_on(date: Dictionary) -> Array` (prova: `game/tests/unit/test_holiday_calendar.gd`).
- [ ] Páscoa correcta: 2026-04-05, 2027-03-28, 2028-04-16, 2029-04-01, 2030-04-21 (prova: GUT).
- [ ] Carnaval (Páscoa -47) em 2026 é 2026-02-17 e em 2027 é 2027-02-09 (prova: GUT).
- [ ] `holidays_on({year=2026, month=12, day=25})` devolve uma lista com o feriado `christmas` e os seus campos `name`, `scene`, `phrases`; um dia normal devolve lista vazia (prova: GUT).
- [ ] Deslocamentos que atravessam meses e anos bissextos funcionam (prova: GUT com um offset que cruza Fevereiro de 2028).
- [ ] `holidays.json` inválido ou com `rule.type` desconhecido: essa entrada é ignorada com `push_warning`, as outras continuam a funcionar (prova: GUT com JSON em `game/tests/fixtures/`).
- [ ] `scripts/verify.sh` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; CHANGELOG em [Não lançado].

## Fora de âmbito
- Qualquer cena ou visual de feriado (T-402).
- Feriados de outros países.

## Prova exigida
- Testes GUT nomeados com o resultado e a fonte usada para confirmar as datas de Páscoa (citada no Relatório).

## Relatório
(preenchido pelo executor)
