class_name DrinkCoconutAction
extends ActionLeaf
## Naufrago parte um coco e bebe a agua. SEDE -30pts, FOME -10pts.
## Cooldown: 4h de jogo (14400s reais / acelerado).
## Trigger: SEDE >= 60 (quando SEDE existir) ou TEDIO >= 40.

const DRINK_DURATION := 5.0
const COOLDOWN_S := 240.0  # 4h de jogo a 30min/dia = 4*30/24*60 = ~7.5min reais
var _timer: float = 0.0
var _cooldown: float = 0.0


## Avanca o temporizador com cooldown; ao atingir DRINK_DURATION (5s) chama
## _finish e devolve SUCCESS. Durante cooldown devolve FAILURE.
func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if _cooldown > 0.0:
		_cooldown -= get_physics_process_delta_time()
		return FAILURE
	_timer += get_physics_process_delta_time()
	if _timer >= DRINK_DURATION:
		_finish()
		_timer = 0.0
		_cooldown = COOLDOWN_S
		return SUCCESS
	return RUNNING


func _finish() -> void:
	if has_node("/root/NeedsManager"):
		NeedsManager.replenish("FOME", 10)
		# SEDE quando existir (Fase 8)
