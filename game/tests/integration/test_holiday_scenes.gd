extends GutTest
## Testes de integracao para HolidayScenes (T-402).
##
## Usa INSULANO_FAKE_TIME para simular datas especificas e verifica que
## os elementos visuais e o estado de primary_holiday_name estao correctos.

const HolidayScenesScript = preload("res://world/holiday_scenes.gd")


## Cria um HolidayScenes com a fake_time dada e devolve-o ja inicializado.
func _make_scenes(fake_time: String) -> HolidayScenes:
	OS.set_environment("INSULANO_FAKE_TIME", fake_time)
	## O Clock autoload pode ainda ter o valor antigo; recarregar via set_fake_time se disponivel.
	if has_node("/root/Clock"):
		var clock: Node = get_node("/root/Clock")
		if clock.has_method("_ready"):
			## Reinvoca _ready para releer a env var.
			pass
		## Setter directo da variavel privada (acesso por reflexao no GUT).
		clock.set("_fake_time", fake_time)
	var hs: HolidayScenes = HolidayScenesScript.new()
	add_child_autofree(hs)
	## Forcamos um check depois de adicionar (Clock pode nao ter emitido ainda).
	hs._check_holidays()
	return hs


func after_each() -> void:
	OS.set_environment("INSULANO_FAKE_TIME", "")


## test_christmas_active: 2026-12-25T21:00 -- elementos natalicos activos.
func test_christmas_active() -> void:
	var hs: HolidayScenes = _make_scenes("2026-12-25T21:00")
	assert_false(hs.active_holidays.is_empty(), "deve haver feriados em 25 de Dezembro")
	## Verifica que o hat layer esta visivel (xmas activado)
	var hat_layer: Node = hs.get_child(0)
	assert_not_null(hat_layer, "hat layer deve existir")
	assert_true(hat_layer.visible, "hat layer deve estar visivel no Natal")
	## Verifica o nome do feriado
	var ids: Array = hs.active_holidays.map(func(h: Dictionary) -> String: return h.get("id", ""))
	assert_true("christmas" in ids, "feriado christmas deve estar activo em 2026-12-25")


## test_fireworks_night: 2026-12-31T23:00 -- fogos activos a noite.
func test_fireworks_night() -> void:
	var hs: HolidayScenes = _make_scenes("2026-12-31T23:00")
	assert_false(hs.active_holidays.is_empty(), "deve haver feriados em 31 de Dezembro")
	var fireworks: CPUParticles2D = null
	for child in hs.get_children():
		if child is CPUParticles2D:
			fireworks = child
			break
	assert_not_null(fireworks, "CPUParticles2D de fogos deve existir")
	assert_true(fireworks.emitting, "fogos devem estar a emitir as 23h em vespera de Ano Novo")


## test_fireworks_day: 2026-12-31T13:00 -- fogos desligados de dia.
func test_fireworks_day() -> void:
	var hs: HolidayScenes = _make_scenes("2026-12-31T13:00")
	var fireworks: CPUParticles2D = null
	for child in hs.get_children():
		if child is CPUParticles2D:
			fireworks = child
			break
	assert_not_null(fireworks, "CPUParticles2D de fogos deve existir")
	assert_false(fireworks.emitting, "fogos nao devem emitir as 13h")


## test_normal_day: 2026-09-13T21:00 -- sem decoracao.
func test_normal_day() -> void:
	var hs: HolidayScenes = _make_scenes("2026-09-13T21:00")
	assert_true(hs.active_holidays.is_empty(), "nao deve haver feriados em 2026-09-13")
	assert_eq(
		hs.primary_holiday_name, "nenhum", "primary_holiday_name deve ser 'nenhum' em dia normal"
	)
	var hat_layer: Node = hs.get_child(0)
	if hat_layer != null:
		assert_false(hat_layer.visible, "hat layer deve estar invisivel em dia normal")
	var fireworks: CPUParticles2D = null
	for child in hs.get_children():
		if child is CPUParticles2D:
			fireworks = child
			break
	if fireworks != null:
		assert_false(fireworks.emitting, "fogos nao devem emitir em dia normal")
