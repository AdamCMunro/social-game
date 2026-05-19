extends CanvasLayer

var money_rgb = Color.from_rgba8(107, 255, 106)
var health_rgb = Color.from_rgba8(255, 0, 121)
var followers_rgb = Color.from_rgba8(0, 114, 255)
var energy_rgb = Color.from_rgba8(236, 227, 71)

var money_invis = Color.from_rgba8(107, 255, 106, 0)
var health_invis = Color.from_rgba8(255, 0, 121, 0)
var followers_invis = Color.from_rgba8(0, 114, 255, 0)
var energy_invis = Color.from_rgba8(236, 227, 71, 0)

var colour : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_pulse()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _show_money():
	visible = true
	$ColorRect.material.set_shader_parameter("border_color", money_rgb)
	colour = "money"
	
func _show_health():
	visible = true
	$ColorRect.material.set_shader_parameter("border_color", health_rgb)
	colour = "health"
	
func _show_followers():
	visible = true
	$ColorRect.material.set_shader_parameter("border_color", followers_rgb)
	colour = "followers"

func _show_energy():
	visible = true
	$ColorRect.material.set_shader_parameter("border_color", energy_rgb)
	colour = "energy"
	
func _pulse():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()
	
	tween.tween_property($ColorRect.material, "shader_parameter/outer_radius", 1.7, 0.5)
	tween.tween_property($ColorRect.material, "shader_parameter/outer_radius", 1.7, 0.5)
	tween.tween_property($ColorRect.material, "shader_parameter/outer_radius", 2, 0.5)
	tween.tween_property($ColorRect.material, "shader_parameter/outer_radius", 2, 0.5)

func _reduce_visibility():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	match colour:
		"money":
			tween.tween_property($ColorRect.material, "shader_parameter/border_color", money_invis, 0.2)
		"health":
			tween.tween_property($ColorRect.material, "shader_parameter/border_color", health_invis, 0.2)
		"followers":
			tween.tween_property($ColorRect.material, "shader_parameter/border_color", followers_invis, 0.2)
		"energy":
			tween.tween_property($ColorRect.material, "shader_parameter/border_color", energy_invis, 0.2)
		_:
			tween.tween_property($ColorRect.material, "shader_parameter/border_color", energy_invis, 0.0)
			
	return tween
	
