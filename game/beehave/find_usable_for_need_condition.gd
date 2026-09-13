@tool
extends ConditionLeaf

class_name FundUsableForNeedCondition

class UsableObjectAndNeed:
	var usable_object: UsableObject
	var need: Need

@export var usable_objects_group: StringName
@export var location_blackboard_key: StringName = "location"
@export var object_blackboard_key: StringName = "usable"

@export var searchArea: Area2D:
	set(value):
		assert(searchArea == null, "searchArea is already set")
		searchArea = value
		searchArea.body_entered.connect(_body_entered_area)
		searchArea.body_exited.connect(_body_entered_area)

var objects_in_area: Array[UsableObject] = []

func tick(actor: Node, blackboard: Blackboard) -> int:
	var result = FAILURE
	
	if actor is Node2D:
		var low_needs: Array[Need] = blackboard.get_value("low_needs", [])
		var usable_and_need: UsableObjectAndNeed = find_object_with_best_score(actor, low_needs)

		if usable_and_need != null and usable_and_need.usable_object != null:
			
			blackboard.set_value(location_blackboard_key, usable_and_need.usable_object.global_position)
			blackboard.set_value(object_blackboard_key, usable_and_need.usable_object)
			blackboard.set_value("need", usable_and_need.need)
			result = SUCCESS
		else:
			blackboard.erase_value(location_blackboard_key)
			blackboard.erase_value(object_blackboard_key)
			blackboard.erase_value("need")
			result = FAILED
	
	return result

func find_object_with_best_score(actor: Node2D, needs: Array[Need]) -> UsableObjectAndNeed:
	needs.sort_custom(func (a, b): return a.get_percentage() < b.get_percentage())
	var result: UsableObjectAndNeed = UsableObjectAndNeed.new()
	var max_score = 0

	for index: int in range(objects_in_area.size() - 1, -1, -1):
		var usable: UsableObject = objects_in_area[index]
		if is_instance_valid(usable):
			var distance = (usable.global_position - actor.global_position).length()
			var score = -distance
			for need in needs:
				if usable.can_satisfy(need.name):
					score += ((100 - need.get_percentage())) * 1000
					result.need = need
					break

			if score > max_score:
				result.usable_object = usable
				max_score = score
		else:
			objects_in_area.pop_at(index)

	return result
	
	
	

func _body_entered_area(body: Node2D) -> void:
	if body is UsableObject and body.is_in_group(usable_objects_group):
		objects_in_area.append(body)

func _body_exited_area(body: Node2D) -> void:
	objects_in_area.erase(body)
