extends GutTest
## Testes unitarios do SessionData: escrita atomica, contagem de peixes,
## deduplicacao de arcos e schema_version.

const SessionDataScript = preload("res://world/session_data.gd")

var session: Node


func before_each() -> void:
	session = SessionDataScript.new()
	session.days_survived = 0
	session.fish_caught = 0
	session.arcs_completed.clear()
	session.first_session = ""
	session.last_session = ""
	_cleanup_files()


func after_each() -> void:
	if session:
		session.free()
	_cleanup_files()


func _cleanup_files() -> void:
	if FileAccess.file_exists("user://save.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://save.json"))
	if FileAccess.file_exists("user://save.tmp.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://save.tmp.json"))


## Apos save(), o ficheiro user://save.json deve existir.
func test_save_creates_file() -> void:
	session.save()
	assert_true(FileAccess.file_exists("user://save.json"), "save() deve criar user://save.json")


## record_fish_caught() + novo SessionData -> fish_caught == 1.
func test_fish_count_persists() -> void:
	session.record_fish_caught()
	var session2 := SessionDataScript.new()
	session2.load_or_init()
	assert_eq(session2.fish_caught, 1, "fish_caught deve ser 1 apos reload")
	session2.free()


## record_arc_completed com o mesmo id duas vezes -> tamanho == 1.
func test_arc_no_duplicate() -> void:
	session.record_arc_completed("jangada")
	session.record_arc_completed("jangada")
	assert_eq(session.arcs_completed.size(), 1, "arcs_completed nao deve conter duplicados")


## save.json deve conter schema_version == 1.
func test_schema_version() -> void:
	session.save()
	var text := FileAccess.get_file_as_string("user://save.json")
	var parser := JSON.new()
	assert_eq(parser.parse(text), OK, "save.json deve ser JSON valido")
	var data: Variant = parser.get_data()
	assert_true(data is Dictionary, "save.json deve ser um dicionario")
	assert_eq(int(data.get("schema_version", 0)), 1, "schema_version deve ser 1")
