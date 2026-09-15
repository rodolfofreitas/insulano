class_name PrayAction
extends ActionLeaf
## Naufrago reza ou medita. Melhora ESPERANCA +10.
## Trigger: ESPERANCA <= 40 ou hora >= 21 (noite).

const PRAY_DURATION := 6.0
var _timer: float = 0.0


## Avanca o temporizador; ao atingir PRAY_DURATION (6s) repoe ESPERANCA +10
## e devolve SUCCESS; enquanto decorre devolve RUNNING.
func tick(_actor: Node, _blackboard: Blackboard) -> int:
	_timer += get_physics_process_delta_time()
	if _timer >= PRAY_DURATION:
		_grant_hope(_actor)
		_timer = 0.0
		return SUCCESS
	return RUNNING


func _grant_hope(_actor: Node) -> void:
	if has_node("/root/NeedsManager"):
		NeedsManager.replenish("ESPERANCA", 10)
