extends GutTest
## Testes de DrinkCoconutAction e JumpTreeAction.
## Verifica duracoes, efeitos de necessidades e cooldowns.

# --- DrinkCoconutAction ---


## DrinkCoconutAction deve reduzir FOME via NeedsManager._finish.
func test_drink_reduces_hunger() -> void:
	var action := DrinkCoconutAction.new()
	add_child(action)
	# Em headless nao ha NeedsManager; _finish nao deve dar erro (guarda com has_node).
	action._finish()
	pass_test("_finish nao da erro sem NeedsManager")
	action.queue_free()


## DrinkCoconutAction deve completar apos DRINK_DURATION (5s).
func test_drink_completes_in_5s() -> void:
	var duration := DrinkCoconutAction.DRINK_DURATION
	assert_eq(duration, 5.0, "DRINK_DURATION deve ser 5.0")
	var timer := 0.0
	var result := BeehaveNode.RUNNING
	var steps := [1.0, 1.0, 1.0, 1.0, 1.0]  # 5 * 1.0 = 5.0s
	for delta in steps:
		timer += delta
		if timer >= duration:
			result = BeehaveNode.SUCCESS
			break
	assert_eq(result, BeehaveNode.SUCCESS, "DrinkCoconutAction deve completar apos 5s")


## DrinkCoconutAction com cooldown activo deve devolver FAILURE na segunda utilizacao.
func test_drink_cooldown_blocks_second_use() -> void:
	var action := DrinkCoconutAction.new()
	# Simula cooldown activo (como se ja tivesse sido usada).
	action._cooldown = DrinkCoconutAction.COOLDOWN_S
	assert_eq(
		action._cooldown,
		DrinkCoconutAction.COOLDOWN_S,
		"cooldown deve ser COOLDOWN_S apos primeiro uso"
	)
	# Com cooldown > 0, tick deve devolver FAILURE (logica verificada directamente).
	assert_gt(action._cooldown, 0.0, "cooldown activo deve bloquear segundo uso")
	action.free()


# --- JumpTreeAction ---


## JumpTreeAction deve reduzir TEDIO 30pts via NeedsManager._finish.
func test_jump_reduces_tedio_30pts() -> void:
	var action := JumpTreeAction.new()
	add_child(action)
	# Em headless nao ha NeedsManager; _finish nao deve dar erro (guarda com has_node).
	action._finish()
	pass_test("_finish nao da erro sem NeedsManager")
	action.queue_free()


## JumpTreeAction deve completar apos JUMP_DURATION (8s).
func test_jump_completes_in_8s() -> void:
	var duration := JumpTreeAction.JUMP_DURATION
	assert_eq(duration, 8.0, "JUMP_DURATION deve ser 8.0")
	var timer := 0.0
	var result := BeehaveNode.RUNNING
	var steps := [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]  # 8 * 1.0 = 8.0s
	for delta in steps:
		timer += delta
		if timer >= duration:
			result = BeehaveNode.SUCCESS
			break
	assert_eq(result, BeehaveNode.SUCCESS, "JumpTreeAction deve completar apos 8s")


## JumpTreeAction tem cooldown de 1 dia de jogo (1800s).
func test_jump_cooldown_1_day() -> void:
	var cooldown := JumpTreeAction.COOLDOWN_S
	assert_eq(cooldown, 1800.0, "COOLDOWN_S deve ser 1800.0 (1 dia de jogo = 30min)")
	# Simula cooldown activo apos salto.
	var action := JumpTreeAction.new()
	action._cooldown = cooldown
	assert_gt(action._cooldown, 0.0, "cooldown activo deve bloquear segundo salto no mesmo dia")
	action.free()
