extends SceneTree
## Captura de prova visual da gaivota (T-302).
## Carrega a cena principal, forca o evento seagull a meio do ecra,
## avanca frames e grava o PNG.
##
## Uso:
##   godot --rendering-driver opengl3 --fixed-fps 60 --path game \
##     -s res://tools/capture_seagull.gd -- --out=/abs/prova.png --frames=90

var _frames_left: int = 90
var _out_path: String = ""
var _viewport: SubViewport
var _seagull: Node


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
	var scene_instance: Node = packed.instantiate()
	_viewport.add_child(scene_instance)
	# Emite o evento seagull directamente apos carregar a cena.
	# Usa duracao longa para que a gaivota esteja visivelmente a meio do ecra.
	var events_node: Node = root.get_node_or_null("Events")
	if events_node != null and events_node.has_signal("event_started"):
		events_node.event_started.emit("seagull", {"duration_s": 30.0})


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
