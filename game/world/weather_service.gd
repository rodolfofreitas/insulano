class_name WeatherService
extends Node
## Servico de tempo: devolve condicao meteorologica com variacao aleatoria natural.
## Autoload: Weather. Ligado por defeito. Sem pedidos de rede.
## V2: considerar integracao com servico meteorologico real (ver docs/decisions.md ADR-012).

signal weather_changed(condition: String)

## Pesos para clima aleatorio: distribuicao tipica de dias em Lisboa.
## clear=50%, clouds=30%, rain=15%, storm=4%, snow=1%
const RANDOM_WEIGHTS: Dictionary = {"clear": 50, "clouds": 30, "rain": 15, "storm": 4, "snow": 1}

## Intervalo entre mudancas de clima (em segundos de jogo).
const CHANGE_INTERVAL_S: float = 1800.0

var _current: String = "clear"
var _timer: float = 0.0
var _rng: RandomNumberGenerator


func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	## Variavel de ambiente para testes sem alterar o codigo.
	var fake := OS.get_environment("INSULANO_FAKE_WEATHER")
	if fake != "":
		_current = fake
		return
	_current = _pick_weather()


## Condicao actual: clear|clouds|rain|storm|snow.
func current() -> String:
	return _current


## Devolve clima aleatorio com pesos naturais. Publico para testes.
func random_weather() -> String:
	return _pick_weather()


func _pick_weather() -> String:
	var total: int = 0
	for w: int in RANDOM_WEIGHTS.values():
		total += w
	var roll := _rng.randi_range(0, total - 1)
	var acc: int = 0
	for cond: String in RANDOM_WEIGHTS:
		acc += RANDOM_WEIGHTS[cond]
		if roll < acc:
			return cond
	return "clear"


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= CHANGE_INTERVAL_S:
		_timer = 0.0
		var new_cond := _pick_weather()
		if new_cond != _current:
			_current = new_cond
			weather_changed.emit(_current)
