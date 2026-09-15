extends SceneTree
## Captura de prova T-123: modo screensaver com INSULANO_FAKE_TIME=2026-09-15T22:00,
## apos 5 minutos simulados de tempo real acelerado o jogo deve estar de madrugada.
##
## Simula 300 segundos de delta directamente no Clock para provar o ciclo acelerado.
##
## Uso (a partir da raiz do repositorio):
##   INSULANO_FAKE_TIME=2026-09-15T22:00 \
##   godot --rendering-driver opengl3 --fixed-fps 60 --path game \
##     -s res://tools/capture_night_cycle.gd -- --out=/abs/T-123-ciclo-noite.png --frames=300

var _frames_left: int = 300
var _out_path: String = ""
var _viewport: SubViewport
var _clock_ready: bool = false


func _initialize() -> void:
	var scene_path: String = ProjectSettings.get_setting("application/run/main_scene")
	var size := Vector2i(1280, 720)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out_path = arg.trim_prefix("--out=")
		elif arg.begins_with("--frames="):
			_frames_left = int(arg.trim_prefix("--frames="))
		elif arg.begins_with("--scene="):
			scene_path = arg.trim_prefix("--scene=")
		elif arg.begins_with("--size="):
			var parts: PackedStringArray = arg.trim_prefix("--size=").split("x")
			size = Vector2i(int(parts[0]), int(parts[1]))
	if _out_path.is_empty():
		printerr("CAPTURE FALHOU: falta --out=CAMINHO")
		quit(2)
		return
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		printerr("CAPTURE FALHOU: cena nao carrega: " + scene_path)
		quit(1)
		return
	_viewport = SubViewport.new()
	_viewport.size = size
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_viewport)
	_viewport.add_child(packed.instantiate())


func _process(_delta: float) -> bool:
	if _viewport == null:
		return false

	## No primeiro frame: activar aceleracao no Clock e simular 300s de delta.
	if not _clock_ready and root.has_node("/root/Clock"):
		var clock_node: Node = root.get_node("/root/Clock")
		if clock_node.has_method("_activate_accelerated_mode"):
			clock_node._activate_accelerated_mode()
		## Simular 300 segundos reais (5 minutos) = 4 horas de jogo desde 22:00 -> ~02:00
		for _i in range(300):
			clock_node._process(1.0)
		_clock_ready = true
		var hf: float = clock_node.hour_float()
		var per: String = clock_node.period()
		print("T-123 PROVA: hora_jogo=%.2f periodo=%s" % [hf, per])

	_frames_left -= 1
	if _frames_left == 0:
		var image: Image = _viewport.get_texture().get_image()
		var err: Error = image.save_png(_out_path)
		if err != OK:
			printerr("CAPTURE FALHOU: nao gravou %s (erro %d)" % [_out_path, err])
			quit(1)
		else:
			print("CAPTURE OK: %s (%dx%d)" % [_out_path, image.get_width(), image.get_height()])
			quit(0)
	return false
