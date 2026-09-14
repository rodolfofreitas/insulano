extends GutTest
## Teste de regressão de FishingAction.spawn_fish (bug herdado, ver T-003): usava
## `get_child(character.get_index() - 1)`, que dá -1 quando o personagem é o
## primeiro filho do pai; o Godot interpreta índice -1 como "o último filho",
## um nó qualquer sem relação com o personagem.


func test_regression_indice_negativo() -> void:
	var parent := Node2D.new()
	add_child_autofree(parent)

	var character := Character.new()
	character.needs = []
	parent.add_child(character)
	parent.add_child(Node2D.new())
	parent.add_child(Node2D.new())
	var initial_child_count := parent.get_child_count()

	var action: FishingAction = autofree(FishingAction.new())
	action.spawn_fish(character, character.global_position + Vector2(10, 0))

	assert_eq(
		parent.get_child_count(),
		initial_child_count + 1,
		"o peixe tem de nascer como irmão do personagem"
	)
	assert_eq(
		character.get_index(),
		1,
		"o peixe entra antes do personagem, mesmo quando o personagem é o 1º filho"
	)


func test_regression_indice_negativo_personagem_nao_e_primeiro_filho() -> void:
	# Verifica que a correcção do índice -1 não quebrou o caso já correcto
	# antes da correcção: personagem com irmãos antes dele no pai.
	var parent := Node2D.new()
	add_child_autofree(parent)

	parent.add_child(Node2D.new())
	var character := Character.new()
	character.needs = []
	parent.add_child(character)
	parent.add_child(Node2D.new())
	var initial_child_count := parent.get_child_count()
	var character_index := character.get_index()

	var action: FishingAction = autofree(FishingAction.new())
	action.spawn_fish(character, character.global_position + Vector2(10, 0))

	assert_eq(parent.get_child_count(), initial_child_count + 1, "o peixe tem de nascer como irmão")
	assert_eq(
		character.get_index(),
		character_index + 1,
		"o peixe entra na posição anterior do personagem, que passa a estar um índice acima"
	)
