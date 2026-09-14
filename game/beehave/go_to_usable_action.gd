@tool
class_name GoToUsableAction
extends ActionLeaf
## Move o actor até à posição em `blackboard_key`, usando o `NavigationAgent2D` do Character.
##
## Devolve `RUNNING` enquanto anda, `SUCCESS` quando o navegador reporta chegada
## (a partir da 2ª chamada, para dar tempo ao agente de calcular caminho).
##
## Bug herdado, não corrigido aqui (ver T-003): `position` é `Vector2` (tipo por
## valor, nunca `null`), por isso `if position != null` é sempre verdadeiro e o
## ramo `else` (que pararia o personagem) é código morto.

@export var blackboard_key: StringName = "location"
@export var distance_threshold: float = 50
## Verbo em pt-PT a escrever em "current_action" (SayGeneratedAction, T-106)
## enquanto este nó anda. Vazio (defeito) não escreve nada. As três sequências
## que usam este nó definem o seu próprio rótulo em `guy.tscn`: "ir comer" (a
## caminho do objecto que satisfaz a fome), "ir pescar" (a caminho do ponto de
## pesca) e "passear" (andar para um ponto aleatório, sem destino funcional,
## onde não há nenhuma outra acção a seguir que escreva um verbo mais
## específico). Sem isto, a `SayGeneratedAction` a seguir a este nó falaria
## com o `current_action` deixado pela sequência anterior (ver tech_design.md
## §4.6).
@export var current_action_label: String = ""


## Anda até `position`; a 1ª chamada só arranca a navegação, as seguintes verificam a chegada.
func tick(actor: Node, blackboard: Blackboard) -> int:
	var position: Vector2 = blackboard.get_value(blackboard_key)
	var character = actor as Character
	var result: int = FAILURE
	if not current_action_label.is_empty():
		blackboard.set_value("current_action", current_action_label)
	if position != null:
		var is_first_call = blackboard.get_value("goToUsable_first_call", true)

		if !is_first_call && character.navigation_agent.is_navigation_finished():
			blackboard.erase_value("goToUsable_first_call")
			character.velocity = Vector2.ZERO
			character.animated_sprite.stop()
			character.animated_sprite.frame = 1

			result = SUCCESS
		else:
			blackboard.set_value("goToUsable_first_call", false)
			if distance_threshold > 0:
				character.navigation_agent.target_desired_distance = distance_threshold
			character.walk_towards(position)

			if character.velocity.length_squared() > 0:
				var direction: Direction = Direction.get_closest_direction(
					character.velocity.normalized()
				)
				character.play_animation_for_direction(direction, "walk")
			else:
				character.animated_sprite.stop()
				character.animated_sprite.frame = 1
			result = RUNNING
	else:
		character.velocity = Vector2.ZERO

	return result
