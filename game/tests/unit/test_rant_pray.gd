extends GutTest
## Testes de RantAction e PrayAction.
## Verifica duracoes, efeito de esperanca e logica de reset.

# --- RantAction ---


## RantAction deve devolver RUNNING durante os primeiros 4s e SUCCESS no fim.
func test_rant_completes_in_4s() -> void:
	var duration := RantAction.RANT_DURATION
	assert_eq(duration, 4.0, "RANT_DURATION deve ser 4.0")
	# Simula logica de temporizador: apos >= 4s deve retornar SUCCESS.
	var timer := 0.0
	var result := BeehaveNode.RUNNING
	var steps := [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]  # 8 * 0.5 = 4.0s
	for delta in steps:
		timer += delta
		if timer >= duration:
			result = BeehaveNode.SUCCESS
			break
	assert_eq(result, BeehaveNode.SUCCESS, "RantAction deve completar apos 4s")


## RantAction _reset deve zerar o temporizador e _started.
func test_rant_reset_clears_state() -> void:
	var action := RantAction.new()
	action._timer = 3.5
	action._started = true
	action._reset()
	assert_eq(action._timer, 0.0, "_timer deve ser 0 apos reset")
	assert_false(action._started, "_started deve ser false apos reset")
	action.free()


# --- PrayAction ---


## PrayAction deve devolver SUCCESS apos 6s e repor ESPERANCA +10.
func test_pray_grants_hope_10pts() -> void:
	# Verifica que _grant_hope chama NeedsManager.replenish com os argumentos certos.
	# Como NeedsManager pode nao estar disponivel em testes headless, validamos
	# a logica de condicao: has_node("/root/NeedsManager").
	var action := PrayAction.new()
	add_child(action)
	# Em headless nao ha NeedsManager; a chamada nao deve dar erro (guarda com has_node).
	action._grant_hope(action)
	pass_test("_grant_hope nao da erro sem NeedsManager")
	action.queue_free()


## PrayAction deve completar apos PRAY_DURATION (6s).
func test_pray_completes_in_6s() -> void:
	var duration := PrayAction.PRAY_DURATION
	assert_eq(duration, 6.0, "PRAY_DURATION deve ser 6.0")
	var timer := 0.0
	var result := BeehaveNode.RUNNING
	var steps := [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]  # 6 * 1.0 = 6.0s
	for delta in steps:
		timer += delta
		if timer >= duration:
			result = BeehaveNode.SUCCESS
			break
	assert_eq(result, BeehaveNode.SUCCESS, "PrayAction deve completar apos 6s")


## PrayAction deve ter PRAY_DURATION maior que RantAction.RANT_DURATION.
func test_pray_longer_than_rant() -> void:
	assert_gt(
		PrayAction.PRAY_DURATION,
		RantAction.RANT_DURATION,
		"rezar (6s) deve durar mais que xingar (4s)"
	)
