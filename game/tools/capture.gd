extends SceneTree
## Captura de prova visual: carrega uma cena com renderização real dentro de um
## SubViewport de tamanho fixo, espera N frames e grava a imagem num PNG.
## É assim que um agente "vê" o jogo.
##
## Porquê SubViewport e não a janela: no Hyprland (tiling) o compositor
## redimensiona a janela e ignora --resolution; o SubViewport garante que todas
## as provas têm o mesmo tamanho e são comparáveis entre corridas.
##
## Uso (a partir da raiz do repositório; NÃO usar --headless, não há imagem):
##   godot --rendering-driver opengl3 --fixed-fps 60 --path game \
##     -s res://tools/capture.gd -- --out=/abs/prova.png --frames=240
##
## Argumentos depois de "--":
##   --out=CAMINHO     PNG de saída (obrigatório, caminho absoluto)
##   --frames=N        frames a simular antes da captura (defeito 240 = 4 s)
##   --scene=res://... cena a carregar (defeito: cena principal do projecto)
##   --size=LxA        tamanho da imagem (defeito 1280x720)

var _frames_left: int = 240
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
		printerr("CAPTURE FALHOU: cena não carrega: " + scene_path)
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
	_frames_left -= 1
	if _frames_left == 0:
		var image: Image = _viewport.get_texture().get_image()
		var err: Error = image.save_png(_out_path)
		if err != OK:
			printerr("CAPTURE FALHOU: não gravou %s (erro %d)" % [_out_path, err])
			quit(1)
		else:
			print("CAPTURE OK: %s (%dx%d)" % [_out_path, image.get_width(), image.get_height()])
			quit(0)
	return false
