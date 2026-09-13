@tool
extends ConditionLeaf

class_name NeedLowCondition

func tick(actor: Node, blackboard: Blackboard) -> int:
	var low_needs: Array[Need] = []
	if actor.has_method("get_needs"):
		var needs: Array[Need] = actor.get_needs()
		
		for need in needs:
			# Decide if the need should be taken care of at random, with weight dependent on percentage
			var decision_var: float = randf_range(0, 100)
			if decision_var >= need.get_percentage():
				low_needs.append(need)

	var result = FAILURE
	if low_needs.size() > 0:
		blackboard.set_value("low_needs", low_needs)
		result = SUCCESS

	return result
	
