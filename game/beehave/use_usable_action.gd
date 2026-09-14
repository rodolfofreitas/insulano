@tool
class_name UseUsableAction
extends ActionUsingDelta
## Usa o objecto em `object_blackboard_key` enquanto a necessidade associada não estiver satisfeita.
##
## Chama `UsableObject.use` a cada tick; devolve `SUCCESS` quando a necessidade
## passa dos 98% (não 100%, porque atingir exactamente 100 quase nunca acontece)
## ou o objecto deixou de ser válido (ex.: consumido e libertado).

@export var object_blackboard_key: StringName = "usable"

var last_time: float = 0


## Usa o objecto do blackboard até a necessidade associada estar quase satisfeita.
func tick(actor: Node, blackboard: Blackboard) -> int:
	# Contexto para o LLMBridge (SayGeneratedAction, T-106): a única
	# necessidade que a base usa aqui é a fome, por isso o verbo é fixo,
	# como em SleepAction (code_patterns.md §4).
	blackboard.set_value("current_action", "comer")
	var usable: UsableObject = blackboard.get_value(object_blackboard_key)
	var need: Need = blackboard.get_value("need")
	var delta = get_delta()

	if need.get_percentage() < 98 && is_instance_valid(usable):
		usable.use(actor, delta)
		return RUNNING
	return SUCCESS
