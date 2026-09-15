class_name GameClock
extends Node
## Relogio do jogo: fonte unica da hora, com suporte a hora simulada para testes.
## Autoload: Clock. Nunca leres Time directamente -- usa sempre Clock.now().
## T-123: modo acelerado em screensaver -- 30 min reais = 1 ciclo de 24h de jogo,
## ancorado na hora real (ou fake) de arranque.

signal hour_changed(hour: int)

## Duracao de um ciclo de jogo completo em segundos reais (30 minutos).
const GAME_DAY_DURATION_S: float = 1800.0

var _last_hour: int = -1
var _fake_time: String = ""
var _accelerated: bool = false
var _start_game_seconds: float = 0.0
var _game_elapsed: float = 0.0
var _game_time_s: float = 0.0


func _ready() -> void:
	## Carrega fake_time da env var ou do setting. Env var tem precedencia.
	var env_val: String = OS.get_environment("INSULANO_FAKE_TIME")
	if env_val != "":
		_fake_time = env_val
	else:
		_fake_time = ProjectSettings.get_setting("insulano/debug/fake_time", "")

	## Activar modo acelerado se o autoload Screensaver ja estiver disponivel.
	## Nota: a ordem dos autoloads pode fazer Screensaver nao existir ainda em _ready().
	if is_inside_tree() and has_node("/root/Screensaver"):
		if Screensaver.mode() == "screensaver":
			_activate_accelerated_mode()


## Activa o modo acelerado: ancora o ciclo na hora actual (real ou fake).
## Pode ser chamado externamente pelo Screensaver se o Clock arrancar primeiro.
func _activate_accelerated_mode() -> void:
	var d := now()
	var real_seconds: float = (
		float(d.get("hour", 0)) * 3600.0
		+ float(d.get("minute", 0)) * 60.0
		+ float(d.get("second", 0))
	)
	var real_fraction: float = real_seconds / 86400.0
	_start_game_seconds = real_fraction * GAME_DAY_DURATION_S
	_game_time_s = _start_game_seconds
	_game_elapsed = 0.0
	_accelerated = true


## Devolve dicionario com a data/hora actual (ou simulada).
## Formato igual a Time.get_datetime_dict_from_system().
func now() -> Dictionary:
	if _fake_time != "":
		var parsed := _parse_fake_time(_fake_time)
		if not parsed.is_empty():
			return parsed
	return Time.get_datetime_dict_from_system()


## Hora como decimal: 21:30 devolve 21.5.
## Em modo acelerado (screensaver), devolve a hora do ciclo de jogo (30min = 24h).
## INSULANO_FAKE_TIME so afecta now() e o calculo da ancora; nao desactiva a aceleracao.
func hour_float() -> float:
	if _accelerated:
		return (_game_time_s / GAME_DAY_DURATION_S) * 24.0
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


func _process(delta: float) -> void:
	if _accelerated:
		_game_elapsed += delta
		_game_time_s = fmod(_start_game_seconds + _game_elapsed, GAME_DAY_DURATION_S)
	var h := int(hour_float())
	if h != _last_hour:
		_last_hour = h
		hour_changed.emit(h)


func _parse_fake_time(s: String) -> Dictionary:
	## Formato esperado: AAAA-MM-DDTHH:MM ou AAAA-MM-DDTHH:MM:SS
	var parts := s.split("T")
	if parts.size() != 2:
		push_warning("[Insulano/Clock] INSULANO_FAKE_TIME invalido: %s" % s)
		return {}
	var date_parts := parts[0].split("-")
	var time_parts := parts[1].split(":")
	if date_parts.size() != 3 or time_parts.size() < 2:
		push_warning("[Insulano/Clock] INSULANO_FAKE_TIME invalido: %s" % s)
		return {}
	return {
		"year": int(date_parts[0]),
		"month": int(date_parts[1]),
		"day": int(date_parts[2]),
		"hour": int(time_parts[0]),
		"minute": int(time_parts[1]),
		"second": int(time_parts[2]) if time_parts.size() > 2 else 0,
		"weekday": 0,
		"dst": false
	}
