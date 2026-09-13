@tool
class_name FindGroupSpotCondition
extends ConditionLeaf
## Escolhe ao acaso um nó do grupo `group_name` e grava a posição no blackboard.
##
## Falha se o grupo estiver vazio ou não tiver nenhum nó `Node2D`. Usada pela
## `GoFishingSequence` para encontrar um ponto de pesca.

@export var group_name: StringName
@export var location_blackboard_key: StringName = "location"
@export var node_blackboard_key: StringName = "found_node"


## Ignora o actor; lê o grupo da árvore de cena e escreve local e nó no blackboard.
func tick(_actor: Node, blackboard: Blackboard) -> int:
	var available_spots: Array[Node] = get_tree().get_nodes_in_group(group_name)
	var spot = available_spots.pick_random()
	if spot != null && spot is Node2D:
		blackboard.set_value(location_blackboard_key, spot.global_position)
		blackboard.set_value(node_blackboard_key, spot)
		return SUCCESS
	return FAILURE
