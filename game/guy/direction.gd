class_name Direction
extends Object
## Uma das quatro direcções cardinais, usada para escolher animação (walk_up,
## fishing_left, ...) a partir de um vector de movimento.
##
## Os quatro singletons (UP, RIGHT, DOWN, LEFT) e ALL_DIRECTIONS ficam em
## MAIÚSCULAS de propósito: são imutáveis como constantes mas não podem ser
## `const` porque o valor vem de `Direction.new(...)`, uma chamada a
## construtor. A supressão de `class-variable-name` abaixo é só para estas
## 5 linhas (ver ADR-011); não há excepção global no repositório.

# gdlint:disable=class-variable-name
static var UP: Direction = Direction.new(Vector2.UP)
static var RIGHT: Direction = Direction.new(Vector2.RIGHT)
static var DOWN: Direction = Direction.new(Vector2.DOWN)
static var LEFT: Direction = Direction.new(Vector2.LEFT)
static var ALL_DIRECTIONS: Array[Direction] = [UP, RIGHT, DOWN, LEFT]
# gdlint:enable=class-variable-name

var vector: Vector2


## Devolve, de entre ALL_DIRECTIONS, a mais próxima do vector dado.
static func get_closest_direction(vec: Vector2) -> Direction:
	var result: Direction = ALL_DIRECTIONS[0]
	var closest_dist: float = vec.distance_squared_to(ALL_DIRECTIONS[0].vector)

	for dir in ALL_DIRECTIONS:
		var dist = vec.distance_squared_to(dir.vector)
		if dist < closest_dist:
			result = dir
			closest_dist = dist
	return result


func _init(dir: Vector2) -> void:
	self.vector = dir
