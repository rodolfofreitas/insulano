@tool
class_name NeedLowCondition
extends ConditionLeaf
## Sorteia, para cada necessidade do actor, se está baixa o suficiente para tratar agora.
##
## Quanto mais baixa a percentagem, maior a hipótese de entrar em `low_needs`
## (sorteio ponderado, não um limiar fixo). Escreve `low_needs` no blackboard e
## só tem sucesso se pelo menos uma necessidade for escolhida.


## Sorteia as necessidades baixas do actor e escreve `low_needs` no blackboard.
func tick(actor: Node, blackboard: Blackboard) -> int:
	var low_needs: Array[Need] = []
	if actor.has_method("get_needs"):
		var needs: Array[Need] = actor.get_needs()

		for need in needs:
			# Decide se a necessidade deve ser tratada agora, ao acaso, com peso
			# dependente da percentagem: quanto mais baixa, mais provável.
			var decision_var: float = randf_range(0, 100)
			if decision_var >= need.get_percentage():
				low_needs.append(need)

	var result = FAILURE
	if low_needs.size() > 0:
		blackboard.set_value("low_needs", low_needs)
		result = SUCCESS

	return result
