extends SceneTree
## Captura de prova visual do ecra de creditos (T-503).
## Carrega a cena principal, forca show_credits() no primeiro frame e captura apos N frames.
##
## Uso:
##   godot --rendering-driver opengl3 --fixed-fps 60 --path game \
##     -s res://tools/capture_credits.gd -- --out=/abs/prova.png --frames=60

var _frames_left: int = 60
var _out_path: String = ""
var _viewport: SubViewport
var _scene_instance: Node = null
var _credits_shown: bool = false


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
	_scene_instance = packed.instantiate()
	_viewport.add_child(_scene_instance)


func _process(_delta: float) -> bool:
	if _viewport == null:
		return false
	## Mostrar creditos no primeiro frame (apos _ready() ja ter corrido)
	if not _credits_shown and _scene_instance != null:
		_credits_shown = true
		for child in _scene_instance.get_children():
			if child is CreditsScreen:
				child.show_credits(false)
				break
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
