extends Character

class_name Guy

@export var standard_hunger_decrease: float = 1 ## percent per second
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _process(delta: float) -> void:
	var hunger: Need = get_need("hunger")
	if hunger != null:
		hunger.decrease_percent(standard_hunger_decrease * delta)
	else:
		animated_sprite.stop()
