extends GutTest
## Testes de integracao para CloudLayer (T-134): movimento das nuvens,
## wrap-around ao sair do ecra e ajuste de alpha dia/noite.


## Stub minimo do Clock para os testes emitirem o sinal hour_changed.
class FakeClock:
	extends Node
	signal hour_changed(hour: int)
	var _hour: int = 12

	func hour_float() -> float:
		return float(_hour)

	func set_hour(h: int) -> void:
		_hour = h
		hour_changed.emit(h)


var _layer: CloudLayer
var _fake_clock: FakeClock


func before_each() -> void:
	_fake_clock = FakeClock.new()
	_fake_clock.name = "Clock"
	add_child(_fake_clock)

	_layer = CloudLayer.new()
	add_child(_layer)
	# Liga o sinal manualmente, simulando o que _ready faz com o autoload real.
	_fake_clock.hour_changed.connect(_layer._on_hour_changed)


func after_each() -> void:
	_layer.queue_free()
	_fake_clock.queue_free()


## test_clouds_move_left: apos process(1.0), x de cada nuvem diminuiu.
func test_clouds_move_left() -> void:
	await get_tree().process_frame
	var xs_before: Array[float] = []
	for cloud in _layer._clouds:
		xs_before.append(cloud["x"])

	_layer._process(1.0)

	for i in range(_layer._clouds.size()):
		var cloud: Dictionary = _layer._clouds[i]
		assert_lt(cloud["x"], xs_before[i], "nuvem %d deve ter x menor apos 1s" % i)


## test_clouds_wrap_around: nuvem com x muito negativo volta para viewport_width.
func test_clouds_wrap_around() -> void:
	await get_tree().process_frame
	# Forcamos x muito negativo numa nuvem.
	var cloud: Dictionary = _layer._clouds[0]
	var w: float = cloud["w"]
	cloud["x"] = -w - 100.0

	_layer._process(0.001)

	assert_gt(
		_layer._clouds[0]["x"],
		0.0,
		"nuvem deve ter voltado para o lado direito apos sair pelo lado esquerdo"
	)


## test_alpha_day_vs_night: hora 12h -> alpha=0.7; hora 23h -> alpha=0.2.
func test_alpha_day_vs_night() -> void:
	await get_tree().process_frame

	_fake_clock.set_hour(12)
	await get_tree().process_frame
	for cloud in _layer._clouds:
		assert_almost_eq(cloud["alpha"], 0.7, 0.01, "alpha deve ser 0.7 de dia (hora 12)")

	_fake_clock.set_hour(23)
	await get_tree().process_frame
	for cloud in _layer._clouds:
		assert_almost_eq(cloud["alpha"], 0.2, 0.01, "alpha deve ser 0.2 de noite (hora 23)")
