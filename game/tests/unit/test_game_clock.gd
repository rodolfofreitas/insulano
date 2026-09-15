extends GutTest
## Testes de [GameClock] (tech_design.md §5), o autoload Clock que e a
## fonte unica da hora no jogo. Cobre: fronteiras de period(), parsing de
## fake_time, valor invalido nao parte o jogo, e emissao de hour_changed.

## Instancia isolada do GameClock sem depender do autoload global.
var _clock: GameClock


func before_each() -> void:
	_clock = GameClock.new()
	add_child(_clock)


func after_each() -> void:
	_clock.queue_free()


## Fronteiras exactas de period() usando _parse_fake_time directamente.
## Cobre: 05:59 madrugada, 06:00 manha, 11:59 manha, 12:00 tarde,
## 16:59 tarde, 17:00 fim da tarde, 19:59 fim da tarde, 20:00 noite,
## 23:59 noite.
func test_period_boundaries() -> void:
	var cases := [
		["2026-01-01T05:59", "madrugada"],
		["2026-01-01T06:00", "manha"],
		["2026-01-01T11:59", "manha"],
		["2026-01-01T12:00", "tarde"],
		["2026-01-01T16:59", "tarde"],
		["2026-01-01T17:00", "fim da tarde"],
		["2026-01-01T19:59", "fim da tarde"],
		["2026-01-01T20:00", "noite"],
		["2026-01-01T23:59", "noite"],
	]
	for c in cases:
		var fake: String = c[0]
		var expected: String = c[1]
		_clock._fake_time = fake
		var got := _clock.period()
		var msg := "fake_time=%s: period() devia ser '%s', obteve '%s'" % [fake, expected, got]
		assert_eq(got, expected, msg)


## INSULANO_FAKE_TIME=2026-12-25T21:30 faz hour_float() devolver 21.5.
func test_fake_time_parsing() -> void:
	_clock._fake_time = "2026-12-25T21:30"
	var hf := _clock.hour_float()
	assert_eq(hf, 21.5, "hour_float() devia ser 21.5 para 21:30")
	var d := _clock.now()
	assert_eq(d.get("year", 0), 2026)
	assert_eq(d.get("month", 0), 12)
	assert_eq(d.get("day", 0), 25)
	assert_eq(d.get("hour", 0), 21)
	assert_eq(d.get("minute", 0), 30)


## Valor invalido nao parte o jogo: _parse_fake_time devolve {} e now() usa hora real.
func test_invalid_fake_time_uses_real() -> void:
	_clock._fake_time = "invalido"
	## Deve devolver dicionario valido (hora real), nunca um dicionario vazio.
	var d := _clock.now()
	assert_false(d.is_empty(), "now() nao pode devolver dicionario vazio com fake_time invalido")
	assert_true(d.has("hour"), "now() deve ter a chave 'hour'")
	assert_true(d.has("minute"), "now() deve ter a chave 'minute'")


## Avancar hora simulada de 10:00 para 11:00 dispara hour_changed uma vez.
func test_hour_changed_emitted() -> void:
	var emitted_hours: Array = []
	_clock.hour_changed.connect(func(h: int) -> void: emitted_hours.append(h))
	## Inicializar _last_hour para 10, evitando emissao espuria no primeiro _process.
	_clock._fake_time = "2026-01-01T10:00"
	_clock._last_hour = 10
	## Avancar para 11:00 -- deve emitir hour_changed(11).
	_clock._fake_time = "2026-01-01T11:00"
	_clock._process(0.016)
	assert_eq(emitted_hours.size(), 1, "hour_changed deve ser emitido exactamente uma vez")
	assert_eq(emitted_hours[0], 11, "hour_changed deve emitir a nova hora (11)")
