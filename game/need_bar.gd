extends ProgressBar

class_name NeedBar

@export var target: Character
@export var need_name: String

func _process(delta: float) -> void:
	var need: Need = target.get_need(need_name)
	if need != null:
		max_value = need.max_value
		value = need.current_value
