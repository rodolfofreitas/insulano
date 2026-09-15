extends GutTest
## Testes puros de [WeatherService]: estado inicial, parsing de respostas
## wttr.in sem rede. Fixtures gravadas em game/tests/fixtures/wttr_*.json
## (curl 'https://wttr.in/Lisbon?format=j1' -o wttr_sol.json em 2026-09-15).

const SOL_FIXTURE := "res://tests/fixtures/wttr_sol.json"
const CHUVA_FIXTURE := "res://tests/fixtures/wttr_chuva.json"
const TROVOADA_FIXTURE := "res://tests/fixtures/wttr_trovoada.json"


func _read_fixture(path: String) -> PackedByteArray:
	return FileAccess.get_file_as_bytes(path)


func _make_service() -> WeatherService:
	var svc := WeatherService.new()
	add_child_autofree(svc)
	return svc


func test_disabled_no_http() -> void:
	## Com insulano/weather/enabled=false (defeito), _http nao e criado.
	var svc := _make_service()
	assert_null(svc._http, "_http deve ser null quando disabled")


func test_unknown_before_response() -> void:
	## current() devolve 'unknown' antes de qualquer resposta HTTP.
	var svc := _make_service()
	assert_eq(svc.current(), "unknown")


func test_parse_clear() -> void:
	## weatherCode=113 mapeia para 'clear'.
	var svc := _make_service()
	var body := _read_fixture(SOL_FIXTURE)
	assert_gt(body.size(), 0, "fixture wttr_sol.json deve existir e nao estar vazia")
	var result := svc.parse_response(body)
	assert_eq(result, "clear")


func test_parse_rain() -> void:
	## weatherCode=302 mapeia para 'rain'.
	var svc := _make_service()
	var body := _read_fixture(CHUVA_FIXTURE)
	assert_gt(body.size(), 0, "fixture wttr_chuva.json deve existir e nao estar vazia")
	var result := svc.parse_response(body)
	assert_eq(result, "rain")


func test_parse_storm() -> void:
	## weatherCode=389 mapeia para 'storm'.
	var svc := _make_service()
	var body := _read_fixture(TROVOADA_FIXTURE)
	assert_gt(body.size(), 0, "fixture wttr_trovoada.json deve existir e nao estar vazia")
	var result := svc.parse_response(body)
	assert_eq(result, "storm")
