extends Node
## Configura o modo de execucao: protector de ecra ou janela.
## Autoload: Screensaver. Le os argumentos de linha de comandos.
## Delega a deteccao de input ao InputWatcher (T-112).

var _mode: String = "window"
var _grace_period_s: float = 1.0
var _elapsed_s: float = 0.0
var _active: bool = false


func _ready() -> void:
	_parse_args()
	if _mode == "screensaver":
		_setup_screensaver()
	elif _mode == "credits":
		_open_credits()


## Modo actual: 'screensaver', 'window' ou 'credits'.
func mode() -> String:
	return _mode


## Interpreta os argumentos de linha de comandos do utilizador.
## Os args do utilizador vem apos '--' nos argumentos do OS.
func _parse_args() -> void:
	_parse_from(OS.get_cmdline_user_args())


## Aceita um array de argumentos para facilitar os testes unitarios.
func _parse_from(args: Array) -> void:
	if "--screensaver" in args or "-s" in args:
		_mode = "screensaver"
	elif "--windowed" in args or "-w" in args:
		_mode = "window"
	elif "--credits" in args:
		_mode = "credits"


func _setup_screensaver() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if has_node("/root/InputWatcher"):
		InputWatcher.set_mode("screensaver")
	_active = true
	if is_inside_tree() and has_node("/root/Clock"):
		Clock.hour_changed.connect(_on_hour_changed_screensaver)


func _open_credits() -> void:
	## Mostra o ecra de creditos ao arrancar com --credits.
	var credits_node: Node = _find_credits_screen()
	if credits_node != null and credits_node.has_method("show_credits"):
		credits_node.show_credits(false)


## Chamado quando Clock emite hour_changed em modo screensaver.
## Mostra os creditos durante 5s no inicio de cada hora.
func _on_hour_changed_screensaver(_hour: int) -> void:
	var credits_node: Node = _find_credits_screen()
	if credits_node != null and credits_node.has_method("show_credits"):
		credits_node.show_credits(true)


## Procura CreditsScreen na arvore de cenas activa.
func _find_credits_screen() -> Node:
	if not is_inside_tree():
		return null
	var root_node: Node = get_tree().current_scene
	if root_node == null:
		return null
	for child in root_node.get_children():
		if child is CreditsScreen:
			return child
	return null


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed_s += delta
