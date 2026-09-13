@tool
extends ConditionLeaf

class_name FindGroupSpotCondition

@export var group_name: StringName
@export var location_blackboard_key: StringName = "location"
@export var node_blackboard_key: StringName = "found_node"

func tick(actor: Node, blackboard: Blackboard) -> int:
	var available_spots: Array[Node] = get_tree().get_nodes_in_group(group_name)
	var spot = available_spots.pick_random()
	if (spot != null && spot is Node2D):
		blackboard.set_value(location_blackboard_key, spot.global_position)
		blackboard.set_value(node_blackboard_key, spot)
		return SUCCESS
	else:
		return FAILURE
