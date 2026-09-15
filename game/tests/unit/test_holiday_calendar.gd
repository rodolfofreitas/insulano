extends GutTest
## Testes de [HolidayCalendar]: algoritmo de Meeus/Butcher para a Pascoa,
## feriados fixos, feriados moveis (offset_days), dias normais vazios e
## robustez a rule.type desconhecido.
##
## Datas de Pascoa verificadas em: https://www.timeanddate.com/holidays/portugal/
## e contra o algoritmo de Meeus/Butcher (Astronomical Algorithms, J. Meeus, 1998).


## Pascoa 2026 = 5 de Abril (Meeus/Butcher).
func test_easter_2026() -> void:
	var e := HolidayCalendar.easter_sunday(2026)
	assert_eq(e.get("year"), 2026, "ano")
	assert_eq(e.get("month"), 4, "mes: Abril")
	assert_eq(e.get("day"), 5, "dia: 5")


## Pascoa 2027 = 28 de Marco (Meeus/Butcher).
func test_easter_2027() -> void:
	var e := HolidayCalendar.easter_sunday(2027)
	assert_eq(e.get("month"), 3, "mes: Marco")
	assert_eq(e.get("day"), 28, "dia: 28")


## Pascoa 2028 = 16 de Abril (ano bissexto -- Fevereiro com 29 dias).
func test_easter_2028() -> void:
	var e := HolidayCalendar.easter_sunday(2028)
	assert_eq(e.get("month"), 4, "mes: Abril")
	assert_eq(e.get("day"), 16, "dia: 16")


## Pascoa 2030 = 21 de Abril (Meeus/Butcher).
func test_easter_2030() -> void:
	var e := HolidayCalendar.easter_sunday(2030)
	assert_eq(e.get("month"), 4, "mes: Abril")
	assert_eq(e.get("day"), 21, "dia: 21")


## Carnaval 2026 = Pascoa(2026) - 47 dias = 2026-02-17.
func test_carnival_2026() -> void:
	var carnival_entry: Dictionary = {
		"id": "carnival",
		"name": "Carnaval",
		"rule": {"type": "easter", "offset_days": -47},
		"scene": "party",
		"phrases": []
	}
	var result := HolidayCalendar.holidays_on(
		{"year": 2026, "month": 2, "day": 17}, [carnival_entry]
	)
	assert_eq(result.size(), 1, "Carnaval deve aparecer em 2026-02-17")
	assert_eq(result[0].get("id", ""), "carnival", "id correcto")


## holidays_on(2026-12-25) deve incluir o feriado christmas do ficheiro real.
func test_christmas() -> void:
	var result := HolidayCalendar.holidays_on({"year": 2026, "month": 12, "day": 25})
	var ids: Array = result.map(func(h) -> String: return h.get("id", ""))
	assert_true("christmas" in ids, "Natal deve estar em 2026-12-25; ids: %s" % str(ids))
	var xmas: Dictionary = result.filter(func(h) -> bool: return h.get("id") == "christmas")[0]
	assert_true(xmas.has("name"), "campo name presente")
	assert_true(xmas.has("scene"), "campo scene presente")
	assert_true(xmas.has("phrases"), "campo phrases presente")


## Um dia normal sem feriados devolve lista vazia.
func test_normal_day() -> void:
	var result := HolidayCalendar.holidays_on({"year": 2026, "month": 9, "day": 13})
	assert_eq(result.size(), 0, "2026-09-13 nao e feriado")


## Entrada com rule.type desconhecido e ignorada (push_warning); as outras funcionam.
func test_invalid_rule_type_ignored() -> void:
	var holidays: Array = [
		{
			"id": "tipo_invalido",
			"name": "Tipo Invalido",
			"rule": {"type": "desconhecido"},
			"scene": "",
			"phrases": []
		},
		{
			"id": "christmas",
			"name": "Natal",
			"rule": {"type": "fixed", "month": 12, "day": 25},
			"scene": "christmas",
			"phrases": ["Feliz Natal."]
		}
	]
	var result := HolidayCalendar.holidays_on({"year": 2026, "month": 12, "day": 25}, holidays)
	assert_eq(result.size(), 1, "so a entrada valida deve aparecer")
	assert_eq(result[0].get("id", ""), "christmas", "feriado valido presente")
