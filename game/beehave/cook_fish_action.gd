class_name CookFishAction
extends ActionLeaf
## Assa o peixe na fogueira e come com satisfacao.
## Requer blackboard[has_fish]=true e has_campfire=true.
## Repoe HUNGER -60pts ao terminar via need hunger.increase_percent().

const COOK_DURATION := 8.0

var _timer: float = 0.0
var _cooking: bool = false


## Aguarda COOK_DURATION frames com fogueira activa e depois come o peixe.
func tick(actor: Node, blackboard: Blackboard) -> int:
	if not blackboard.get_value("has_fish", false):
		return FAILURE
	if not blackboard.get_value("has_campfire", false):
		return FAILURE
	_timer += get_physics_process_delta_time()
	if not _cooking:
		_cooking = true
	if _timer >= COOK_DURATION:
		_finish_cooking(actor, blackboard)
		return SUCCESS
	return RUNNING


## Consome o peixe, repoe 60pts de fome e regista na sessao.
func _finish_cooking(actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value("has_fish", false)
	var character := actor as Character
	if character != null:
		var hunger: Need = character.get_need("hunger")
		if hunger != null:
			hunger.increase_percent(60.0)
	SessionData.record_fish_caught()
