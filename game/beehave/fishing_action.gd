@tool
extends ActionUsingDelta

class_name FishingAction

var fish_scene = preload("res://object/raw_fish.tscn")

@export var node_blackboard_key: StringName = "usable_spot"
@export var fishingRod: Sprite2D
@export var animation_name: String = "fishing"

var seconds_until_bite: float
var in_use: bool = false

func tick(actor: Node, blackboard: Blackboard) -> int:
	var character = actor as Character
	var result: int = FAILURE
	var spot: Node2D = blackboard.get_value(node_blackboard_key)
	
	if !in_use:
		seconds_until_bite = randf_range(5, 10)
		play_animation(character, spot)
		if fishingRod != null:
			display_fishing_rod(character, spot)
		in_use = true
		result = RUNNING
	else:
		seconds_until_bite -= get_delta()
		if seconds_until_bite <= 0:
			spawn_fish(character, spot.global_position)
			in_use = false
			character.animated_sprite.stop()
			if fishingRod != null:
				fishingRod.transform = Transform2D.IDENTITY
				fishingRod.visible = false
			result = SUCCESS
		else:
			result = RUNNING

	
	return result

func play_animation(character: Character, fishing_spot: Node2D) -> void:
	var direction: Direction = Direction.get_closest_direction(fishing_spot.global_position - character.global_position)
	character.play_animation_for_direction(direction, animation_name)

func display_fishing_rod(character: Character, fishing_spot: Node2D) -> void:
	var direction: Direction = Direction.get_closest_direction(fishing_spot.global_position - character.global_position)
	match direction:
		Direction.UP: fishingRod.transform = fishingRod.transform.rotated(deg_to_rad(-90))
		Direction.RIGHT: pass
		Direction.DOWN: fishingRod.transform = fishingRod.transform.rotated(deg_to_rad(90))
		Direction.LEFT: fishingRod.transform = fishingRod.transform.scaled(Vector2(-1, 1))
	fishingRod.visible = true
			
func spawn_fish(character: Character, spot_location: Vector2) -> void:
	var fish: Node2D = fish_scene.instantiate()
	var character_location: Vector2 = character.global_position
	var direction: Direction = Direction.get_closest_direction(character_location - spot_location) # Spawn behind character -> top of vector is character_location
	fish.position = character_location + (direction.vector * 32)
	var parent: Node = character.get_parent()
	character.get_parent().get_child(character.get_index() - 1).add_sibling(fish)
