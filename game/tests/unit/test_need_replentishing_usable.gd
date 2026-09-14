extends GutTest
## Teste de regressão de NeedReplentishingUsable (bug herdado, ver T-003):
## get_satisfying_needs() rebentava com max_replentish_value == 0 porque chamava
## `.name` sobre elementos de um Array[String].


func test_regression_find_custom_sobre_strings() -> void:
	var usable: NeedReplentishingUsable = autofree(NeedReplentishingUsable.new())
	usable.satisfying_needs = ["hunger", "energy"]
	usable.need_name = "hunger"
	usable.max_replentish_value = 0

	var result: Array = usable.get_satisfying_needs()

	assert_eq(result, ["energy"], "com reposição esgotada, need_name sai da lista")
