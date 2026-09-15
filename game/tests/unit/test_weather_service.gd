extends GutTest
## Testes do WeatherService com clima aleatorio (sem rede).
## V2 com servico meteorologico real documentada em docs/decisions.md ADR-012.


func _make_service() -> WeatherService:
	var svc := WeatherService.new()
	add_child_autofree(svc)
	return svc


func test_initial_condition_is_valid() -> void:
	## current() devolve uma condicao valida desde o inicio.
	var svc := _make_service()
	var valid := ["clear", "clouds", "rain", "storm", "snow"]
	assert_has(valid, svc.current(), "condicao inicial deve ser valida")


func test_random_weather_returns_valid() -> void:
	## random_weather() devolve sempre uma condicao valida.
	var svc := _make_service()
	var valid := ["clear", "clouds", "rain", "storm", "snow"]
	for i in range(20):
		assert_has(valid, svc.random_weather(), "random_weather deve ser valido")


func test_fake_weather_env() -> void:
	## INSULANO_FAKE_WEATHER=rain forca a condicao sem rede.
	OS.set_environment("INSULANO_FAKE_WEATHER", "rain")
	var svc := _make_service()
	assert_eq(svc.current(), "rain", "FAKE_WEATHER deve ser respeitado")
	OS.set_environment("INSULANO_FAKE_WEATHER", "")


func test_distribution_has_clear_most_often() -> void:
	## Numa amostra de 200 chamadas, clear deve ser o mais frequente.
	var svc := _make_service()
	var counts := {"clear": 0, "clouds": 0, "rain": 0, "storm": 0, "snow": 0}
	for i in range(200):
		var c := svc.random_weather()
		if c in counts:
			counts[c] += 1
	assert_gt(counts["clear"], counts["rain"], "clear deve ser mais frequente que rain")
	assert_gt(counts["clouds"], counts["storm"], "clouds deve ser mais frequente que storm")
