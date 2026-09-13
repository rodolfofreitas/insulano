@tool
extends ActionUsingDelta

class_name WatchOceanAction

@export var min_watch_time_seconds: float = 5
@export var max_watch_time_seconds: float = 10

func tick(actor: Node, blackboard: Blackboard) -> int:
	var watched: float = blackboard.get_value("time_watched", 0)
	var watch_goal: float = blackboard.get_value("watch_goal", 0)
	if watch_goal == 0:
		watch_goal = randf_range(min_watch_time_seconds, max_watch_time_seconds)
		blackboard.set_value("watch_goal", watch_goal)
		
	var delta: float = get_delta()
	watched += delta
	blackboard.set_value("time_watched", watched)
	var result: int = RUNNING
	if watched >= watch_goal:
		result = SUCCESS
		blackboard.erase_value("watch_goal")
		blackboard.erase_value("time_watched")
	return result
