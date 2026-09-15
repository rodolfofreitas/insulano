class_name CampfireObject
extends Node2D
## Fogueira com particulas CPUParticles2D e luz nocturna PointLight2D.
## Sinais: lit() quando acende, extinguished() quando apaga.
## Uso: campfire.ignite() para acender, campfire.extinguish() para apagar.

signal lit
signal extinguished

const FLAME_COLOR_INNER := Color(1.0, 0.6, 0.1, 0.9)  # laranja quente
const FLAME_COLOR_OUTER := Color(1.0, 0.2, 0.0, 0.0)  # vermelho transparente
const SMOKE_COLOR := Color(0.4, 0.4, 0.4, 0.3)

var _flames: CPUParticles2D
var _smoke: CPUParticles2D
var _light: PointLight2D
var _burning: bool = false


func _ready() -> void:
	_setup_flames()
	_setup_smoke()
	_setup_light()
	extinguish()


## Acende a fogueira, activa particulas e luz nocturna. Emite sinal lit.
func ignite() -> void:
	if _burning:
		return
	_burning = true
	_flames.emitting = true
	_smoke.emitting = true
	_update_light()
	lit.emit()


## Apaga a fogueira, desactiva particulas e luz. Emite sinal extinguished.
func extinguish() -> void:
	_burning = false
	_flames.emitting = false
	_smoke.emitting = false
	_light.enabled = false
	extinguished.emit()


## Devolve true se a fogueira estiver acesa.
func is_burning() -> bool:
	return _burning


func _update_light() -> void:
	# Luz so de noite (Clock.period() != 'dia')
	if not _burning:
		return
	var is_night := true
	if is_inside_tree() and has_node("/root/Clock"):
		var period: String = Clock.period()
		is_night = period in ["noite", "madrugada", "anoitecer"]
	_light.enabled = is_night


func _setup_flames() -> void:
	_flames = CPUParticles2D.new()
	_flames.amount = 40
	_flames.lifetime = 0.8
	_flames.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_flames.emission_sphere_radius = 6.0
	_flames.direction = Vector2(0, -1)
	_flames.spread = 25.0
	_flames.gravity = Vector2(0, -60)
	_flames.initial_velocity_min = 20.0
	_flames.initial_velocity_max = 45.0
	_flames.scale_amount_min = 0.3
	_flames.scale_amount_max = 0.8
	_flames.color = FLAME_COLOR_INNER
	add_child(_flames)


func _setup_smoke() -> void:
	_smoke = CPUParticles2D.new()
	_smoke.amount = 15
	_smoke.lifetime = 2.0
	_smoke.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_smoke.emission_sphere_radius = 4.0
	_smoke.direction = Vector2(0, -1)
	_smoke.spread = 15.0
	_smoke.gravity = Vector2(5, -30)
	_smoke.initial_velocity_min = 10.0
	_smoke.initial_velocity_max = 25.0
	_smoke.scale_amount_min = 0.5
	_smoke.scale_amount_max = 1.5
	_smoke.color = SMOKE_COLOR
	add_child(_smoke)


func _setup_light() -> void:
	_light = PointLight2D.new()
	_light.energy = 0.8
	_light.texture_scale = 2.0
	_light.color = Color(1.0, 0.6, 0.2, 1.0)
	add_child(_light)
