class_name RunAction
extends ActionLeaf
## Naufrago corre pela praia. Reduz TEDIO -15 e melhora MOVIMENTO.
## Duracao: 6s. Mais rapido que andar.
## Trigger: TEDIO >= 50.

const RUN_DURATION := 6.0
var _timer: float = 0.0


## Devolve RUNNING enquanto nao chega a RUN_DURATION; SUCCESS e repoe o timer.
func tick(_actor: Node, _blackboard: Blackboard) -> int:
	_timer += get_physics_process_delta_time()
	if _timer >= RUN_DURATION:
		if has_node("/root/NeedsManager"):
			NeedsManager.replenish("TEDIO", 15)
		_timer = 0.0
		return SUCCESS
	return RUNNING
