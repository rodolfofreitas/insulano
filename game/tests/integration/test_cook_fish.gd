extends GutTest
## Testes de integracao para CookFishAction (T-120): verificar que a fome baixa
## 60pts apos ritual completo, que FishingAction nunca chama replenish()
## directamente, e que CookFishAction devolve FAILURE sem peixe.


## Cria uma Need de fome com um valor inicial dado.
func _make_hunger(current_pct: float) -> Need:
	var need := Need.new()
	need.name = "hunger"
	need.max_value = 100
	need.current_value = current_pct
	return need


## test_cook_fish_reduces_hunger_60pts: com has_fish=true e has_campfire=true,
## apos COOK_DURATION ticks, hunger subiu 60pts.
func test_cook_fish_reduces_hunger_60pts() -> void:
	var action: CookFishAction = autofree(CookFishAction.new())
	add_child_autofree(action)

	var character := Character.new()
	character.needs = []
	var hunger := _make_hunger(20.0)
	character.needs.append(hunger)
	add_child_autofree(character)

	var blackboard := Blackboard.new()
	add_child_autofree(blackboard)
	blackboard.set_value("has_fish", true)
	blackboard.set_value("has_campfire", true)

	var before_pct := hunger.get_percentage()

	# Simular COOK_DURATION directamente no timer interno
	action._timer = CookFishAction.COOK_DURATION
	var result := action.tick(character, blackboard)

	assert_eq(result, action.SUCCESS, "deve devolver SUCCESS apos COOK_DURATION")
	var after_pct := hunger.get_percentage()
	assert_almost_eq(after_pct, before_pct + 60.0, 0.01, "hunger deve subir 60pts apos cozinhar")
	assert_false(blackboard.get_value("has_fish", false), "has_fish deve ser false apos comer")


## test_raw_fish_never_eaten: FishingAction nunca chama increase_percent() (replenish)
## directamente - verifica via analise estatica do codigo fonte.
func test_raw_fish_never_eaten() -> void:
	var path := "res://beehave/fishing_action.gd"
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "fishing_action.gd deve existir")
	if file == null:
		return
	var source := file.get_as_text()
	file.close()
	assert_false(
		"increase_percent" in source or "replenish" in source,
		"FishingAction nao deve chamar increase_percent nem replenish directamente"
	)


## test_no_fish_no_cook: CookFishAction devolve FAILURE quando has_fish=false.
func test_no_fish_no_cook() -> void:
	var action: CookFishAction = autofree(CookFishAction.new())
	add_child_autofree(action)

	var character := Character.new()
	character.needs = []
	add_child_autofree(character)

	var blackboard := Blackboard.new()
	add_child_autofree(blackboard)
	blackboard.set_value("has_fish", false)
	blackboard.set_value("has_campfire", true)

	var result := action.tick(character, blackboard)
	assert_eq(result, action.FAILURE, "sem peixe deve devolver FAILURE")


## test_no_campfire_no_cook: CookFishAction devolve FAILURE quando has_campfire=false.
func test_no_campfire_no_cook() -> void:
	var action: CookFishAction = autofree(CookFishAction.new())
	add_child_autofree(action)

	var character := Character.new()
	character.needs = []
	add_child_autofree(character)

	var blackboard := Blackboard.new()
	add_child_autofree(blackboard)
	blackboard.set_value("has_fish", true)
	blackboard.set_value("has_campfire", false)

	var result := action.tick(character, blackboard)
	assert_eq(result, action.FAILURE, "sem fogueira deve devolver FAILURE")
