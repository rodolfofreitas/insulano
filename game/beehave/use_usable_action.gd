@tool
extends ActionUsingDelta

class_name UseUsableAction

var last_time: float = 0

@export var object_blackboard_key: StringName = "usable"

func tick(actor: Node, blackboard: Blackboard) -> int:
	var usable: UsableObject = blackboard.get_value(object_blackboard_key)
	var need: Need = blackboard.get_value("need")
	var delta = get_delta()
	
	# If need over 99.5, stop it. (99 instead of 100, because >= 100 almost never happens
	if need.get_percentage() < 98 && is_instance_valid(usable):
		usable.use(actor, delta)
		return RUNNING
	else:
		return SUCCESS
