extends SceneTree
## Mede FPS durante 10s com chuva activa (T-305).
## Uso: INSULANO_FAKE_WEATHER=rain godot --rendering-driver opengl3
##   --fixed-fps 60 --path game -s res://tools/fps_rain.gd
## Saida: FPS_RAIN_MEDIO: <valor>

const WARMUP_FRAMES: int = 120
const MEASURE_FRAMES: int = 600  # 10s a 60fps

var _frames: int = 0
var _fps_sum: float = 0.0
var _fps_count: int = 0


func _initialize() -> void:
	var scene_path: String = ProjectSettings.get_setting("application/run/main_scene")
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		printerr("FPS_RAIN FALHOU: cena nao carrega")
		quit(1)
		return
	root.add_child(packed.instantiate())


func _process(_delta: float) -> bool:
	_frames += 1
	if _frames > WARMUP_FRAMES:
		_fps_sum += Engine.get_frames_per_second()
		_fps_count += 1
	if _frames >= WARMUP_FRAMES + MEASURE_FRAMES:
		var avg: float = _fps_sum / _fps_count if _fps_count > 0 else 0.0
		print("FPS_RAIN_MEDIO: %.1f" % avg)
		if avg >= 55.0:
			print("FPS OK (>= 55 fps)")
			quit(0)
		else:
			printerr("FPS BAIXO: %.1f (minimo 55)" % avg)
			quit(1)
	return false
