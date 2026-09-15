extends Node
## Persistencia de arcos entre sessoes. Escrita atomica: tmp + rename.
## Limite 50 arcos. schema_version=1. Reset gracioso em erro.

const SAVE_PATH: String = "user://arc_history.json"
const TMP_PATH: String = "user://arc_history.tmp.json"
const SCHEMA_VERSION: int = 1
const MAX_ARCS: int = 50

var completed_arcs: Array = []
var active_arc: Dictionary = {}
var schema_version: int = SCHEMA_VERSION


func _ready() -> void:
	load_history()


## Carrega o historico do disco. Em caso de erro retorna estado vazio.
func load_history() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var text := FileAccess.get_file_as_string(SAVE_PATH)
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_warning("[Insulano/ArcHistory] JSON invalido, a resetar")
		return
	var data: Variant = json.get_data()
	if not data is Dictionary:
		push_warning("[Insulano/ArcHistory] JSON invalido, a resetar")
		return
	if data.get("schema_version", 0) != SCHEMA_VERSION:
		push_warning("[Insulano/ArcHistory] schema mismatch, a resetar")
		return
	completed_arcs = data.get("completed_arcs", [])
	active_arc = data.get("active_arc", {})


## Guarda o historico de forma atomica (tmp + rename).
func save_history() -> void:
	var data := {
		"schema_version": SCHEMA_VERSION, "completed_arcs": completed_arcs, "active_arc": active_arc
	}
	var f := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if not f:
		push_warning("[Insulano/ArcHistory] nao conseguiu abrir tmp")
		return
	f.store_string(JSON.stringify(data))
	f.close()
	DirAccess.rename_absolute(
		ProjectSettings.globalize_path(TMP_PATH), ProjectSettings.globalize_path(SAVE_PATH)
	)


## Adiciona arco completo. Descarta os mais antigos se > MAX_ARCS.
func add_completed(arc: Dictionary) -> void:
	completed_arcs.append(arc)
	if completed_arcs.size() > MAX_ARCS:
		completed_arcs = completed_arcs.slice(completed_arcs.size() - MAX_ARCS)
	save_history()


## Ultimos n titulos para contexto do LLM.
func get_recent_titles(n: int) -> Array[String]:
	var result: Array[String] = []
	var start: int = max(0, completed_arcs.size() - n)
	for i in range(start, completed_arcs.size()):
		result.append(str(completed_arcs[i].get("titulo", "")))
	return result
