class_name DanceAction
extends ActionLeaf
## Naufrago danca de alegria. Trigger: ESPERANCA >= 80.
## Duracao: 8s. SOLIDAO -10, TEDIO -20.

const DANCE_DURATION := 8.0
var _timer: float = 0.0


## Avanca o temporizador; ao atingir DANCE_DURATION (8s) repoe necessidades
## e devolve SUCCESS; enquanto decorre devolve RUNNING.
func tick(_actor: Node, _blackboard: Blackboard) -> int:
	_timer += get_physics_process_delta_time()
	if _timer >= DANCE_DURATION:
		_finish()
		_timer = 0.0
		return SUCCESS
	return RUNNING


func _finish() -> void:
	if has_node("/root/NeedsManager"):
		NeedsManager.replenish("SOLIDAO", 10)
		NeedsManager.replenish("TEDIO", 20)
