extends UsableObject

class_name UsableObjectContainer

@export var containing_objects: Array[UsableObject]

func get_satisfying_needs() -> Array[String]:
	var result: Array[String] = []
	for usable in containing_objects:
		result.append_array(usable.get_satisfying_needs())
	return result
