class_name HolidayCalendar
extends RefCounted
## Calendario de feriados: datas fixas e moveis calculadas pela Pascoa.
## Sem estado, sem autoload -- so funcoes estaticas puras.

const HOLIDAYS_PATH: String = "res://data/holidays.json"


## Calcula o Domingo de Pascoa pelo algoritmo de Meeus/Butcher.
static func easter_sunday(year: int) -> Dictionary:
	var a: int = year % 19
	var b: int = year / 100
	var c: int = year % 100
	var d: int = b / 4
	var e: int = b % 4
	var f: int = (b + 8) / 25
	var g: int = (b - f + 1) / 3
	var h: int = (19 * a + b - d - g + 15) % 30
	var i: int = c / 4
	var k: int = c % 4
	var l: int = (32 + 2 * e + 2 * i - h - k) % 7
	var m: int = (a + 11 * h + 22 * l) / 451
	var month: int = (h + l - 7 * m + 114) / 31
	var day: int = ((h + l - 7 * m + 114) % 31) + 1
	return {"year": year, "month": month, "day": day}


## Devolve lista de feriados activos na data dada.
## Cada entrada tem: id, name, scene, phrases.
## _override: array opcional para injectao em testes; quando vazio usa HOLIDAYS_PATH.
static func holidays_on(date: Dictionary, _override: Array = []) -> Array:
	var year: int = int(date.get("year", 0))
	var month: int = int(date.get("month", 0))
	var day: int = int(date.get("day", 0))
	var result: Array = []
	var holidays := _override if not _override.is_empty() else _load_holidays()
	var easter := easter_sunday(year)
	for h in holidays:
		var rule: Dictionary = h.get("rule", {})
		var rule_type: String = rule.get("type", "")
		var hmonth: int = 0
		var hday: int = 0
		if rule_type == "fixed":
			hmonth = int(rule.get("month", 0))
			hday = int(rule.get("day", 0))
		elif rule_type == "easter":
			var offset: int = int(rule.get("offset_days", 0))
			var edate := _add_days(easter, offset)
			hmonth = edate.month
			hday = edate.day
		else:
			push_warning("[Insulano/Holiday] rule.type desconhecido: %s" % rule_type)
			continue
		if hmonth == month and hday == day:
			result.append(h)
	return result


static func _load_holidays() -> Array:
	var text := FileAccess.get_file_as_string(HOLIDAYS_PATH)
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return []
	var data: Variant = parser.get_data()
	if not data is Dictionary:
		return []
	return data.get("holidays", [])


static func _add_days(date: Dictionary, days: int) -> Dictionary:
	var d := Time.get_unix_time_from_datetime_dict(date) + days * 86400
	return Time.get_datetime_dict_from_unix_time(d)
