class_name WeatherService
extends Node
## Servico de tempo: devolve condicao meteorologica actual.
## Autoload: Weather. Desligado por defeito (insulano/weather/enabled=false).
## Nunca bloqueia um frame.

signal weather_changed(condition: String)

const CODES_PATH: String = "res://data/weather_codes.json"
const REFRESH_INTERVAL_S: float = 3600.0
const TIMEOUT_S: float = 3.0

var _current: String = "unknown"
var _enabled: bool = false
var _location: String = ""
var _codes: Dictionary = {}
var _http: HTTPRequest
var _timer: float = 0.0


func _ready() -> void:
	_enabled = ProjectSettings.get_setting("insulano/weather/enabled", false)
	_location = ProjectSettings.get_setting("insulano/weather/location", "")
	_load_codes()
	var fake := OS.get_environment("INSULANO_FAKE_WEATHER")
	if fake != "":
		_current = fake
		return  # nao faz pedidos HTTP
	if not _enabled:
		return
	_http = HTTPRequest.new()
	_http.timeout = TIMEOUT_S
	add_child(_http)
	_http.request_completed.connect(_on_response)
	_fetch()


## Condicao actual: clear|clouds|rain|storm|snow|unknown.
func current() -> String:
	return _current


## Parsing publico para testes injectarem respostas sem rede.
func parse_response(body: PackedByteArray) -> String:
	var text := body.get_string_from_utf8()
	var parser := JSON.new()
	if parser.parse(text) != OK:
		push_warning("[Insulano/Weather] JSON invalido")
		return _current
	var data: Variant = parser.get_data()
	if not data is Dictionary:
		return _current
	var conditions: Variant = data.get("current_condition", [])
	if not conditions is Array or conditions.is_empty():
		return _current
	var code: int = int(str(conditions[0].get("weatherCode", "0")))
	for cond: String in _codes:
		var codes_for_cond: Variant = _codes[cond]
		if not codes_for_cond is Array:
			continue
		if code in codes_for_cond:
			return cond
	return "unknown"


func _load_codes() -> void:
	var text := FileAccess.get_file_as_string(CODES_PATH)
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return
	var data: Variant = parser.get_data()
	if not data is Dictionary:
		return
	for key: String in data:
		var val: Variant = data[key]
		if not val is Array:
			continue
		var int_codes: Array[int] = []
		for v: Variant in val:
			int_codes.append(int(v))
		_codes[key] = int_codes


func _process(delta: float) -> void:
	if not _enabled:
		return
	_timer += delta
	if _timer >= REFRESH_INTERVAL_S:
		_timer = 0.0
		_fetch()


func _fetch() -> void:
	if _location == "":
		return
	var url := "https://wttr.in/%s?format=j1" % _location.uri_encode()
	_http.request(url)


func _on_response(
	result: int, code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		push_warning("[Insulano/Weather] falha HTTP %d" % code)
		return
	var new_cond := parse_response(body)
	if new_cond != _current:
		_current = new_cond
		weather_changed.emit(_current)
