extends SceneTree
## Captura de prova especifica para CampfireObject (T-119).
## Carrega a cena principal e ignita a fogueira antes de capturar.
##
## Uso:
##   INSULANO_FAKE_TIME=2026-12-25T23:00 godot --rendering-driver opengl3 \
##     --fixed-fps 60 --path game -s res://tools/capture_campfire.gd \
##     -- --out=/abs/prova.png --frames=300

var _frames_left: int = 300
var _out_path: String = ""
var _viewport: SubViewport


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
	var scene_instance := packed.instantiate()
	_viewport.add_child(scene_instance)
	# Ignita a fogueira apos um frame
	await scene_instance.ready
	var campfire := scene_instance.get_node_or_null("Campfire") as CampfireObject
	if campfire != null:
		campfire.ignite()
		print("CAPTURE: fogueira acesa, burning=%s" % campfire.is_burning())
	else:
		printerr("CAPTURE AVISO: Campfire nao encontrado na cena")


func _process(_delta: float) -> bool:
	if _viewport == null:
		return false
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
