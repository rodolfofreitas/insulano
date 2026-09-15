class_name SwimAction
extends ActionLeaf
## Naufrago nada no oceano. Melhora TEDIO -20 e CALOR -15 (se existir).
## Duracao: 10s. CPUParticles2D splash ao entrar.
## Trigger: TEDIO >= 60 ou hora >= 11h e <= 16h (calor do dia).

const SWIM_DURATION := 10.0
var _timer: float = 0.0


## Devolve RUNNING enquanto nao chega a SWIM_DURATION; SUCCESS e chama _finish.
func tick(actor: Node, _blackboard: Blackboard) -> int:
	_timer += get_physics_process_delta_time()
	if _timer >= SWIM_DURATION:
		_finish(actor)
		_timer = 0.0
		return SUCCESS
	return RUNNING


## Aplica efeitos ao completar: repoe TEDIO 20pts e CALOR 15pts (se existir).
func _finish(_actor: Node) -> void:
	if has_node("/root/NeedsManager"):
		NeedsManager.replenish("TEDIO", 20)
		if NeedsManager.has_need("CALOR"):
			NeedsManager.replenish("CALOR", 15)
