class_name CreditsScreen
extends CanvasLayer
## Ecra de creditos com atribuicoes obrigatorias.
## Aparece ao arrancar com --credits ou durante 5s no inicio de cada hora em modo screensaver.

const CREDITS_PATH: String = "res://data/credits.json"
const DISPLAY_DURATION_S: float = 5.0

var _visible_timer: float = 0.0
var _auto_hide: bool = false


func _ready() -> void:
	_build_ui()
	hide()


## Mostra o ecra de creditos. Se auto_hide=true, esconde-se automaticamente apos 5s.
func show_credits(auto_hide: bool = false) -> void:
	_auto_hide = auto_hide
	_visible_timer = 0.0
	show()


func _process(delta: float) -> void:
	if not visible:
		return
	if _auto_hide:
		_visible_timer += delta
		if _visible_timer >= DISPLAY_DURATION_S:
			hide()


func _build_ui() -> void:
	# Fundo semitransparente
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	# Label de creditos
	var label := RichTextLabel.new()
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.custom_minimum_size = Vector2(800, 400)
	label.bbcode_enabled = true
	label.text = _build_text()
	label.add_theme_font_size_override("normal_font_size", 18)
	add_child(label)


func _build_text() -> String:
	var text := "[center][b]Insulano[/b]\n\n[b]Creditos[/b]\n\n"
	var credits := _load_credits()
	var last_cat := ""
	for entry in credits:
		var cat: String = entry.get("category", "")
		if cat != last_cat:
			text += "[b]%s[/b]\n" % cat
			last_cat = cat
		var asset: String = entry.get("asset", "")
		var author: String = entry.get("name", "")
		var lic: String = entry.get("license", "")
		text += "%s -- %s (%s)\n" % [asset, author, lic]
	text += "[/center]"
	return text


func _load_credits() -> Array:
	var text := FileAccess.get_file_as_string(CREDITS_PATH)
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return []
	var data: Variant = parser.get_data()
	if not data is Dictionary:
		return []
	return data.get("credits", [])
