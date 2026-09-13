extends CharacterBody2D

class_name Character

@export var needs: Array[Need]
@export var walking_speed: int = 100 # Speed in px/s
@export var navigationAgent: NavigationAgent2D
@export var animated_sprite: AnimatedSprite2D

var current_walking_dir: Vector2 = Vector2.ZERO

@export var speech_bubble: Label

@export var talking_text: String = "":
	set(value):
		talking_text = value
		if speech_bubble != null:
			speech_bubble.text = value
			if value == "":
				speech_bubble.visible = false
			else:
				speech_bubble.visible = true

func _ready() -> void:
	if speech_bubble != null:
		speech_bubble.text = talking_text
		if talking_text != "":
			speech_bubble.visible = true

func walk_towards(target_global: Vector2) -> void:
	if navigationAgent == null:
		velocity = (target_global - global_position).normalized() * walking_speed
	else:
		navigationAgent.target_position = target_global

func _physics_process(delta: float) -> void:
	if navigationAgent != null:
		if !navigationAgent.is_navigation_finished():
			var current_agent_position: Vector2 = global_position
			var next_path_position: Vector2 = navigationAgent.get_next_path_position()

			velocity = current_agent_position.direction_to(next_path_position) * walking_speed
		else:
			velocity = Vector2.ZERO
	move_and_slide()
	
func get_needs() -> Array[Need]:
	return needs
	
func get_need(name: String) -> Need:
	var result: Need
	for need in needs:
		if need.name == name:
			result = need
			break
	return result


func play_animation_for_direction(dir: Direction, name: String) -> void:
	match dir:
		Direction.UP:
			animated_sprite.play(name + "_up")
		Direction.RIGHT:
			animated_sprite.play(name + "_right")
		Direction.DOWN:
			animated_sprite.play(name + "_down")
		Direction.LEFT:
			animated_sprite.play(name + "_left")
		_:
			animated_sprite.stop()
