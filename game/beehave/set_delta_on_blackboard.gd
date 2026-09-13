extends ActionLeaf

class_name SetDeltaOnBlackboardAction

@export var key: StringName = "delta"
@export var use_physics_process: bool = false

var last_time = 0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var delta = 0
	if use_physics_process:
		delta = get_physics_process_delta_time()
	else:
		delta = get_process_delta_time()

	blackboard.set_value(key, delta)
	print("delta = ", delta)
	if delta == 0:
		return RUNNING
	else:
		return SUCCESS
