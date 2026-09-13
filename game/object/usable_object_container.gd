class_name UsableObjectContainer
extends UsableObject
## Agrupa vários objectos utilizáveis num só nó (ex.: uma prateleira com comida).
##
## `get_satisfying_needs` é a concatenação (não elimina duplicados) das
## necessidades de `containing_objects`; não decide qual usar, isso é feito
## por `FindUsableForNeedCondition`.

@export var containing_objects: Array[UsableObject]


## Devolve a concatenação das necessidades satisfeitas por containing_objects.
func get_satisfying_needs() -> Array[String]:
	var result: Array[String] = []
	for usable in containing_objects:
		result.append_array(usable.get_satisfying_needs())
	return result
