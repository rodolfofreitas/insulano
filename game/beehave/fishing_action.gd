@tool
class_name FishingAction
extends ActionUsingDelta
## Acção de pescar: mostra a cana, espera um tempo aleatório e faz nascer um peixe.
##
## Enquanto `in_use`, conta o tempo até à mordida (`seconds_until_bite`); ao
## fim, chama `spawn_fish` e devolve `SUCCESS`. Precisa de `blackboard_key`
## apontar para o nó do ponto de pesca (escrito por `FindGroupSpotCondition`).

@export var node_blackboard_key: StringName = "usable_spot"
@export var fishing_rod: Sprite2D
@export var animation_name: String = "fishing"

var fish_scene = preload("res://object/raw_fish.tscn")

var seconds_until_bite: float
var in_use: bool = false


## Faz o actor pescar: arranca a animação e a cana na 1ª chamada, faz nascer o peixe no fim.
func tick(actor: Node, blackboard: Blackboard) -> int:
	var character = actor as Character
	var result: int = FAILURE
	var spot: Node2D = blackboard.get_value(node_blackboard_key)

	if !in_use:
		seconds_until_bite = randf_range(5, 10)
		play_animation(character, spot)
		if fishing_rod != null:
			display_fishing_rod(character, spot)
		in_use = true
		result = RUNNING
	else:
		seconds_until_bite -= get_delta()
		if seconds_until_bite <= 0:
			spawn_fish(character, spot.global_position)
			in_use = false
			character.animated_sprite.stop()
			if fishing_rod != null:
				fishing_rod.transform = Transform2D.IDENTITY
				fishing_rod.visible = false
			result = SUCCESS
		else:
			result = RUNNING

	return result


## Toca a animação de pesca virada para o ponto de pesca.
func play_animation(character: Character, fishing_spot: Node2D) -> void:
	var direction: Direction = Direction.get_closest_direction(
		fishing_spot.global_position - character.global_position
	)
	character.play_animation_for_direction(direction, animation_name)


## Roda ou espelha a cana consoante a direcção do ponto de pesca e torna-a visível.
func display_fishing_rod(character: Character, fishing_spot: Node2D) -> void:
	var direction: Direction = Direction.get_closest_direction(
		fishing_spot.global_position - character.global_position
	)
	match direction:
		Direction.UP:
			fishing_rod.transform = fishing_rod.transform.rotated(deg_to_rad(-90))
		Direction.RIGHT:
			pass
		Direction.DOWN:
			fishing_rod.transform = fishing_rod.transform.rotated(deg_to_rad(90))
		Direction.LEFT:
			fishing_rod.transform = fishing_rod.transform.scaled(Vector2(-1, 1))
	fishing_rod.visible = true


## Instancia um peixe atrás do personagem, no lado oposto ao ponto de pesca.
##
## O peixe entra na lista de irmãos mesmo antes do personagem (por
## `move_child`, não por `get_child(indice - 1).add_sibling`, que dava -1
## e apanhava o último filho do pai quando o personagem era o primeiro, ver T-003).
func spawn_fish(character: Character, spot_location: Vector2) -> void:
	var fish: Node2D = fish_scene.instantiate()
	var character_location: Vector2 = character.global_position
	# O vector aponta do ponto de pesca para o personagem: nasce do lado oposto.
	var direction: Direction = Direction.get_closest_direction(character_location - spot_location)
	fish.position = character_location + (direction.vector * 32)
	var parent: Node = character.get_parent()
	var character_index: int = character.get_index()
	parent.add_child(fish)
	parent.move_child(fish, character_index)
