class_name ActionUsingDelta
extends ActionLeaf
## Base para acções do Beehave que precisam do delta do frame corrente.
##
## Escolhe entre o delta do `_physics_process` e o do `_process` conforme
## `use_physics_process_delta`, para as acções que herdam dela (fishing_action.gd,
## use_usable_action.gd, watch_ocean_action.gd) não repetirem a escolha. Não faz
## tick nem devolve estado da árvore.

@export var use_physics_process_delta: bool = false


## Devolve o delta do frame: físico se `use_physics_process_delta`, senão o normal.
func get_delta() -> float:
	var result = 0
	if use_physics_process_delta:
		result = get_physics_process_delta_time()
	else:
		result = get_process_delta_time()
	return result
