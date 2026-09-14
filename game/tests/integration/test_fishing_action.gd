extends GutTest
## Teste de regressão de FishingAction.spawn_fish (bug herdado, ver T-003): usava
## `get_child(character.get_index() - 1)`, que dá -1 quando o personagem é o
## primeiro filho do pai; o Godot interpreta índice -1 como "o último filho",
## um nó qualquer sem relação com o personagem.
##
## test_escreve_current_action_pescar (T-106): FishingAction tem de escrever
## "current_action" no blackboard, para o SayGeneratedAction o usar no
## contexto da frase. Força-se o ramo "à espera da mordida" (in_use = true,
## seconds_until_bite alto) para não precisar de um ponto de pesca nem de
## AnimatedSprite2D válidos, que a animação (fora de âmbito aqui) exigiria.


func test_escreve_current_action_pescar() -> void:
	var action: FishingAction = autofree(FishingAction.new())
	add_child_autofree(action)
	action.in_use = true
	action.seconds_until_bite = 999.0

	var character := Character.new()
	character.needs = []
	add_child_autofree(character)

	var blackboard := Blackboard.new()
	add_child_autofree(blackboard)

	var result := action.tick(character, blackboard)

	assert_eq(result, action.RUNNING, "sem a mordida acontecer ainda, tick tem de ficar RUNNING")
	assert_eq(blackboard.get_value("current_action"), "pescar")


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
