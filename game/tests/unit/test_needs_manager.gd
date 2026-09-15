extends GutTest
## Testes unitarios do NeedsManager: decay passivo, interaccoes entre necessidades e limiares.
## Instancia o script directamente (via load) para evitar conflito com o autoload singleton.

const NeedsManagerScript = preload("res://world/needs_manager.gd")

var manager: Node


func _make_manager() -> Node:
	var m: Node = NeedsManagerScript.new()
	# Carregar config a partir do ficheiro real.
	m._load_config()
	# Inicializar estado dos limiares.
	m._init_threshold_state()
	return m


func before_each() -> void:
	manager = _make_manager()


func after_each() -> void:
	if manager:
		manager.free()


## SOLIDAO deve subir passivamente ao longo do tempo sem qualquer interaccao.
func test_solitude_increases_passively() -> void:
	var initial: float = manager.get_value("SOLIDAO")
	# Simular 10 segundos de tempo idle.
	manager._apply_passive_rates(10.0)
	manager._clamp_values()
	var after: float = manager.get_value("SOLIDAO")
	assert_gt(after, initial, "SOLIDAO deve subir apos 10s passivos")


## FOME alta deve reduzir a taxa de crescimento do TEDIO.
func test_boredom_slows_when_hungry() -> void:
	var initial_tedio: float = manager.get_value("TEDIO")
	# Simular sem fome.
	manager.set_hunger_level(0.0)
	manager._apply_passive_rates(10.0)
	var tedio_sem_fome: float = manager.get_value("TEDIO")
	var delta_sem_fome: float = tedio_sem_fome - initial_tedio

	# Repor valor inicial.
	manager.set_value("TEDIO", initial_tedio)

	# Simular com fome alta.
	manager.set_hunger_level(90.0)
	manager._apply_passive_rates(10.0)
	var tedio_com_fome: float = manager.get_value("TEDIO")
	var delta_com_fome: float = tedio_com_fome - initial_tedio

	assert_lt(delta_com_fome, delta_sem_fome, "TEDIO deve subir mais devagar quando FOME > 80")


## Com FOME>80 e SOLIDAO>70, ESPERANCA deve descer mais rapido do que o decay passivo sozinho.
func test_hope_drains_when_all_needs_high() -> void:
	var initial_esperanca: float = manager.get_value("ESPERANCA")

	# Simular sem as condicoes de interaccao.
	manager.set_hunger_level(0.0)
	manager.set_value("SOLIDAO", 40.0)
	manager._apply_passive_rates(10.0)
	manager._apply_interactions(10.0)
	manager._clamp_values()
	var esperanca_sem_interacao: float = manager.get_value("ESPERANCA")
	var delta_sem: float = initial_esperanca - esperanca_sem_interacao

	# Repor.
	manager.set_value("ESPERANCA", initial_esperanca)

	# Simular com FOME alta e SOLIDAO alta.
	manager.set_hunger_level(85.0)
	manager.set_value("SOLIDAO", 75.0)
	manager._apply_passive_rates(10.0)
	manager._apply_interactions(10.0)
	manager._clamp_values()
	var esperanca_com_interacao: float = manager.get_value("ESPERANCA")
	var delta_com: float = initial_esperanca - esperanca_com_interacao

	assert_gt(delta_com, delta_sem, "ESPERANCA deve descer mais com FOME>80 e SOLIDAO>70")


## get_snapshot deve incluir todas as necessidades com campo 'value'.
func test_snapshot_includes_all_needs() -> void:
	var snap: Dictionary = manager.get_snapshot()
	assert_true(snap.has("SOLIDAO"), "Snapshot deve conter SOLIDAO")
	assert_true(snap.has("TEDIO"), "Snapshot deve conter TEDIO")
	assert_true(snap.has("ESPERANCA"), "Snapshot deve conter ESPERANCA")
	assert_true(snap.has("FOME"), "Snapshot deve conter FOME")
	for key: String in snap:
		assert_true(snap[key].has("value"), "Cada entrada deve ter campo 'value'")
