class_name HumAction
extends ActionLeaf
## Naufrago cantarola quando TEDIO >= 50.
## Trigger autonomo -- nao precisa de evento externo.

const HUM_DURATION := 8.0
var _timer: float = 0.0


## Devolve RUNNING enquanto nao chega a HUM_DURATION; SUCCESS e repoe o timer a zero.
func tick(_actor: Node, _blackboard: Blackboard) -> int:
	_timer += get_physics_process_delta_time()
	if _timer >= HUM_DURATION:
		_timer = 0.0
		return SUCCESS
	return RUNNING
