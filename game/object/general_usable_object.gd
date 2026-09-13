class_name GeneralUsableObject
extends UsableObject
## Objecto utilizável que declara, em `satisfying_needs`, quais necessidades trata.
##
## Não faz nada em `use` (herdado de UsableObject); é a base para objectos que
## só precisam de anunciar necessidades, como `NeedReplentishingUsable`.

@export var satisfying_needs: Array[String]


## Devolve os nomes configurados em satisfying_needs.
func get_satisfying_needs() -> Array[String]:
	return satisfying_needs
