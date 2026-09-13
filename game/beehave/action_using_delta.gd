extends ActionLeaf

class_name ActionUsingDelta

@export var use_physics_process_delta: bool = false

func get_delta() -> float:
	var result = 0
	if use_physics_process_delta:
		result = get_physics_process_delta_time()
	else:
		result = get_process_delta_time()
	return result
