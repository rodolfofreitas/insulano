@tool
extends ActionLeaf

class_name GoToUsableAction

@export var blackboard_key: StringName = "location"
@export var distance_threshold: float = 50

func tick(actor: Node, blackboard: Blackboard) -> int:
	var position: Vector2 = blackboard.get_value(blackboard_key)
	var character = actor as Character
	var result: int = FAILURE
	if position != null:
		
		var is_first_call = blackboard.get_value("goToUsable_first_call", true)
	
		if !is_first_call && character.navigationAgent.is_navigation_finished():
			blackboard.erase_value("goToUsable_first_call")
			character.velocity = Vector2.ZERO
			character.animated_sprite.stop()
			character.animated_sprite.frame = 1

			result = SUCCESS
		else:
			blackboard.set_value("goToUsable_first_call", false)
			if distance_threshold > 0:
				character.navigationAgent.target_desired_distance = distance_threshold
			character.walk_towards(position)
			
			if character.velocity.length_squared() > 0:
				var direction: Direction = Direction.get_closest_direction(character.velocity.normalized())
				character.play_animation_for_direction(direction, "walk")
			else:
				character.animated_sprite.stop()
				character.animated_sprite.frame = 1
			result = RUNNING
	else:
		character.velocity = Vector2.ZERO

	return result
	
