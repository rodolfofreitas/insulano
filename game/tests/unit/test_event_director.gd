extends GutTest

## Testes unitarios do EventDirector: sinais, seed reprodutivel, exclusividade
## de kind, cooldown e comportamento com config invalida.

const EventDirectorScript = preload("res://events/event_director.gd")

## JSON minimo para testes -- dois eventos com pesos e intervalos reduzidos.
const FAKE_EVENTS_JSON: String = """
{
  "_schema_version": 1,
  "events": [
    {
      "id": "test_seagull",
      "kind": "seagull",
      "weight": 100,
      "min_interval_s": 60,
      "duration_s": 5,
      "requires_condition": null,
      "arc_id": null
    },
    {
      "id": "test_ship",
      "kind": "ship",
      "weight": 80,
      "min_interval_s": 90,
      "duration_s": 8,
      "requires_condition": null,
      "arc_id": null
    }
  ]
}
"""

const INVALID_CONFIG: String = "isto nao e json valido {"

## Instancia isolada com config injectada via ficheiro temporario.
var _dir: EventDirector
## Caminho do ficheiro JSON temporario criado para cada teste.
var _tmp_json_path: String = ""


## Cria ficheiro JSON temporario e devolve o caminho absoluto do sistema de ficheiros.
func _write_tmp_json(content: String) -> String:
	var path: String = "user://test_events_%d.json" % randi()
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(content)
		f.close()
	return ProjectSettings.globalize_path(path)


func _make_director(json_content: String) -> EventDirector:
	var abs_path: String = _write_tmp_json(json_content)
	var d: EventDirector = EventDirectorScript.new()
	d._config_path = abs_path
	_tmp_json_path = abs_path
	return d


func before_each() -> void:
	_dir = _make_director(FAKE_EVENTS_JSON)
	add_child(_dir)


func after_each() -> void:
	if is_instance_valid(_dir):
		_dir.queue_free()
	if _tmp_json_path != "" and FileAccess.file_exists(_tmp_json_path):
		DirAccess.remove_absolute(_tmp_json_path)
	_tmp_json_path = ""


## event_started e event_finished sao emitidos correctamente ao avancar tempo.
func test_signals_watched() -> void:
	watch_signals(_dir)
	_dir.reset_with_seed(42)
	## Avanca em passos grandes para forcara um evento rapidamente.
	var started: bool = false
	var finished: bool = false
	for _i: int in range(3000):
		_dir.advance_time(0.1)
		if not started and get_signal_emit_count(_dir, "event_started") > 0:
			started = true
		if not finished and get_signal_emit_count(_dir, "event_finished") > 0:
			finished = true
		if started and finished:
			break
	assert_true(started, "event_started deve ser emitido num avanco de 300s")
	assert_true(finished, "event_finished deve ser emitido apos a duracao do evento")


## Com seed 42, duas corridas de 600s produzem a mesma sequencia de eventos.
func test_same_seed_same_sequence() -> void:
	## Primeira corrida.
	_dir.reset_with_seed(42)
	var seq_a: Array = []
	_dir.event_started.connect(func(kind: String, _data: Dictionary) -> void: seq_a.append(kind))
	for _i: int in range(6000):
		_dir.advance_time(0.1)

	## Segunda corrida -- nova instancia com a mesma seed.
	var dir2: EventDirector = _make_director(FAKE_EVENTS_JSON)
	add_child(dir2)
	dir2.reset_with_seed(42)
	var seq_b: Array = []
	dir2.event_started.connect(func(kind: String, _data: Dictionary) -> void: seq_b.append(kind))
	for _i: int in range(6000):
		dir2.advance_time(0.1)
	dir2.queue_free()

	assert_gt(seq_a.size(), 0, "seed 42 deve produzir pelo menos 1 evento em 600s")
	assert_eq(seq_a, seq_b, "a mesma seed deve produzir a mesma sequencia de eventos")


## Nunca dois eventos do mesmo kind activos em simultaneo.
func test_no_simultaneous_same_kind() -> void:
	_dir.reset_with_seed(7)
	var active_kinds: Dictionary = {}
	var violation: bool = false

	_dir.event_started.connect(
		func(kind: String, _data: Dictionary) -> void:
			if kind in active_kinds:
				violation = true
			active_kinds[kind] = true
	)
	_dir.event_finished.connect(func(kind: String) -> void: active_kinds.erase(kind))

	for _i: int in range(36000):
		_dir.advance_time(0.1)

	assert_false(violation, "nunca deve haver dois eventos do mesmo kind activos em simultaneo")


## Apos um evento, o mesmo kind nao reaparece antes de min_interval_s.
func test_min_interval_respected() -> void:
	_dir.reset_with_seed(99)
	var last_finish_time: Dictionary = {}  # kind -> tempo em que terminou
	var elapsed: float = 0.0
	var violation: bool = false
	## min_interval_s do seagull e 60s no fake JSON; usar margem de 0.1s.
	var min_interval: float = 60.0

	_dir.event_finished.connect(func(kind: String) -> void: last_finish_time[kind] = elapsed)
	_dir.event_started.connect(
		func(kind: String, _data: Dictionary) -> void:
			if kind in last_finish_time:
				var gap: float = elapsed - last_finish_time[kind]
				if gap < min_interval - 0.5:
					violation = true
	)

	var step: float = 0.1
	for _i: int in range(36000):
		elapsed += step
		_dir.advance_time(step)

	assert_false(violation, "min_interval_s deve ser respeitado entre eventos do mesmo kind")


## Com JSON invalido o director fica inactivo e nao emite sinais.
func test_missing_config_inactive() -> void:
	var dir_bad: EventDirector = _make_director(INVALID_CONFIG)
	add_child(dir_bad)
	dir_bad.reset_with_seed(1)
	var count: int = 0
	dir_bad.event_started.connect(func(_k: String, _d: Dictionary) -> void: count += 1)

	for _i: int in range(3000):
		dir_bad.advance_time(0.1)

	dir_bad.queue_free()
	assert_eq(count, 0, "director com config invalida deve ficar inactivo (sem eventos)")
