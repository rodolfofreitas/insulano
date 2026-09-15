extends Node
## Detecta presenca do utilizador e emite sinal para reaccao antes de fechar.
## Autoload: InputWatcher. Em modo screensaver fecha apos 150ms de graca.

signal presence_detected(type: String)

const JITTER_THRESHOLD_PX: float = 6.0
const JITTER_FRAMES: int = 3
const REACTION_MS: float = 150.0

var _mode: String = "window"
var _accumulated_delta: float = 0.0
var _frames_counted: int = 0
var _closing: bool = false


## Define o modo de operacao: 'screensaver' fecha apos reaccao; 'window' nunca fecha.
func set_mode(mode: String) -> void:
	_mode = mode


func _input(event: InputEvent) -> void:
	if _closing:
		return
	if event is InputEventMouseMotion:
		_accumulated_delta += event.relative.length()
		_frames_counted += 1
		if _frames_counted >= JITTER_FRAMES:
			if _accumulated_delta > JITTER_THRESHOLD_PX:
				var type := "suave" if _accumulated_delta < 20.0 else "brusco"
				_on_presence(type)
			_accumulated_delta = 0.0
			_frames_counted = 0
	elif event is InputEventMouseButton:
		_on_presence("clique")
	elif event is InputEventKey:
		_on_presence("tecla")


func _on_presence(type: String) -> void:
	presence_detected.emit(type)
	if _mode == "screensaver":
		_closing = true
		await get_tree().create_timer(REACTION_MS / 1000.0).timeout
		get_tree().quit()
