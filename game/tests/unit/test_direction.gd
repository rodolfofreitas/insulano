extends GutTest
## Testes de caracterização de [Direction], usada para escolher a animação
## (walk_up, fishing_left, ...) a partir de um vector de movimento.


func test_mostly_right_vector_maps_to_right() -> void:
	assert_eq(Direction.get_closest_direction(Vector2(0.9, 0.2)), Direction.RIGHT)


func test_screen_up_is_negative_y() -> void:
	assert_eq(Direction.get_closest_direction(Vector2(0.1, -1.0)), Direction.UP)


func test_mostly_left_vector_maps_to_left() -> void:
	assert_eq(Direction.get_closest_direction(Vector2(-0.7, 0.3)), Direction.LEFT)


func test_all_directions_has_four_unique_entries() -> void:
	assert_eq(Direction.ALL_DIRECTIONS.size(), 4)
