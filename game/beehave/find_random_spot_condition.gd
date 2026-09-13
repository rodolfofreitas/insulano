@tool
extends ConditionLeaf

class_name FindRandomSpotCondition

@export var blackboard_key: StringName = "location"

func tick(actor: Node, blackboard: Blackboard) -> int:
	var character: Character = actor as Character
	
	var mapId: RID = character.navigationAgent.get_navigation_map()
	var spot: Vector2 = NavigationServer2D.map_get_random_point(mapId, character.navigationAgent.navigation_layers, false)
	if (spot != null && spot != Vector2.ZERO):
		blackboard.set_value(blackboard_key, spot)
		return SUCCESS
	else:
		return FAILURE
