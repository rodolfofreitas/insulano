class_name SetDeltaOnBlackboardAction
extends ActionLeaf
## Escreve o delta do frame corrente no blackboard, para outras folhas o lerem.
##
## Devolve `RUNNING` (não é falha) enquanto o delta for 0, e `SUCCESS` assim que
## deixar de o ser.

@export var key: StringName = "delta"
@export var use_physics_process: bool = false

var last_time = 0


## Ignora o actor; lê o delta do processo escolhido e escreve-o em `key`.
func tick(_actor: Node, blackboard: Blackboard) -> int:
	var delta = 0
	if use_physics_process:
		delta = get_physics_process_delta_time()
	else:
		delta = get_process_delta_time()

	blackboard.set_value(key, delta)
	print("delta = ", delta)
	if delta == 0:
		return RUNNING
	return SUCCESS
