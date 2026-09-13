extends Node2D

class_name UsableObject

func get_satisfying_needs() -> Array[String]:
	return []

func can_satisfy(need_name: String) -> bool:
	return get_satisfying_needs().any(func (n): return n == need_name)

func use(character: Character, delta: float) -> void:
	pass
