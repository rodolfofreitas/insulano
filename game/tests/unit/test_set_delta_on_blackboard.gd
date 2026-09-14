extends GutTest
## Teste de regressão de SetDeltaOnBlackboardAction (bug herdado, ver T-003):
## a acção imprimia "delta = ..." a cada tick, inundando os logs
## (agent_docs/code_patterns.md:157). Testado por leitura do ficheiro fonte porque o
## GUT não intercepta stdout; a prova complementar é o grep a reports/boot.log.


func test_regression_print_a_cada_tick() -> void:
	var source := FileAccess.get_file_as_string("res://beehave/set_delta_on_blackboard.gd")
	assert_false(source.is_empty(), "não consegui ler a fonte de set_delta_on_blackboard.gd")
	assert_false(source.contains("print("), "tick() não deve imprimir a cada frame")
