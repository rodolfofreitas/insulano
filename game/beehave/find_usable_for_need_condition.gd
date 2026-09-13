@tool
class_name FundUsableForNeedCondition
extends ConditionLeaf
## Encontra, entre os objectos utilizáveis dentro de `search_area`, o que melhor
## satisfaz a necessidade mais baixa do actor, por pontuação de distância e
## percentagem da necessidade.
##
## Escreve `location`, `object_blackboard_key` e `need` no blackboard quando
## encontra um par válido; limpa-os quando não encontra nenhum.
##
## Nota (não corrigida aqui, fora do âmbito da T-002, ver T-003): o nome da
## classe tem um erro tipográfico herdado ("Fund" em vez de "Find"); o ramo
## de falha usa a constante `FAILED` (erro global, vale 1) em vez de `FAILURE`,
## que só funciona porque calham a ter o mesmo valor (ver AGENTS.md, secção 10);
## e `search_area.body_exited` está ligado a `_body_entered_area` (linha
## abaixo), não a `_body_exited_area`: os objectos nunca saem de
## `objects_in_area`, mesmo depois de saírem fisicamente da área.


class UsableObjectAndNeed:
	var usable_object: UsableObject
	var need: Need


@export var usable_objects_group: StringName
@export var location_blackboard_key: StringName = "location"
@export var object_blackboard_key: StringName = "usable"

@export var search_area: Area2D:
	set(value):
		assert(search_area == null, "search_area is already set")
		search_area = value
		search_area.body_entered.connect(_body_entered_area)
		search_area.body_exited.connect(_body_entered_area)

var objects_in_area: Array[UsableObject] = []


## Escolhe, entre os objectos em `search_area`, o par objecto/necessidade com melhor pontuação.
func tick(actor: Node, blackboard: Blackboard) -> int:
	var result = FAILURE

	if actor is Node2D:
		var low_needs: Array[Need] = blackboard.get_value("low_needs", [])
		var usable_and_need: UsableObjectAndNeed = find_object_with_best_score(actor, low_needs)

		if usable_and_need != null and usable_and_need.usable_object != null:
			var usable_object: UsableObject = usable_and_need.usable_object
			blackboard.set_value(location_blackboard_key, usable_object.global_position)
			blackboard.set_value(object_blackboard_key, usable_object)
			blackboard.set_value("need", usable_and_need.need)
			result = SUCCESS
		else:
			blackboard.erase_value(location_blackboard_key)
			blackboard.erase_value(object_blackboard_key)
			blackboard.erase_value("need")
			result = FAILED

	return result


## Percorre `objects_in_area` e devolve o par (objecto, necessidade) com melhor pontuação.
func find_object_with_best_score(actor: Node2D, needs: Array[Need]) -> UsableObjectAndNeed:
	needs.sort_custom(func(a, b): return a.get_percentage() < b.get_percentage())
	var result: UsableObjectAndNeed = UsableObjectAndNeed.new()
	var max_score = 0

	for index: int in range(objects_in_area.size() - 1, -1, -1):
		var usable: UsableObject = objects_in_area[index]
		if is_instance_valid(usable):
			var distance = (usable.global_position - actor.global_position).length()
			var score = -distance
			for need in needs:
				if usable.can_satisfy(need.name):
					score += (100 - need.get_percentage()) * 1000
					result.need = need
					break

			if score > max_score:
				result.usable_object = usable
				max_score = score
		else:
			objects_in_area.pop_at(index)

	return result


func _body_entered_area(body: Node2D) -> void:
	if body is UsableObject and body.is_in_group(usable_objects_group):
		objects_in_area.append(body)


func _body_exited_area(body: Node2D) -> void:
	objects_in_area.erase(body)
