class_name Guy
extends Character
## O náufrago jogável: um Character que perde fome com o tempo.
##
## A perda de fome só acontece se existir uma necessidade chamada "hunger" em
## `needs` (definida na cena, não aqui); sem ela, apenas pára a animação.

@export var standard_hunger_decrease: float = 1  ## percentagem por segundo


func _physics_process(delta: float) -> void:
	super._physics_process(delta)


func _process(delta: float) -> void:
	var hunger: Need = get_need("hunger")
	if hunger != null:
		hunger.decrease_percent(standard_hunger_decrease * delta)
	else:
		animated_sprite.stop()
