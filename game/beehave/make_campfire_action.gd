class_name MakeCampfireAction
extends ActionLeaf
## Recolhe lenha e acende a fogueira.
## blackboard[has_campfire] = true quando termina.

enum Phase {
	GATHER_WOOD,
	LIGHT_FIRE,
	DONE,
}

const GATHER_DURATION := 3.0
const LIGHT_DURATION := 2.0
const CAMPFIRE_SCENE := preload("res://object/campfire_object.gd")

var _phase: Phase = Phase.GATHER_WOOD
var _timer: float = 0.0


## Executa as sub-fases de recolha de lenha e acendimento da fogueira.
func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("has_campfire", false):
		return SUCCESS
	_timer += get_physics_process_delta_time()
	match _phase:
		Phase.GATHER_WOOD:
			if _timer >= GATHER_DURATION:
				_timer = 0.0
				_phase = Phase.LIGHT_FIRE
		Phase.LIGHT_FIRE:
			if _timer >= LIGHT_DURATION:
				_spawn_campfire(actor, blackboard)
				_phase = Phase.DONE
				return SUCCESS
	return RUNNING


## Instancia um CampfireObject junto ao actor, accende-o e actualiza o blackboard.
func _spawn_campfire(actor: Node, blackboard: Blackboard) -> void:
	var campfire := Node2D.new()
	campfire.set_script(CAMPFIRE_SCENE)
	campfire.position = actor.position + Vector2(30, 0)
	actor.get_parent().add_child(campfire)
	campfire.ignite()
	blackboard.set_value("has_campfire", true)
	blackboard.set_value("campfire_node", campfire)
