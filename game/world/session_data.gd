extends Node
## Persistencia de sessao: dias sobrevividos, peixes apanhados, arcos completados.
## Escrita atomica (write-to-tmp + rename). Schema_version=1.
## Autoload: SessionData.

const SAVE_PATH := "user://save.json"
const TMP_PATH := "user://save.tmp.json"
const SCHEMA_VERSION := 1

var days_survived: int = 0
var fish_caught: int = 0
var arcs_completed: Array[String] = []
var first_session: String = ""
var last_session: String = ""


func _ready() -> void:
	load_or_init()
	if Engine.has_singleton("Clock") or is_instance_valid(get_node_or_null("/root/Clock")):
		var clock_node := get_node_or_null("/root/Clock")
		if clock_node and clock_node.has_signal("day_changed"):
			clock_node.day_changed.connect(_on_day_changed)


## Carrega o save ou inicializa com valores por defeito.
func load_or_init() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_init_fresh()
		return
	var text := FileAccess.get_file_as_string(SAVE_PATH)
	var parser := JSON.new()
	if parser.parse(text) != OK:
		push_warning("[Insulano/Session] JSON invalido, a reiniciar")
		_init_fresh()
		return
	var data: Variant = parser.get_data()
	if not data is Dictionary:
		_init_fresh()
		return
	days_survived = int(data.get("days_survived", 0))
	fish_caught = int(data.get("fish_caught", 0))
	var raw_arcs: Array = data.get("arcs_completed", [])
	arcs_completed.clear()
	for item in raw_arcs:
		arcs_completed.append(str(item))
	first_session = str(data.get("first_session", ""))
	last_session = str(data.get("last_session", ""))


## Grava o estado actual de forma atomica.
func save() -> void:
	last_session = Time.get_datetime_string_from_system()
	if first_session.is_empty():
		first_session = last_session
	var data := {
		"schema_version": SCHEMA_VERSION,
		"days_survived": days_survived,
		"fish_caught": fish_caught,
		"arcs_completed": arcs_completed,
		"first_session": first_session,
		"last_session": last_session
	}
	var text := JSON.stringify(data)
	var tmp := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if not tmp:
		push_warning("[Insulano/Session] nao conseguiu abrir tmp para escrita")
		return
	tmp.store_string(text)
	tmp.close()
	DirAccess.rename_absolute(
		ProjectSettings.globalize_path(TMP_PATH), ProjectSettings.globalize_path(SAVE_PATH)
	)


## Incrementa o contador de peixes apanhados e grava.
func record_fish_caught() -> void:
	fish_caught += 1
	save()


## Regista arco como completado (sem duplicados) e grava.
func record_arc_completed(arc_id: String) -> void:
	if arc_id not in arcs_completed:
		arcs_completed.append(arc_id)
		save()


func _on_day_changed(_day: int) -> void:
	days_survived += 1
	save()


func _init_fresh() -> void:
	days_survived = 0
	fish_caught = 0
	arcs_completed = []
	first_session = ""
	last_session = ""
	save()
