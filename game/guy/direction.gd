extends Object

class_name Direction

static var UP: Direction = Direction.new(Vector2.UP)
static var RIGHT: Direction = Direction.new(Vector2.RIGHT)
static var DOWN: Direction = Direction.new(Vector2.DOWN)
static var LEFT: Direction = Direction.new(Vector2.LEFT)

static var ALL_DIRECTIONS: Array[Direction] = [UP, RIGHT, DOWN, LEFT]

static func get_closest_direction(vec: Vector2) -> Direction:
	var result: Direction = ALL_DIRECTIONS[0]
	var closest_dist: float = vec.distance_squared_to(ALL_DIRECTIONS[0].vector)

	for dir in ALL_DIRECTIONS:
		var dist = vec.distance_squared_to(dir.vector)
		if dist < closest_dist:
			result = dir
			closest_dist = dist
	return result


var vector: Vector2

func _init(dir: Vector2) -> void:
	self.vector = dir




	
