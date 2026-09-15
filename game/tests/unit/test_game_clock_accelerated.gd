extends GutTest
## Testes de [GameClock] modo acelerado (T-123): ciclo de 30 minutos ancorado na hora real.
## Cobre: ciclo completo de 1800s, ancora na hora real, modo janela sem aceleracao.

## Instancia isolada do GameClock sem depender do autoload global.
var _clock: GameClock


func before_each() -> void:
	_clock = GameClock.new()
	add_child(_clock)
	## Garantir que nao esta em modo acelerado por defeito.
	_clock._accelerated = false
	_clock._game_elapsed = 0.0
	_clock._start_game_seconds = 0.0


func after_each() -> void:
	_clock.queue_free()


## Simular 1800s de delta acumulado: hour_float deve voltar ao ponto de partida (modulo 24h).
## A ancora e as 14h (fraccao 14/24 do ciclo = 1050s). Apos 1800s, _game_elapsed=1800s,
## _game_time_s = (1050 + 1800) % 1800 = 1050, ou seja de volta a ~14h de jogo.
func test_screensaver_cycle_30min() -> void:
	## Ancora manual a 14h: 14/24 * 1800 = 1050s
	var anchor_seconds: float = (14.0 / 24.0) * GameClock.GAME_DAY_DURATION_S
	_clock._start_game_seconds = anchor_seconds
	_clock._game_elapsed = 0.0
	_clock._game_time_s = anchor_seconds
	_clock._accelerated = true

	## Simular 1800s (um ciclo completo) de delta
	var total_delta: float = 1800.0
	var step: float = 0.016
	var elapsed: float = 0.0
	while elapsed < total_delta:
		var d: float = minf(step, total_delta - elapsed)
		_clock._process(d)
		elapsed += d

	## Apos 1800s exactos, game_time_s deve estar de volta a ancora (~14h)
	var hf: float = _clock.hour_float()
	## tolerancia: o loop de passos de 16ms pode dar um erro residual pequeno
	assert_almost_eq(hf, 14.0, 0.1, "apos 1800s o ciclo deve voltar ao ponto de partida (~14h)")


## Com INSULANO_FAKE_TIME=2026-09-15T14:00:00 e modo screensaver,
## a ancora deve colocar game_hour inicial ~14.0.
func test_anchor_14h() -> void:
	_clock._fake_time = "2026-09-15T14:00:00"
	_clock._activate_accelerated_mode()
	var hf: float = _clock.hour_float()
	assert_almost_eq(hf, 14.0, 0.05, "game_hour inicial deve ser ~14.0 quando ancora as 14h")
	assert_true(_clock._accelerated, "_accelerated deve ser true apos _activate_accelerated_mode()")


## Em modo janela (sem aceleracao), hour_float() reflecte a hora real/fake sem multiplicador.
## Com fake_time=16:30, hour_float() deve devolver 16.5.
func test_window_mode_real_time() -> void:
	_clock._fake_time = "2026-09-15T16:30"
	## _accelerated e false (por defeito no before_each)
	assert_false(_clock._accelerated, "modo janela: _accelerated deve ser false")
	var hf: float = _clock.hour_float()
	assert_almost_eq(
		hf, 16.5, 0.01, "modo janela: hour_float() deve devolver a hora real/fake (16.5)"
	)
	## Simular _process nao muda a hora em modo janela
	_clock._process(60.0)
	var hf2: float = _clock.hour_float()
	assert_almost_eq(hf2, 16.5, 0.01, "modo janela: _process nao deve alterar hour_float()")
