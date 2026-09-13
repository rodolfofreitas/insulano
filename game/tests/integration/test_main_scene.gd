extends GutTest
## Teste de integração da cena principal: garante que a cena configurada em
## application/run/main_scene instancia e contém um personagem com a necessidade
## "hunger". Protege contra renomeações de cena ou de nós que partem o arranque.

var _scene: Node


func before_each() -> void:
	var scene_path: String = ProjectSettings.get_setting("application/run/main_scene")
	var packed: PackedScene = load(scene_path) as PackedScene
	assert_not_null(packed, "a cena principal tem de carregar: %s" % scene_path)
	_scene = packed.instantiate()
	add_child_autofree(_scene)


func test_main_scene_has_a_character() -> void:
	assert_not_null(_find_character(_scene), "a cena principal tem de ter um Character")


func test_character_has_hunger_need() -> void:
	var character: Character = _find_character(_scene)
	assert_not_null(character.get_need("hunger"), "o Character tem de ter a necessidade hunger")


func _find_character(node: Node) -> Character:
	if node is Character:
		return node
	for child in node.get_children():
		var found: Character = _find_character(child)
		if found != null:
			return found
	return null
