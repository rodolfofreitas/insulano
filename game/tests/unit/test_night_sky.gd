extends GutTest
## Testes de [NightSky] (T-204): seed fixa, alpha diurno, nocturno e crepusculo.


## Duas instancias geradas com seed 42 devem ter as mesmas posicoes.
func test_same_seed_same_stars() -> void:
	var a := NightSky.new()
	var b := NightSky.new()
	add_child(a)
	add_child(b)
	# _generate_stars e chamado em _ready via add_child
	assert_eq(a._stars.size(), b._stars.size(), "numero de estrelas deve ser igual")
	for i in range(a._stars.size()):
		assert_eq(
			a._stars[i],
			b._stars[i],
			"estrela %d deve ter a mesma posicao em ambas as instancias" % i
		)
	a.queue_free()
	b.queue_free()


## Alpha de dia (12h) deve ser 0.0.
func test_alpha_day() -> void:
	assert_eq(NightSky.sky_alpha_for_hour(12.0), 0.0, "alpha de dia deve ser 0.0")


## Alpha de noite (23h) deve ser 1.0.
func test_alpha_night() -> void:
	assert_eq(NightSky.sky_alpha_for_hour(23.0), 1.0, "alpha de noite deve ser 1.0")


## Alpha no crepusculo (19.5h) deve estar entre 0 e 1.
func test_alpha_twilight() -> void:
	var alpha := NightSky.sky_alpha_for_hour(19.5)
	var msg := "alpha no crepusculo deve ser entre 0 e 1 (foi %.3f)" % alpha
	assert_true(alpha > 0.0 and alpha < 1.0, msg)
