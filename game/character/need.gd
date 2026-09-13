extends Resource

class_name Need

@export var name: String
@export var max_value: int
@export var current_value: float
	
func get_percentage() -> float:
	return float(current_value) / float(max_value) * 100
	
func set_percentage(value: float) -> void:
	current_value = max_value * (value / 100.0)

## Decreases the current value by value, to a minimum of 0
func decrease(value: float) -> void:
	if current_value > 0:
		current_value = max(0, current_value - value)

## Decreases the current percentage by value (100% is always max_value).
func decrease_percent(value: float) -> void:
	var current = get_percentage()
	var new = max(0, current - value)
	set_percentage(new)

## Increases the current percentage by value (100% is always max_value).
func increase_percent(value: float) -> void:
	var current = get_percentage()
	var new = min(100, current + value)
	set_percentage(new)

## Increases the current value by value, to a maximum of max_value.
## Returns the amout used from value for increasing current_value
func increase(value: float) -> float:
	var value_used = 0
	if current_value < max_value:
		value_used = min(max_value - current_value, value)
		current_value += value_used
	return value_used
