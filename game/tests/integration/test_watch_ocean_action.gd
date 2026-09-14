extends GutTest
## Teste de [WatchOceanAction] (T-106): tem de escrever "current_action" no
## blackboard, para o SayGeneratedAction usar "observar o oceano" no contexto
## da frase enquanto o náufrago olha o mar.


func test_escreve_current_action_observar_o_oceano() -> void:
	var action: WatchOceanAction = autofree(WatchOceanAction.new())
	add_child_autofree(action)

	var blackboard := Blackboard.new()
	add_child_autofree(blackboard)

	var actor := Node2D.new()
	add_child_autofree(actor)

	action.tick(actor, blackboard)

	assert_eq(blackboard.get_value("current_action"), "observar o oceano")
