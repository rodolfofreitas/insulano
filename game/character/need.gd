class_name Need
extends Resource
## Um recurso de necessidade (fome, energia, ...) com valor actual e máximo.
##
## `Character.needs` guarda um array destes; a behavior tree lê a percentagem
## para decidir o que fazer e as acções (ex. `NeedReplentishingUsable.use`)
## chamam `increase`/`decrease` para a alterar. Não sabe nada de animação nem
## de blackboard.

@export var name: String
@export var max_value: int
@export var current_value: float


## Devolve o valor actual como percentagem de `max_value` (0 a 100).
func get_percentage() -> float:
	return float(current_value) / float(max_value) * 100


## Define o valor actual a partir de uma percentagem de `max_value`.
func set_percentage(value: float) -> void:
	current_value = max_value * (value / 100.0)


## Diminui o valor actual em value, com o mínimo de 0.
func decrease(value: float) -> void:
	if current_value > 0:
		current_value = max(0, current_value - value)


## Diminui a percentagem actual em value (100% é sempre max_value).
func decrease_percent(value: float) -> void:
	var current = get_percentage()
	var new = max(0, current - value)
	set_percentage(new)


## Aumenta a percentagem actual em value (100% é sempre max_value).
func increase_percent(value: float) -> void:
	var current = get_percentage()
	var new = min(100, current + value)
	set_percentage(new)


## Aumenta o valor actual em value, até ao máximo de max_value.
## Devolve a quantidade de value efectivamente usada para aumentar current_value.
func increase(value: float) -> float:
	var value_used = 0
	if current_value < max_value:
		value_used = min(max_value - current_value, value)
		current_value += value_used
	return value_used
