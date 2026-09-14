extends GutTest
## Teste de regressão de fishing_spot.gd (bug herdado, ver T-003): o círculo
## vermelho de debug aparecia sempre, também fora do editor (jogo, protector de
## ecrã, screenshot).


func test_regression_circulos_de_debug() -> void:
	var script: Script = load("res://fishing_spot.gd")
	var spot: Node2D = script.new()
	add_child_autofree(spot)

	assert_false(
		spot.should_draw_debug_circle(), "fora do editor o círculo de debug não deve aparecer"
	)


func test_regression_circulos_de_debug_guarda_de_fonte() -> void:
	# should_draw_debug_circle() sozinho é verdade em headless independentemente
	# do que _draw() faz com ela; esta guarda lê a fonte para confirmar que a
	# chamada a draw_circle está de facto DENTRO de um if que usa esse método
	# (ou Engine.is_editor_hint() directo), não só declarada e ignorada.
	var source := FileAccess.get_file_as_string("res://fishing_spot.gd")
	var draw_start := source.find("func _draw(")
	assert_true(draw_start != -1, "esperava encontrar func _draw() na fonte")

	var next_func := source.find("\nfunc ", draw_start + 1)
	var draw_body := (
		source.substr(draw_start, next_func - draw_start)
		if next_func != -1
		else source.substr(draw_start)
	)

	var lines := draw_body.split("\n")
	var guard_line_index := -1
	for i in range(lines.size()):
		var trimmed := lines[i].strip_edges()
		if (
			trimmed.begins_with("if should_draw_debug_circle():")
			or trimmed.begins_with("if Engine.is_editor_hint():")
		):
			guard_line_index = i
			break

	assert_true(
		guard_line_index != -1,
		"_draw() tem de ter 'if should_draw_debug_circle():' ou 'if Engine.is_editor_hint():'"
	)
	if guard_line_index == -1:
		return

	var guard_line: String = lines[guard_line_index]
	var guard_indent := guard_line.length() - guard_line.strip_edges(true, false).length()
	var next_line: String = (
		lines[guard_line_index + 1] if guard_line_index + 1 < lines.size() else ""
	)
	var next_indent := next_line.length() - next_line.strip_edges(true, false).length()

	assert_true(
		next_line.strip_edges().begins_with("draw_circle") and next_indent > guard_indent,
		"draw_circle tem de estar indentado dentro do guarda, nunca incondicional (ver T-003)"
	)

	# Guarda extra: um draw_circle solto à MESMA indentação do próprio `if`
	# (ou seja, ao nível do corpo de _draw(), fora do guarda) passaria a
	# verificação acima na mesma, porque essa só olha para a linha a seguir
	# ao `if`. Aqui varremos o corpo inteiro à procura desse caso.
	for i in range(lines.size()):
		if i == guard_line_index:
			continue
		var line: String = lines[i]
		var trimmed_line := line.strip_edges()
		if trimmed_line.is_empty():
			continue
		var indent := line.length() - line.strip_edges(true, false).length()
		assert_false(
			indent == guard_indent and trimmed_line.begins_with("draw_circle"),
			"draw_circle não pode estar solto ao nível do `if`, tem de estar sempre dentro dele"
		)
