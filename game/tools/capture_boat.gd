extends SceneTree
## Ferramenta de prova visual T-303: carrega a cena, dispara o evento "boat"
## imediatamente e captura o frame com o barco visivel no horizonte.
##
## Uso (a partir da raiz do repositorio):
##   godot --rendering-driver opengl3 --fixed-fps 60 --path game \
##     -s res://tools/capture_boat.gd -- --out=/abs/T-303-barco.png --frames=60

var _frames_left: int = 60
var _out_path: String = ""
var _viewport: SubViewport = null
var _boat: Node = null
var _scene_instance: Node = null
var _boat_triggered: bool = false


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
	var scene_instance: Node = packed.instantiate()
	_scene_instance = scene_instance
	_viewport.add_child(scene_instance)

	## Adiciona o barco directamente; o evento sera disparado no 1o frame
	## para que o viewport ja tenha tamanho valido.
	var BoatClass: Script = load("res://events/boat.gd")
	if BoatClass != null:
		_boat = BoatClass.new()
		scene_instance.add_child(_boat)


func _process(_delta: float) -> bool:
	if _viewport == null:
		return false
	## Dispara o evento no frame 2 (viewport ja tem tamanho valido).
	if not _boat_triggered and _boat != null and _frames_left <= 58:
		_boat_triggered = true
		_boat._on_event_started("boat", {"duration_s": 30.0})
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
