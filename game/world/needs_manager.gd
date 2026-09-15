extends Node
## Autoload NeedsManager: gere as necessidades SOLIDAO, TEDIO e ESPERANCA do naufrago.
## As taxas de decaimento e limiares sao lidas de game/data/needs_config.json.
## FOME e gerida pelo personagem; este manager recebe o nivel de fome via set_hunger_level.

signal need_threshold_crossed(need_name: String, threshold: float, direction: String)

const CONFIG_PATH: String = "res://data/needs_config.json"
const LOG_PREFIX: String = "[Insulano/Needs]"

## Configuracao lida do JSON (taxas, limiares, neutros).
var _config: Dictionary = {}

## Valores actuais das necessidades (float 0-100).
var _values: Dictionary = {
	"SOLIDAO": 40.0,
	"TEDIO": 30.0,
	"ESPERANCA": 55.0,
}

## Nivel de FOME recebido do personagem (0-100). Usado para calcular interaccoes.
var _hunger_level: float = 0.0

## Estado dos limiares para detetar cruzamentos (evitar emissao repetida).
var _above_threshold: Dictionary = {}


func _ready() -> void:
	_load_config()
	_init_threshold_state()
	print(LOG_PREFIX + " NeedsManager pronto. Necessidades: " + str(_values.keys()))


## Carrega a configuracao de needs_config.json.
func _load_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_error(LOG_PREFIX + " Nao foi possivel abrir " + CONFIG_PATH)
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error(LOG_PREFIX + " Erro ao parsear " + CONFIG_PATH)
		return
	_config = parsed
	# Actualizar valores neutros iniciais a partir do config.
	for need_name: String in _config:
		if need_name in _values:
			_values[need_name] = float(_config[need_name].get("neutral", _values[need_name]))


## Inicializa o estado dos limiares com base nos valores actuais.
func _init_threshold_state() -> void:
	for need_name: String in _config:
		var threshold: float = float(_config[need_name].get("urgent_threshold", 70.0))
		var passive_rate: float = float(_config[need_name].get("passive_rate", 0.0))
		# Para ESPERANCA, urgencia e abaixo do limiar; para as outras, e acima.
		if passive_rate < 0.0:
			# Necessidade que decresce -- urgencia e valor baixo.
			_above_threshold[need_name] = _values[need_name] > threshold
		else:
			_above_threshold[need_name] = _values[need_name] >= threshold


func _process(delta: float) -> void:
	_apply_passive_rates(delta)
	_apply_interactions(delta)
	_clamp_values()
	_check_thresholds()


## Aplica as taxas passivas de cada necessidade (lidas do config).
func _apply_passive_rates(delta: float) -> void:
	for need_name: String in _values:
		if not need_name in _config:
			continue
		var rate: float = float(_config[need_name].get("passive_rate", 0.0))
		# TEDIO: FOME alta ocupa a mente, TEDIO sobe mais devagar.
		if need_name == "TEDIO" and _hunger_level > 80.0:
			rate = rate * 0.3
		_values[need_name] += rate * delta


## Aplica interaccoes entre necessidades.
func _apply_interactions(delta: float) -> void:
	# FOME alta + SOLIDAO alta drena ESPERANCA.
	if _hunger_level > 80.0 and _values["SOLIDAO"] > 70.0:
		_values["ESPERANCA"] -= 2.0 * delta


## Garante que todos os valores ficam dentro de [0, max].
func _clamp_values() -> void:
	for need_name: String in _values:
		var max_val: float = 100.0
		if need_name in _config:
			max_val = float(_config[need_name].get("max", 100.0))
		_values[need_name] = clampf(_values[need_name], 0.0, max_val)


## Deteta cruzamentos de limiares e emite o sinal correspondente.
func _check_thresholds() -> void:
	for need_name: String in _config:
		var threshold: float = float(_config[need_name].get("urgent_threshold", 70.0))
		var passive_rate: float = float(_config[need_name].get("passive_rate", 0.0))
		var current: float = _values[need_name]
		var was_above: bool = _above_threshold.get(need_name, false)
		var is_above_now: bool
		# Para necessidades que decrescem (ESPERANCA), urgencia e valor baixo.
		if passive_rate < 0.0:
			is_above_now = current > threshold
		else:
			is_above_now = current >= threshold
		if is_above_now != was_above:
			var direction: String = "up" if is_above_now else "down"
			emit_signal("need_threshold_crossed", need_name, threshold, direction)
		_above_threshold[need_name] = is_above_now


## Informa o manager do nivel actual de FOME do personagem (0-100).
func set_hunger_level(value: float) -> void:
	_hunger_level = clampf(value, 0.0, 100.0)


## Devolve o nivel actual de FOME registado.
func get_hunger_level() -> float:
	return _hunger_level


## Devolve o valor actual de uma necessidade (0-100).
func get_value(need_name: String) -> float:
	return _values.get(need_name, 0.0)


## Define o valor de uma necessidade directamente (util para testes e eventos).
func set_value(need_name: String, value: float) -> void:
	if need_name in _values:
		var max_val: float = 100.0
		if need_name in _config:
			max_val = float(_config[need_name].get("max", 100.0))
		_values[need_name] = clampf(value, 0.0, max_val)


## Reduz uma necessidade pelo valor indicado (minimo 0).
func decrease(need_name: String, amount: float) -> void:
	set_value(need_name, _values.get(need_name, 0.0) - amount)


## Aumenta uma necessidade pelo valor indicado (maximo 100 ou max do config).
func increase(need_name: String, amount: float) -> void:
	set_value(need_name, _values.get(need_name, 0.0) + amount)


## Devolve um snapshot das necessidades para contexto do LLM.
func get_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	for need_name: String in _values:
		snapshot[need_name] = {
			"value": _values[need_name],
			"urgent": _is_urgent(need_name),
		}
	snapshot["FOME"] = {
		"value": _hunger_level,
		"urgent": _hunger_level >= 85.0,
	}
	return snapshot


## Devolve true se a necessidade esta em estado urgente.
func _is_urgent(need_name: String) -> bool:
	if not need_name in _config:
		return false
	var threshold: float = float(_config[need_name].get("urgent_threshold", 70.0))
	var passive_rate: float = float(_config[need_name].get("passive_rate", 0.0))
	var current: float = _values[need_name]
	if passive_rate < 0.0:
		return current <= threshold
	return current >= threshold
