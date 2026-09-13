class_name UsableObject
extends Node2D
## Base de qualquer objecto que a behavior tree pode usar para satisfazer necessidades.
##
## Uma classe base sem comportamento próprio: `GeneralUsableObject`,
## `NeedReplentishingUsable` e `UsableObjectContainer` é que implementam
## `get_satisfying_needs` e `use` de facto.


## Devolve os nomes das necessidades que este objecto pode satisfazer.
func get_satisfying_needs() -> Array[String]:
	return []


## Verifica se este objecto satisfaz a necessidade com o nome dado.
func can_satisfy(need_name: String) -> bool:
	return get_satisfying_needs().any(func(n): return n == need_name)


## Aplica o efeito do objecto no personagem; a base não faz nada.
func use(_character: Character, _delta: float) -> void:
	pass
