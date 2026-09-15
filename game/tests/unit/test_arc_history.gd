extends GutTest
## Testes unitarios do ArcHistory: escrita atomica, limite de 50 arcos,
## schema mismatch e get_recent_titles.

const ArcHistoryScript = preload("res://world/arc_history.gd")

var arc_history: Node


func before_each() -> void:
	arc_history = ArcHistoryScript.new()
	arc_history.completed_arcs = []
	arc_history.active_arc = {}
	_cleanup_files()


func after_each() -> void:
	if arc_history:
		arc_history.free()
	_cleanup_files()


func _cleanup_files() -> void:
	if FileAccess.file_exists("user://arc_history.json"):
		DirAccess.remove_absolute(
			ProjectSettings.globalize_path("user://arc_history.json")
		)
	if FileAccess.file_exists("user://arc_history.tmp.json"):
		DirAccess.remove_absolute(
			ProjectSettings.globalize_path("user://arc_history.tmp.json")
		)


## Escrever JSON corrompido em user://arc_history.json, chamar load_history(),
## confirmar que completed_arcs esta vazio (reset gracioso em erro de parsing).
func test_atomic_write_survives_corruption() -> void:
	var f := FileAccess.open("user://arc_history.json", FileAccess.WRITE)
	f.store_string("{corrupted json [[[ not valid")
	f.close()
	arc_history.load_history()
	assert_eq(
		arc_history.completed_arcs.size(), 0,
		"Estado corrompido deve ser ignorado e completados ficam vazios"
	)


## Adicionar 55 arcos, confirmar que completed_arcs.size() == 50 (limite maximo).
func test_max_50_arcs_enforced() -> void:
	for i in range(55):
		arc_history.add_completed({"titulo": "Arco %d" % i, "id": i})
	assert_eq(
		arc_history.completed_arcs.size(), 50,
		"Deve manter exactamente 50 arcos apos adicionar 55"
	)


## Guardar JSON com schema_version=99, confirmar que load_history() reseta para estado vazio.
func test_schema_mismatch_resets() -> void:
	var bad_data := {
		"schema_version": 99,
		"completed_arcs": [{"titulo": "Arco Antigo", "id": 1}],
		"active_arc": {"titulo": "Activo", "id": 0}
	}
	var f := FileAccess.open("user://arc_history.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(bad_data))
	f.close()
	arc_history.load_history()
	assert_eq(
		arc_history.completed_arcs.size(), 0,
		"Schema mismatch deve resetar completed_arcs para vazio"
	)
	assert_eq(
		arc_history.active_arc.size(), 0,
		"Schema mismatch deve resetar active_arc para vazio"
	)


## Adicionar 5 arcos, get_recent_titles(3) deve devolver os 3 ultimos titulos.
func test_get_recent_titles() -> void:
	var titulos := ["Jangada", "Companheiro", "Sinal", "Diario", "Avulso"]
	for t: String in titulos:
		arc_history.add_completed({"titulo": t})
	var recentes: Array[String] = arc_history.get_recent_titles(3)
	assert_eq(recentes.size(), 3, "Deve devolver exactamente 3 titulos")
	assert_eq(recentes[0], "Sinal", "Primeiro dos 3 deve ser o 3o arco")
	assert_eq(recentes[1], "Diario", "Segundo dos 3 deve ser o 4o arco")
	assert_eq(recentes[2], "Avulso", "Terceiro dos 3 deve ser o 5o (ultimo) arco")
