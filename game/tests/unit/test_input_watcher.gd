extends GutTest
## Testes unitarios do InputWatcher: threshold anti-jitter, tipos de input, modo window.

const InputWatcherScript = preload("res://app/input_watcher.gd")

var watcher: Node
var _detected_types: Array[String] = []


func before_each() -> void:
	watcher = InputWatcherScript.new()
	add_child_autofree(watcher)
	_detected_types = []
	watcher.presence_detected.connect(func(type: String) -> void: _detected_types.append(type))


func after_each() -> void:
	_detected_types = []


## Movimento de 5px acumulado em 3 frames nao dispara (abaixo do threshold de 6px).
func test_jitter_threshold() -> void:
	# 5px total em 3 frames -- abaixo de JITTER_THRESHOLD_PX (6.0)
	for i in range(3):
		var ev := InputEventMouseMotion.new()
		# ~1.67px por frame; relativo em X para dar comprimento total ~5px
		ev.relative = Vector2(5.0 / 3.0, 0.0)
		watcher._input(ev)
	assert_eq(_detected_types.size(), 0, "Movimento de 5px nao deve disparar presence_detected")


## Movimento de 10px acumulado em 3 frames dispara com tipo 'suave' (< 20px).
func test_above_threshold_fires() -> void:
	# 10px total em 3 frames -- acima de 6px e abaixo de 20px => tipo 'suave'
	for i in range(3):
		var ev := InputEventMouseMotion.new()
		ev.relative = Vector2(10.0 / 3.0, 0.0)
		watcher._input(ev)
	assert_eq(_detected_types.size(), 1, "Movimento de 10px deve disparar presence_detected")
	assert_eq(_detected_types[0], "suave", "Tipo deve ser 'suave' para delta < 20px")


## MouseButton dispara com tipo 'clique'.
func test_click_type() -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	watcher._input(ev)
	assert_eq(_detected_types.size(), 1, "Clique deve disparar presence_detected")
	assert_eq(_detected_types[0], "clique", "Tipo deve ser 'clique' para MouseButton")


## Em modo window, presence_detected emite mas o jogo nao fecha.
func test_window_mode_never_closes() -> void:
	watcher.set_mode("window")
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	watcher._input(ev)
	assert_eq(_detected_types.size(), 1, "Sinal presence_detected deve ser emitido em modo window")
	# _closing deve permanecer false em modo window (quit nao e chamado)
	assert_false(watcher._closing, "Em modo window, _closing deve permanecer false")
