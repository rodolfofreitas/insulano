class_name Guy
extends Character
## O naufrago jogavel: um Character que perde fome e energia com o tempo.
##
## A perda de fome so acontece se existir uma necessidade chamada "hunger" em
## `needs` (definida na cena, nao aqui); sem ela, apenas para a animacao.
## A energia desce sempre a `standard_energy_decrease` por segundo enquanto
## acordado (independentemente da SleepAction que a recupera mais depressa).

@export var standard_hunger_decrease: float = 1  ## percentagem por segundo
@export var standard_energy_decrease: float = 0.5  ## percentagem por segundo


func _physics_process(delta: float) -> void:
	super._physics_process(delta)


func _process(delta: float) -> void:
	var hunger: Need = get_need("hunger")
	if hunger != null:
		hunger.decrease_percent(standard_hunger_decrease * delta)
	else:
		animated_sprite.stop()
	var energy: Need = get_need("energy")
	if energy != null:
		energy.decrease_percent(standard_energy_decrease * delta)
