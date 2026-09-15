class_name GameClock
extends Node
## Relogio do jogo: fonte unica da hora, com suporte a hora simulada para testes.
## Autoload: Clock. Nunca leres Time directamente -- usa sempre Clock.now().

signal hour_changed(hour: int)

var _last_hour: int = -1
var _fake_time: String = ""


func _ready() -> void:
	## Carrega fake_time da env var ou do setting. Env var tem precedencia.
	var env_val: String = OS.get_environment("INSULANO_FAKE_TIME")
	if env_val != "":
		_fake_time = env_val
	else:
		_fake_time = ProjectSettings.get_setting("insulano/debug/fake_time", "")


## Devolve dicionario com a data/hora actual (ou simulada).
## Formato igual a Time.get_datetime_dict_from_system().
func now() -> Dictionary:
	if _fake_time != "":
		var parsed := _parse_fake_time(_fake_time)
		if not parsed.is_empty():
			return parsed
	return Time.get_datetime_dict_from_system()


## Hora como decimal: 21:30 devolve 21.5.
func hour_float() -> float:
	var d := now()
	return float(d.get("hour", 0)) + float(d.get("minute", 0)) / 60.0


## Periodo do dia: madrugada, manha, tarde, fim da tarde, noite.
func period() -> String:
	var h := int(hour_float())
	if h < 6:
		return "madrugada"
	if h < 12:
		return "manha"
	if h < 17:
		return "tarde"
	if h < 20:
		return "fim da tarde"
	return "noite"


func _process(_delta: float) -> void:
	var h := int(hour_float())
	if h != _last_hour:
		_last_hour = h
		hour_changed.emit(h)


func _parse_fake_time(s: String) -> Dictionary:
	## Formato esperado: AAAA-MM-DDTHH:MM
	var parts := s.split("T")
	if parts.size() != 2:
		push_warning("[Insulano/Clock] INSULANO_FAKE_TIME invalido: %s" % s)
		return {}
	var date_parts := parts[0].split("-")
	var time_parts := parts[1].split(":")
	if date_parts.size() != 3 or time_parts.size() != 2:
		push_warning("[Insulano/Clock] INSULANO_FAKE_TIME invalido: %s" % s)
		return {}
	return {
		"year": int(date_parts[0]),
		"month": int(date_parts[1]),
		"day": int(date_parts[2]),
		"hour": int(time_parts[0]),
		"minute": int(time_parts[1]),
		"second": 0,
		"weekday": 0,
		"dst": false
	}
