@tool
class_name FindRandomSpotCondition
extends ConditionLeaf
## Escolhe um ponto aleatório navegável do `NavigationServer2D` e grava-o no blackboard.
##
## Falha se o servidor de navegação devolver `Vector2.ZERO` (sem malha carregada
## ou navegação ainda não sincronizada). A posição não é fixada pela seed: ver a
## nota em tools/boot_smoke.gd sobre `NavigationServer2D.map_get_random_point`.

@export var blackboard_key: StringName = "location"


## Lê o NavigationAgent2D do actor e escreve um ponto aleatório da malha de navegação.
func tick(actor: Node, blackboard: Blackboard) -> int:
	var character: Character = actor as Character

	var map_id: RID = character.navigation_agent.get_navigation_map()
	var layers: int = character.navigation_agent.navigation_layers
	var spot: Vector2 = NavigationServer2D.map_get_random_point(map_id, layers, false)
	if spot != null && spot != Vector2.ZERO:
		blackboard.set_value(blackboard_key, spot)
		return SUCCESS
	return FAILURE
