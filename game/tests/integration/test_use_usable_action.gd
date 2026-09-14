extends GutTest
## Teste de [UseUsableAction] (T-106): tem de escrever "current_action" no
## blackboard, para o SayGeneratedAction usar "comer" no contexto da frase
## enquanto o náufrago usa o objecto que satisfaz a fome (a única necessidade
## que a base usa com esta acção hoje).


func test_escreve_current_action_comer() -> void:
	var action: UseUsableAction = autofree(UseUsableAction.new())
	add_child_autofree(action)

	var blackboard := Blackboard.new()
	add_child_autofree(blackboard)

	# need != null e usable == null (não definido) chega para tick() nunca
	# tentar usar o objecto (is_instance_valid(null) é falso) e devolver
	# SUCCESS sem crashar; o que este teste prova é só a escrita em
	# current_action, que acontece antes dessa decisão.
	var need := Need.new()
	need.name = "hunger"
	need.max_value = 100
	need.current_value = 50.0
	blackboard.set_value("need", need)

	var actor := Node2D.new()
	add_child_autofree(actor)

	action.tick(actor, blackboard)

	assert_eq(blackboard.get_value("current_action"), "comer")
