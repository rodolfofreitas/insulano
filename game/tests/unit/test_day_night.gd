extends GutTest
## Testes de [DayNight] (tech_design.md §5): interpolacao de cor por hora,
## ponto medio, wrap-around nocturno e palette invalida.

## Palette minima com 3 pontos para os testes.
var _palette_minimal: Array = [
	{"hour": 0.0, "color": "#000000"},
	{"hour": 12.0, "color": "#ffffff"},
	{"hour": 24.0, "color": "#000000"},
]

## Palette real carregada do JSON do projecto.
var _palette_real: Array = []


func before_all() -> void:
	## Carregar palette real para os testes de wrap-around.
	var text := FileAccess.get_file_as_string("res://data/day_night_palette.json")
	var data: Variant = JSON.parse_string(text)
	if data is Array and not data.is_empty():
		_palette_real = data


## Cor na primeira paragem deve ser exactamente a cor definida.
func test_color_at_palette_point() -> void:
	var col := DayNight.color_for_hour(0.0, _palette_minimal)
	assert_eq(col, Color("#000000"), "hora 0.0 deve devolver cor da primeira entrada")


## Ponto medio entre hora 0 (preto) e hora 12 (branco) deve ser cinzento medio.
func test_midpoint_interpolation() -> void:
	var col := DayNight.color_for_hour(6.0, _palette_minimal)
	var expected := Color("#000000").lerp(Color("#ffffff"), 0.5)
	assert_almost_eq(col.r, expected.r, 0.01, "canal R deve ser medio")
	assert_almost_eq(col.g, expected.g, 0.01, "canal G deve ser medio")
	assert_almost_eq(col.b, expected.b, 0.01, "canal B deve ser medio")


## 23.99 deve ter cor quase igual a 0.0 (palette cíclica com ponto final = inicial).
## A palette real tem hora 22.0 com "#0d1130" como ultima entrada;
## 23.99 cai alem do ultimo ponto e devolve a cor da ultima entrada,
## que e igual a cor da primeira (hora 0.0). Diferenca por canal < 0.02.
func test_wrap_around() -> void:
	assert_false(_palette_real.is_empty(), "palette real deve estar carregada")
	var col_midnight := DayNight.color_for_hour(0.0, _palette_real)
	var col_late := DayNight.color_for_hour(23.99, _palette_real)
	assert_true(
		abs(col_midnight.r - col_late.r) < 0.02,
		"canal R: 23.99 e 0.0 devem ser quase iguais (diff < 0.02)"
	)
	assert_true(
		abs(col_midnight.g - col_late.g) < 0.02,
		"canal G: 23.99 e 0.0 devem ser quase iguais (diff < 0.02)"
	)
	assert_true(
		abs(col_midnight.b - col_late.b) < 0.02,
		"canal B: 23.99 e 0.0 devem ser quase iguais (diff < 0.02)"
	)


## Palette vazia deve devolver Color.WHITE.
func test_invalid_palette_returns_white() -> void:
	var col := DayNight.color_for_hour(12.0, [])
	assert_eq(col, Color.WHITE, "palette vazia deve devolver Color.WHITE")
