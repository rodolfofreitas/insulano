extends GutTest
## Testes de integracao para CampfireObject (T-119): fogueira inicia apagada,
## ignite() emite sinal lit, extinguish() para particulas, e dois ignite()
## consecutivos so emitem lit uma vez.

var _campfire: CampfireObject


func before_each() -> void:
	_campfire = CampfireObject.new()
	add_child(_campfire)
	await get_tree().process_frame


func after_each() -> void:
	_campfire.queue_free()


## test_campfire_starts_extinguished: is_burning() == false no inicio
func test_campfire_starts_extinguished() -> void:
	assert_false(_campfire.is_burning(), "Fogueira deve comecar apagada")


## test_ignite_emits_lit_signal: ignite() emite sinal lit
func test_ignite_emits_lit_signal() -> void:
	watch_signals(_campfire)
	_campfire.ignite()
	assert_signal_emitted(_campfire, "lit", "ignite() deve emitir sinal lit")


## test_extinguish_stops_particles: apos extinguish(), _flames.emitting == false
func test_extinguish_stops_particles() -> void:
	_campfire.ignite()
	await get_tree().process_frame
	_campfire.extinguish()
	await get_tree().process_frame
	var flames := _campfire.get_child(0) as CPUParticles2D
	assert_not_null(flames, "Fogueira deve ter CPUParticles2D filho")
	assert_false(flames.emitting, "chamas devem parar apos extinguish()")


## test_ignite_twice_no_duplicate: dois ignite() so emitem lit uma vez
func test_ignite_twice_no_duplicate() -> void:
	watch_signals(_campfire)
	_campfire.ignite()
	_campfire.ignite()
	assert_signal_emit_count(
		_campfire, "lit", 1, "lit deve ser emitido apenas uma vez com dois ignite()"
	)
