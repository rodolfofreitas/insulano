extends GutTest
## Testes de caracterização de [Need], o recurso de necessidade herdado da base.
##
## Fixam o comportamento actual antes de qualquer alteração: se um destes testes
## falhar depois de uma mudança, a mudança alterou o contrato de Need.


func _make_need(max_value: int, current_value: float) -> Need:
	var need := Need.new()
	need.name = "hunger"
	need.max_value = max_value
	need.current_value = current_value
	return need


func test_percentage_is_relative_to_max_value() -> void:
	assert_eq(_make_need(200, 50.0).get_percentage(), 25.0)


func test_decrease_percent_never_goes_below_zero() -> void:
	var need := _make_need(100, 30.0)
	need.decrease_percent(80.0)
	assert_eq(need.current_value, 0.0)


func test_increase_percent_never_goes_above_hundred() -> void:
	var need := _make_need(100, 90.0)
	need.increase_percent(50.0)
	assert_eq(need.get_percentage(), 100.0)


func test_increase_returns_only_the_amount_used() -> void:
	var need := _make_need(100, 90.0)
	assert_eq(need.increase(25.0), 10.0)
	assert_eq(need.current_value, 100.0)


func test_decrease_by_value_clamps_at_zero() -> void:
	var need := _make_need(100, 5.0)
	need.decrease(10.0)
	assert_eq(need.current_value, 0.0)
