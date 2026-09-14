extends GutTest
## Testes de regressão de FundUsableForNeedCondition (dois dos bugs herdados
## documentados no ficheiro, corrigidos na T-003). O erro tipográfico no nome da
## classe ("Fund" em vez de "Find") não é corrigido aqui, fora do âmbito da T-003.

var _condition: FundUsableForNeedCondition
var _search_area: Area2D
var _blackboard: Blackboard
var _actor: Node2D


func before_each() -> void:
	_search_area = Area2D.new()
	add_child_autofree(_search_area)

	_condition = FundUsableForNeedCondition.new()
	_condition.usable_objects_group = "usable_objects"
	_condition.search_area = _search_area
	add_child_autofree(_condition)

	_blackboard = Blackboard.new()
	add_child_autofree(_blackboard)

	_actor = Node2D.new()
	add_child_autofree(_actor)


func test_regression_sinal_trocado() -> void:
	var usable := UsableObject.new()
	usable.add_to_group("usable_objects")
	add_child_autofree(usable)

	_search_area.body_entered.emit(usable)
	assert_eq(_condition.objects_in_area.size(), 1, "body_entered devia adicionar o objecto")

	_search_area.body_exited.emit(usable)
	assert_eq(
		_condition.objects_in_area.size(),
		0,
		"body_exited devia remover o objecto (antes da correcção, duplicava-o)"
	)


func test_regression_constante_errada() -> void:
	# Guarda de comportamento: em Beehave, ConditionLeaf.FAILURE vale 1, o mesmo
	# valor numérico da constante global FAILED do Godot (AGENTS.md secção 10).
	# Por essa coincidência, esta asserção sozinha passa mesmo com `result = FAILED`
	# na fonte: não distingue as duas constantes. Por isso complementa-se abaixo
	# com uma guarda directa à fonte, que é a única forma de apanhar o bug real
	# (usar o nome errado da constante).
	var empty_needs: Array[Need] = []
	_blackboard.set_value("low_needs", empty_needs)

	var result: int = _condition.tick(_actor, _blackboard)
	assert_eq(result, _condition.FAILURE, "sem objectos na área, tick tem de devolver FAILURE")


func test_regression_constante_errada_guarda_de_fonte() -> void:
	var source := FileAccess.get_file_as_string("res://beehave/find_usable_for_need_condition.gd")
	assert_false(source.is_empty(), "não consegui ler a fonte de find_usable_for_need_condition.gd")
	assert_false(
		source.contains("FAILED"),
		(
			"tick() deve usar a constante FAILURE do Beehave, nunca a global FAILED "
			+ "(mesmo valor numérico, ver AGENTS.md secção 10)"
		)
	)
