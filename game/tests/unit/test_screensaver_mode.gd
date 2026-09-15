extends GutTest
## Testes unitarios do ScreensaverMode: interpretacao de argumentos de linha de comandos.

const ScreensaverScript = preload("res://app/screensaver_mode.gd")

var screensaver: Node


func before_each() -> void:
	screensaver = ScreensaverScript.new()
	add_child_autofree(screensaver)


## '--screensaver' activa o modo protector de ecra.
func test_parse_screensaver_arg() -> void:
	screensaver._parse_from(["--screensaver"])
	assert_eq(
		screensaver.mode(), "screensaver", "Argumento --screensaver deve activar modo 'screensaver'"
	)


## '-s' e o alias curto para --screensaver.
func test_parse_screensaver_short_arg() -> void:
	screensaver._parse_from(["-s"])
	assert_eq(screensaver.mode(), "screensaver", "Argumento -s deve activar modo 'screensaver'")


## '--windowed' activa o modo janela.
func test_parse_windowed_arg() -> void:
	screensaver._parse_from(["--windowed"])
	assert_eq(screensaver.mode(), "window", "Argumento --windowed deve activar modo 'window'")


## Sem argumentos o modo por omissao e 'window'.
func test_parse_no_arg() -> void:
	screensaver._parse_from([])
	assert_eq(screensaver.mode(), "window", "Sem argumentos o modo deve ser 'window'")


## '--credits' activa o modo de creditos.
func test_parse_credits_arg() -> void:
	screensaver._parse_from(["--credits"])
	assert_eq(screensaver.mode(), "credits", "Argumento --credits deve activar modo 'credits'")
