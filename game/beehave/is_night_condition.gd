@tool
class_name IsNightCondition
extends ConditionLeaf
## SUCCESS quando Clock.period() e 'noite' ou 'madrugada'.


## Devolve SUCCESS se Clock.period() e 'noite' ou 'madrugada'; FAILURE caso contrario.
func tick(_actor: Node, _blackboard: Blackboard) -> int:
	var period: String = ""
	if has_node("/root/Clock"):
		period = Clock.period()
	if period in ["noite", "madrugada"]:
		return SUCCESS
	return FAILURE
