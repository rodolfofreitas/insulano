class_name Character
extends CharacterBody2D
## Personagem base: necessidades, navegação, animação por direcção e balão de fala.
##
## `Guy` (guy/guy.gd) estende esta classe para o náufrago jogável; a behavior
## tree (Beehave) lê `needs` e chama `walk_towards`/`play_animation_for_direction`
## através dela. Não decide sozinho o que fazer: quem decide é a árvore.
##
## `speech_bubble` é quem manda na duração da frase visível (T-107,
## `game/ui/speech_bubble.gd`, tech_design.md §4.6): `talking_text` só lhe
## passa o texto (`show_text()`), nunca controla quanto tempo fica visível
## nem o esconde directamente. `SayGeneratedAction` (T-106) fala através
## deste `talking_text`, nunca do `speech_bubble` directamente, para não
## depender do tipo concreto do balão.

@export var needs: Array[Need]
@export var walking_speed: int = 100  ## Velocidade em px/s
@export var navigation_agent: NavigationAgent2D
@export var animated_sprite: AnimatedSprite2D
@export var speech_bubble: SpeechBubble

## Guarda a última frase dita, mesmo depois de o balão a esconder: o setter
## só passa o texto ao `speech_bubble` (`show_text()`), nunca o limpa por
## conta própria quando o balão desaparece sozinho ao fim de
## `display_seconds_for()`. O `boot_smoke.gd` depende disto para confirmar
## que a árvore chegou a falar, mesmo que a captura corra depois do balão já
## se ter escondido.
@export var talking_text: String = "":
	set(value):
		talking_text = value
		if speech_bubble != null:
			speech_bubble.show_text(value)

var current_walking_dir: Vector2 = Vector2.ZERO


func _ready() -> void:
	if speech_bubble != null:
		speech_bubble.show_text(talking_text)


## Move o personagem em direcção a `target_global`, via NavigationAgent2D se houver um.
func walk_towards(target_global: Vector2) -> void:
	if navigation_agent == null:
		velocity = (target_global - global_position).normalized() * walking_speed
	else:
		navigation_agent.target_position = target_global


func _physics_process(_delta: float) -> void:
	if navigation_agent != null:
		if !navigation_agent.is_navigation_finished():
			var current_agent_position: Vector2 = global_position
			var next_path_position: Vector2 = navigation_agent.get_next_path_position()

			velocity = current_agent_position.direction_to(next_path_position) * walking_speed
		else:
			velocity = Vector2.ZERO
	move_and_slide()


## Devolve todas as necessidades do personagem.
func get_needs() -> Array[Need]:
	return needs


## Devolve a necessidade com o nome dado, ou null se não existir.
func get_need(name: String) -> Need:
	var result: Need
	for need in needs:
		if need.name == name:
			result = need
			break
	return result


## Toca a animação `name` virada para `dir` (ex.: "walk" + Direction.UP -> "walk_up").
func play_animation_for_direction(dir: Direction, name: String) -> void:
	match dir:
		Direction.UP:
			animated_sprite.play(name + "_up")
		Direction.RIGHT:
			animated_sprite.play(name + "_right")
		Direction.DOWN:
			animated_sprite.play(name + "_down")
		Direction.LEFT:
			animated_sprite.play(name + "_left")
		_:
			animated_sprite.stop()
