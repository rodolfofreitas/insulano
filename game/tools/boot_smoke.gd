extends SceneTree
## Smoke de arranque: carrega a cena principal, simula tempo de jogo e verifica
## sinais vitais do personagem. Sai com código 0 (passou) ou 1 (falhou).
##
## Uso (a partir da raiz do repositório):
##   godot --headless --fixed-fps 60 --path game -s res://tools/boot_smoke.gd
##
## Com --fixed-fps 60, cada frame vale exactamente 1/60 s de jogo, por isso
## SIMULATED_FRAMES corresponde a um tempo de jogo determinístico, seja qual
## for a velocidade real da máquina.

## 30 segundos de jogo: chega para a fome descer e o personagem sair do sítio.
const SIMULATED_FRAMES: int = 1800

## A fome da base desce 1 ponto percentual por segundo; exigimos que o mínimo
## atingido fique pelo menos 5 pontos abaixo do início. Mede-se o mínimo e não o
## valor final porque o personagem pode pescar e comer durante a simulação.
const MIN_HUNGER_DROP_PERCENT: float = 5.0

## Seed fixa para o randf() da behavior tree. NÃO torna a corrida determinística:
## NavigationServer2D.map_get_random_point usa um gerador próprio (medido a 2026-09-13:
## deslocação entre 523 e 692 px em três corridas). Por isso os limiares são largos.
const RNG_SEED: int = 1992

var _frames: int = 0
var _character: Character
var _start_position: Vector2
var _start_hunger: float
var _min_hunger: float = 100.0
var _max_distance: float = 0.0


func _initialize() -> void:
	seed(RNG_SEED)
	var scene_path: String = ProjectSettings.get_setting("application/run/main_scene")
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		_fail("a cena principal não carrega: %s" % scene_path)
		return
	var scene: Node = packed.instantiate()
	root.add_child(scene)
	_character = _find_character(scene)
	if _character == null:
		_fail("a cena principal não contém nenhum nó Character")


func _process(_delta: float) -> bool:
	if _character == null:
		return false
	_frames += 1
	if _frames == 1:
		_start_position = _character.global_position
		_start_hunger = _character.get_need("hunger").get_percentage()
	var distance: float = _character.global_position.distance_to(_start_position)
	_max_distance = maxf(_max_distance, distance)
	_min_hunger = minf(_min_hunger, _character.get_need("hunger").get_percentage())
	if _frames >= SIMULATED_FRAMES:
		_finish()
	return false


func _finish() -> void:
	var hunger_drop: float = _start_hunger - _min_hunger
	var problems: PackedStringArray = []
	if hunger_drop < MIN_HUNGER_DROP_PERCENT:
		problems.append(
			"a fome desceu só %.2f pontos (mínimo %.1f)" % [hunger_drop, MIN_HUNGER_DROP_PERCENT]
		)
	if _max_distance < 1.0:
		problems.append("o personagem não se mexeu em %d frames" % SIMULATED_FRAMES)
	if problems.is_empty():
		print(
			(
				"BOOT_SMOKE PASSOU: fome -%.1f pontos, deslocação máxima %.0f px"
				% [hunger_drop, _max_distance]
			)
		)
		quit(0)
	else:
		_fail("; ".join(problems))


func _fail(reason: String) -> void:
	printerr("BOOT_SMOKE FALHOU: " + reason)
	quit(1)


func _find_character(node: Node) -> Character:
	if node is Character:
		return node
	for child in node.get_children():
		var found: Character = _find_character(child)
		if found != null:
			return found
	return null
