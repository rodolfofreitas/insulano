extends SceneTree
## Smoke de arranque: carrega a cena principal, simula tempo de jogo e verifica
## sinais vitais do personagem. Sai com código 0 (passou) ou 1 (falhou).
##
## Uso (a partir da raiz do repositório), com INSULANO_LLM_URL apontado para
## uma porta morta (127.0.0.1:9, T-106): a env var é lida pelo LLMSettings
## dentro do próprio autoload LLM, ANTES deste script correr, por isso tem de
## vir do processo que invoca o Godot (scripts/verify.sh), nunca de
## OS.set_environment() aqui dentro (chegaria tarde demais):
##   INSULANO_LLM_URL=http://127.0.0.1:9 \
##     godot --headless --fixed-fps 60 --path game -s res://tools/boot_smoke.gd
##
## Com --fixed-fps 60, cada frame vale exactamente 1/60 s de jogo, por isso
## SIMULATED_FRAMES corresponde a um tempo de jogo determinístico, seja qual
## for a velocidade real da máquina.

## 90 segundos de jogo simulados (T-106): frames de sobra para o personagem
## completar pelo menos um ciclo de decisão (chegar a um ponto usável e a
## SayGeneratedAction correspondente falar), e ainda cobre a queda de fome
## que a versão anterior desta smoke já provava. O min_interval_s (30 s por
## defeito, tech_design.md §3) NÃO entra nesta conta: conta-se em SEGUNDOS
## REAIS (Time.get_ticks_msec(), não os frames simulados por --fixed-fps, que
## o Godot headless processa muito mais rápido do que o tempo real), mas a
## 1ª frase nunca está bloqueada por ele (say_last_at_s começa por definir no
## blackboard, `now_s - (-INF)` é sempre maior que qualquer intervalo); este
## smoke só exige UMA frase alguma vez, nunca uma 2ª depois do intervalo.
const SIMULATED_FRAMES: int = 5400

## A fome da base desce 1 ponto percentual por segundo; exigimos que o mínimo
## atingido fique pelo menos 5 pontos abaixo do início. Mede-se o mínimo e não o
## valor final porque o personagem pode pescar e comer durante a simulação.
const MIN_HUNGER_DROP_PERCENT: float = 5.0

## Seed fixa para o randf() da behavior tree. NÃO torna a corrida determinística:
## NavigationServer2D.map_get_random_point usa um gerador próprio (medido a 2026-09-13:
## deslocação entre 523 e 692 px em três corridas). Por isso os limiares são largos.
const RNG_SEED: int = 1992

## JSON com as frases de fallback (AGENTS.md §6.5, fonte única): usado para
## confirmar que a frase dita pelo SayGeneratedAction (T-106) é mesmo uma das
## garantidas pelo FallbackPhrases, nunca texto inventado por este script.
const FALLBACK_PHRASES_PATH := "res://data/phrases_fallback.json"

var _frames: int = 0
var _character: Character
var _start_position: Vector2
var _start_hunger: float
var _min_hunger: float = 100.0
var _max_distance: float = 0.0
## Todas as frases de game/data/phrases_fallback.json, achatadas numa só
## lista (categoria não importa para esta prova: qualquer uma serve).
var _fallback_phrases: PackedStringArray = []
## Verdadeiro desde que talking_text tenha coincidido, em algum frame, com
## uma frase de _fallback_phrases.
var _said_fallback_phrase: bool = false


func _initialize() -> void:
	seed(RNG_SEED)
	_fallback_phrases = _load_fallback_phrases()
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
	if not _said_fallback_phrase and _fallback_phrases.has(_character.talking_text):
		_said_fallback_phrase = true
	if _frames >= SIMULATED_FRAMES:
		_finish()
	return false


## Lê phrases_fallback.json e devolve todas as frases de todas as categorias
## numa única lista achatada (code_patterns.md §7: JSON do Godot, sem
## depender de FallbackPhrases porque não expõe as frases todas, só pick()).
func _load_fallback_phrases() -> PackedStringArray:
	var result: PackedStringArray = []
	var text := FileAccess.get_file_as_string(FALLBACK_PHRASES_PATH)
	var data: Variant = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("[Insulano/boot_smoke] JSON inválido: %s" % FALLBACK_PHRASES_PATH)
		return result
	for category in data.keys():
		var phrases: Variant = data[category]
		if typeof(phrases) != TYPE_ARRAY:
			continue
		for phrase in phrases:
			result.append(String(phrase))
	return result


func _finish() -> void:
	var hunger_drop: float = _start_hunger - _min_hunger
	var problems: PackedStringArray = []
	if hunger_drop < MIN_HUNGER_DROP_PERCENT:
		problems.append(
			"a fome desceu só %.2f pontos (mínimo %.1f)" % [hunger_drop, MIN_HUNGER_DROP_PERCENT]
		)
	if _max_distance < 1.0:
		problems.append("o personagem não se mexeu em %d frames" % SIMULATED_FRAMES)
	if not _said_fallback_phrase:
		problems.append(
			(
				"o personagem nunca disse uma frase de %s em %d frames"
				% [FALLBACK_PHRASES_PATH, SIMULATED_FRAMES]
			)
		)
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
