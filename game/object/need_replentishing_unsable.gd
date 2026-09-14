class_name NeedReplentishingUsable
extends GeneralUsableObject
## Objecto que repõe uma necessidade enquanto durar (ex.: o peixe apanhado).
##
## `use` chama `Need.increase` a cada tick e consome `max_replentish_value`;
## quando chega a 0, o próprio objecto se liberta (`queue_free`). O nome do
## ficheiro (`need_replentishing_unsable.gd`, com dois erros ortográficos
## herdados) não foi corrigido aqui: é fora do âmbito da T-002 (proíbe
## renomear ficheiros).
##
## Nota (não corrigida aqui, fora do âmbito): a condição que guarda a remoção
## de `need_name` (`max_replentish_value == 0`) quase nunca é verdadeira,
## porque `use` já chama `queue_free()` assim que `max_replentish_value` fica
## `<= 0`, o que torna o ramo praticamente morto. É comportamento, não um erro
## de tipos, por isso fica fora do âmbito da T-003.

@export var max_replentish_value = 50  ## Valor máximo de reposição da necessidade
@export var replentish_speed = 10  ## Velocidade de reposição, em unidades por segundo
@export var need_name: String  ## Nome da necessidade que este objecto pode repor


## Como get_satisfying_needs, mas remove need_name se já não houver reposição disponível.
func get_satisfying_needs():
	var result = Array(satisfying_needs)
	if max_replentish_value == 0:
		var need_index = result.find_custom(func(n: String): return n == need_name)
		if need_index >= 0:
			result.pop_at(need_index)
	return result


## Repõe a necessidade need_name do personagem, tocando a animação de comer.
func use(character: Character, delta: float) -> void:
	var need: Need = character.get_need(need_name)
	var max_use = min(max_replentish_value, replentish_speed * delta)
	if !character.animated_sprite.animation.begins_with("eat"):
		play_animation(character)
	var used = need.increase(max_use)
	max_replentish_value -= used
	if max_replentish_value <= 0:
		queue_free()


## Toca a animação de comer virada para o personagem.
func play_animation(character: Character) -> void:
	var direction: Direction = Direction.get_closest_direction(
		global_position - character.global_position
	)
	character.play_animation_for_direction(direction, "eat")
