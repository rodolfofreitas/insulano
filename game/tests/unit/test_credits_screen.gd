extends GutTest
## Testes unitarios do CreditsScreen: conteudo dos creditos e auto-hide.

const CreditsScript = preload("res://app/credits_screen.gd")

var _credits: CreditsScreen


func before_each() -> void:
	_credits = CreditsScript.new()
	add_child_autofree(_credits)


## O texto dos creditos contem 'Antifarea' (sprites do personagem).
func test_credits_contain_antifarea() -> void:
	var text: String = _credits._build_text()
	assert_true(text.contains("Antifarea"), "Creditos devem conter 'Antifarea'")


## O texto dos creditos contem 'Majadroid' (tileset da ilha).
func test_credits_contain_majadroid() -> void:
	var text: String = _credits._build_text()
	assert_true(text.contains("Majadroid"), "Creditos devem conter 'Majadroid'")


## O texto dos creditos contem 'Godot' (motor).
func test_credits_contain_godot() -> void:
	var text: String = _credits._build_text()
	assert_true(text.contains("Godot"), "Creditos devem conter 'Godot'")


## O texto dos creditos contem 'MIT' (licenca).
func test_credits_contain_mit() -> void:
	var text: String = _credits._build_text()
	assert_true(text.contains("MIT"), "Creditos devem conter 'MIT'")


## Com auto_hide=true, apos 5s o ecra esconde-se automaticamente.
func test_auto_hide_after_5s() -> void:
	_credits.show_credits(true)
	assert_true(_credits.visible, "Creditos devem estar visiveis apos show_credits()")
	## Simular mais de 5 segundos de delta
	_credits._process(5.1)
	assert_false(_credits.visible, "Creditos devem esconder-se apos 5s com auto_hide=true")
