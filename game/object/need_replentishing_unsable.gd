extends GeneralUsableObject

class_name NeedReplentishingUsable

@export var max_replentish_value = 50 ## Maximum replentish value for the Need
@export var replentish_speed = 10 ## Speed of replentishing the Need in units per second
@export var need_name: String ## Name of the Need, that this object can replentish

func get_satisfying_needs():
	var result = Array(satisfying_needs)
	if max_replentish_value == 0:
		var need_index = result.find_custom(func(n): return n.name == need_name)
		if need_index >= 0:
			result.pop_at(need_index)
	return result
	
func use(character: Character, delta: float) -> void:
	var need: Need = character.get_need(need_name)
	var max_use = min(max_replentish_value, replentish_speed * delta)
	if !character.animated_sprite.animation.begins_with("eat"):
		play_animation(character)
	var used = need.increase(max_use)
	max_replentish_value -= used
	if max_replentish_value <= 0:
		queue_free()

func play_animation(character: Character) -> void:
	var direction: Direction = Direction.get_closest_direction(global_position - character.global_position)
	character.play_animation_for_direction(direction, "eat")
