class_name EventDirector
extends Node

## Director de eventos: agenda e dispara eventos aleatorios com seed.
## Autoload: Events. Config em game/data/events.json.

signal event_started(kind: String, data: Dictionary)
signal event_finished(kind: String)

const EVENTS_PATH: String = "res://data/events.json"

var _rng: RandomNumberGenerator
var _events_config: Array = []
var _active_events: Dictionary = {}  # kind -> tempo_restante
var _cooldowns: Dictionary = {}  # kind -> tempo_restante
var _enabled: bool = false
## Caminho alternativo do JSON; se vazio usa EVENTS_PATH. Sobrepor em testes.
var _config_path: String = ""


func _ready() -> void:
	_load_config()
	var seed_val: int = ProjectSettings.get_setting("insulano/events/seed", 0)
	_rng = RandomNumberGenerator.new()
	if seed_val == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_val


## Avanca o tempo do director (para testes sem esperar tempo real).
func advance_time(delta: float) -> void:
	if not _enabled:
		return
	_tick_active(delta)
	_tick_cooldowns(delta)
	_maybe_spawn(delta)


func _process(delta: float) -> void:
	advance_time(delta)


## Redefine seed e limpa estado activo -- util para testes reproductiveis.
func reset_with_seed(seed_val: int) -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = seed_val
	_active_events.clear()
	_cooldowns.clear()


func _load_config() -> void:
	var path: String = _config_path if _config_path != "" else EVENTS_PATH
	var text := FileAccess.get_file_as_string(path)
	var parser := JSON.new()
	if parser.parse(text) != OK or not parser.get_data() is Dictionary:
		push_warning("[Insulano/Events] events.json invalido")
		return
	var data: Dictionary = parser.get_data()
	_events_config = data.get("events", [])
	_enabled = _events_config.size() > 0


func _tick_active(delta: float) -> void:
	for kind in _active_events.keys():
		_active_events[kind] -= delta
		if _active_events[kind] <= 0:
			_active_events.erase(kind)
			event_finished.emit(kind)


func _tick_cooldowns(delta: float) -> void:
	for kind in _cooldowns.keys():
		_cooldowns[kind] -= delta
		if _cooldowns[kind] <= 0:
			_cooldowns.erase(kind)


func _maybe_spawn(delta: float) -> void:
	var candidates: Array = []
	for ev in _events_config:
		var kind: String = ev.get("kind", "")
		if kind in _active_events:
			continue
		if kind in _cooldowns:
			continue
		candidates.append(ev)
	if candidates.is_empty():
		return
	# peso total
	var total_weight: float = 0.0
	for ev in candidates:
		total_weight += float(ev.get("weight", 1))
	var roll: float = _rng.randf() * total_weight * (1.0 / max(delta, 0.016))
	if roll > total_weight:
		return  # probabilidade por segundo
	var pick: float = _rng.randf() * total_weight
	var acc: float = 0.0
	for ev in candidates:
		acc += float(ev.get("weight", 1))
		if pick <= acc:
			_start_event(ev)
			break


func _start_event(ev: Dictionary) -> void:
	var kind: String = ev.get("kind", "")
	_active_events[kind] = float(ev.get("duration_s", 10))
	_cooldowns[kind] = float(ev.get("min_interval_s", 300))
	event_started.emit(kind, ev)
