extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2

var option_hovered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_prepare_drift()
	scale = Vector2.ZERO
	position = viewport_centre
	
	$PauseBody/Resume.mouse_entered.connect(_on_option_mouse_entered.bind($PauseBody/Resume))
	$PauseBody/Resume.mouse_exited.connect(_on_option_mouse_exited.bind($PauseBody/Resume))
	
	$PauseBody/Settings.mouse_entered.connect(_on_option_mouse_entered.bind($PauseBody/Settings))
	$PauseBody/Settings.mouse_exited.connect(_on_option_mouse_exited.bind($PauseBody/Settings))
	
	$PauseBody/Quit.mouse_entered.connect(_on_option_mouse_entered.bind($PauseBody/Quit))
	$PauseBody/Quit.mouse_exited.connect(_on_option_mouse_exited.bind($PauseBody/Quit))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if option_hovered:
		$PauseBody/Selection.visible = true
	else:
		$PauseBody/Selection.visible = false
	
	if visible:
		_drift(delta)
	else:
		position = viewport_centre
		rotation = 0

func _show_pause():
	visible = true
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.05)
	tween.tween_property(self, "scale", Vector2(1,1), 0.06)
	
func _hide_pause():
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.05)
	tween.tween_property(self, "scale", Vector2(0,0), 0.06)
	
	return tween


func _on_option_mouse_entered(area) -> void:
	option_hovered = true
	$PauseBody/Selection.visible = true
	$PauseBody/Selection.position = area.position
	_add_wave(area.get_node("Label"))


func _on_option_mouse_exited(area) -> void:
	option_hovered = false
	$PauseBody/Selection.visible = false
	_remove_wave(area.get_node("Label"))
	
func _add_wave(label):
	label.text = str("[wave amp=11.0 freq=2.5 connected=0]", label.text, "[/wave]")
	
func _remove_wave(label):
	if label.text.contains("Resume"):
		label.text = "Resume"
	elif label.text.contains("Settings"):
		label.text = "Settings"
	else:
		label.text = "Quit"

#drift stuff

var noise = FastNoiseLite.new()
var time = 0.0

var speed = 0.6
var amplitude = 10.0 # How far it drifts
var rotation_amplitude = 5.0 # How much it tilts

func _prepare_drift():
	noise.seed = randi()
	noise.frequency = 0.1
	
func _drift(delta):
	time += delta * speed

	var ox = noise.get_noise_1d(time) * amplitude
	var oy = noise.get_noise_1d(time + 100) * amplitude 
	var ang = noise.get_noise_1d(time + 200) * rotation_amplitude

	position = Vector2(viewport_centre.x + ox, viewport_centre.y + oy)
	rotation_degrees = ang
