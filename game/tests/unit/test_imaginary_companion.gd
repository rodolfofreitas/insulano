extends GutTest
## Testes unitarios do ImaginaryCompanion: ciclo de vida, nome, estado.

const CompanionScript = preload("res://world/imaginary_companion.gd")

var companion: Node


func before_each() -> void:
	companion = CompanionScript.new()
	# Nao adicionar a scenetree para evitar _ready() com autoloads ausentes.
	companion.state = CompanionScript.State.ABSENT
	companion.companion_name = ""
	companion.companion_object = ""
	companion.days_together = 0


func after_each() -> void:
	if companion:
		companion.free()


## SOLIDAO=100 -> try_birth() -> state deve ser ALIVE.
func test_birth_when_lonely() -> void:
	companion.state = CompanionScript.State.ABSENT
	companion.try_birth()
	assert_eq(companion.state, CompanionScript.State.ALIVE, "Apos try_birth() state deve ser ALIVE")


## Nome nunca deve ser 'Wilson' -- risco legal Cast Away.
func test_no_wilson_name() -> void:
	for _i in range(100):
		companion.state = CompanionScript.State.ABSENT
		companion.try_birth()
		assert_ne(companion.companion_name, "Wilson", "Nome nao pode ser Wilson")
		companion.state = CompanionScript.State.ABSENT


## lose() -> state deve ser MOURNING.
func test_lose_triggers_mourning() -> void:
	companion.state = CompanionScript.State.ALIVE
	companion.lose()
	assert_eq(
		companion.state, CompanionScript.State.MOURNING, "Apos lose() state deve ser MOURNING"
	)


## end_mourning() -> state deve ser ABSENT.
func test_end_mourning_returns_absent() -> void:
	companion.state = CompanionScript.State.MOURNING
	companion.end_mourning()
	assert_eq(
		companion.state, CompanionScript.State.ABSENT, "Apos end_mourning() state deve ser ABSENT"
	)


## Dois try_birth() seguidos -- so nasce uma vez (segundo e ignorado).
func test_birth_only_when_absent() -> void:
	companion.state = CompanionScript.State.ABSENT
	companion.try_birth()
	var first_name: String = companion.companion_name
	companion.try_birth()
	assert_eq(
		companion.state, CompanionScript.State.ALIVE, "Segundo try_birth nao deve mudar estado"
	)
	assert_eq(companion.companion_name, first_name, "Segundo try_birth nao deve mudar o nome")


## lose() quando ABSENT -- nao deve mudar estado.
func test_lose_when_absent_does_nothing() -> void:
	companion.state = CompanionScript.State.ABSENT
	companion.lose()
	assert_eq(
		companion.state, CompanionScript.State.ABSENT, "lose() em ABSENT nao deve mudar estado"
	)


## is_alive() devolve true so quando ALIVE.
func test_is_alive_only_when_alive() -> void:
	companion.state = CompanionScript.State.ABSENT
	assert_false(companion.is_alive(), "ABSENT nao esta vivo")
	companion.state = CompanionScript.State.ALIVE
	assert_true(companion.is_alive(), "ALIVE esta vivo")
	companion.state = CompanionScript.State.MOURNING
	assert_false(companion.is_alive(), "MOURNING nao esta vivo")
