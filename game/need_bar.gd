class_name NeedBar
extends ProgressBar
## Barra de progresso que reflecte uma necessidade (`need_name`) de `target`.
##
## Puramente de leitura: lê `Need.max_value`/`current_value` a cada frame e
## actualiza a `ProgressBar`; nunca altera a necessidade.

@export var target: Character
@export var need_name: String


## Actualiza os limites e o valor da barra a partir da necessidade lida em target.
func _process(_delta: float) -> void:
	var need: Need = target.get_need(need_name)
	if need != null:
		max_value = need.max_value
		value = need.current_value
