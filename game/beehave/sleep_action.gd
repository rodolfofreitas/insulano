@tool
class_name SleepAction
extends ActionUsingDelta
## Faz o personagem dormir: energia recupera, velocidade zero.
## RUNNING enquanto dorme; SUCCESS quando energia = 100 e nao e noite.

@export var recover_rate: float = 2.0


## Para o personagem, recupera energia e devolve RUNNING enquanto precisa dormir.
func tick(actor: Node, blackboard: Blackboard) -> int:
	var character := actor as Character
	if character == null:
		return FAILURE
	blackboard.set_value("current_action", "dormir")
	# parar o personagem
	character.velocity = Vector2.ZERO
	# recuperar energia
	var energy: Need = character.get_need("energy")
	if energy:
		energy.increase_percent(recover_rate * get_delta())
	# continuar a dormir se energia < 100 ou se e noite
	var is_night := false
	if has_node("/root/Clock"):
		is_night = Clock.period() in ["noite", "madrugada"]
	if (energy and energy.get_percentage() < 100.0) or is_night:
		return RUNNING
	return SUCCESS
