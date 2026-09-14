extends GutTest
## Testes de [GoToUsableAction] focados em current_action_label (T-106): este
## nó é partilhado por três sequências da árvore (ir comer, ir pescar,
## passear), e as TRÊS instâncias em guy.tscn definem o seu próprio rótulo
## ("ir comer", "ir pescar", "passear" respectivamente), para a
## SayGeneratedAction a seguir na mesma sequência nunca ler o current_action
## deixado pela sequência anterior (ver go_to_usable_action.gd). O 1º teste
## prova esse caso, com rótulo definido; o 2º prova o caso neutro (sem
## rótulo, o defeito de @export), que hoje nenhuma instância na árvore usa,
## mas que este nó continua a suportar sem escrever nada em current_action.


## Dá ao personagem um AnimatedSprite2D com as 4 animações de "walk" válidas
## (mesmo sem frames reais), para tick() poder tocar a animação de andar sem
## rebentar com uma referência nula (character/character.gd:15, @export
## animated_sprite, chega null por defeito).
func _make_walking_character() -> Character:
	var character := Character.new()
	character.needs = []

	var frames := SpriteFrames.new()
	var texture := PlaceholderTexture2D.new()
	for anim_name in ["walk_up", "walk_down", "walk_left", "walk_right"]:
		frames.add_animation(anim_name)
		frames.add_frame(anim_name, texture)

	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	character.animated_sprite = sprite

	add_child_autofree(sprite)
	add_child_autofree(character)
	return character


func test_escreve_current_action_quando_label_definido() -> void:
	var action: GoToUsableAction = autofree(GoToUsableAction.new())
	action.current_action_label = "passear"
	action.distance_threshold = 0.0
	add_child_autofree(action)

	var blackboard := Blackboard.new()
	add_child_autofree(blackboard)
	blackboard.set_value("location", Vector2(10, 10))

	var character := _make_walking_character()

	action.tick(character, blackboard)

	assert_eq(blackboard.get_value("current_action"), "passear")


func test_nao_escreve_current_action_sem_label_definido() -> void:
	var action: GoToUsableAction = autofree(GoToUsableAction.new())
	action.distance_threshold = 0.0
	add_child_autofree(action)

	var blackboard := Blackboard.new()
	add_child_autofree(blackboard)
	blackboard.set_value("location", Vector2(10, 10))

	var character := _make_walking_character()

	action.tick(character, blackboard)

	assert_false(
		blackboard.has_value("current_action"),
		(
			"sem current_action_label (caso neutro, nenhuma das 3 instâncias na árvore usa), "
			+ "este nó não deve escrever nada"
		)
	)
