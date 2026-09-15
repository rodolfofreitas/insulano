class_name JumpTreeAction
extends ActionLeaf
## Naufrago trepa a palmeira e salta para o mar. TEDIO -30pts.
## Duracao: 8s. RARO -- 1x por dia de jogo.
## Trigger: TEDIO >= 70.

const JUMP_DURATION := 8.0
const COOLDOWN_S := 1800.0  # 1 dia de jogo (30min)
var _timer: float = 0.0
var _cooldown: float = 0.0


## Avanca o temporizador com cooldown; ao atingir JUMP_DURATION (8s) chama
## _finish e devolve SUCCESS. Durante cooldown devolve FAILURE.
func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if _cooldown > 0.0:
		_cooldown -= get_physics_process_delta_time()
		return FAILURE
	_timer += get_physics_process_delta_time()
	if _timer >= JUMP_DURATION:
		_finish()
		_timer = 0.0
		_cooldown = COOLDOWN_S
		return SUCCESS
	return RUNNING


func _finish() -> void:
	if has_node("/root/NeedsManager"):
		NeedsManager.replenish("TEDIO", 30)
		NeedsManager.replenish("ESPERANCA", 5)
