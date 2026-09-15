class_name ExerciseAction
extends ActionLeaf
## Naufrago faz flexoes ou abdominais. TEDIO -20, ENERGIA +10.
## Duracao: 10s. Trigger: TEDIO >= 55.

const EXERCISE_DURATION := 10.0
var _timer: float = 0.0


## Avanca o temporizador; ao atingir EXERCISE_DURATION (10s) repoe necessidades
## e devolve SUCCESS; enquanto decorre devolve RUNNING.
func tick(_actor: Node, _blackboard: Blackboard) -> int:
	_timer += get_physics_process_delta_time()
	if _timer >= EXERCISE_DURATION:
		_finish()
		_timer = 0.0
		return SUCCESS
	return RUNNING


func _finish() -> void:
	if has_node("/root/NeedsManager"):
		NeedsManager.replenish("TEDIO", 20)
