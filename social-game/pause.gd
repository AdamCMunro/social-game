extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2
@onready var options_arr = [$PauseBody/Resume, $PauseBody/Settings, $PauseBody/Quit]
@onready var main = get_parent()


var option_hovered = false
var option_selected = -1

var black = '#000000'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_prepare_drift()
	scale = Vector2.ZERO
	position = viewport_centre
	
	for n in options_arr:
	
		n.mouse_entered.connect(_on_option_mouse_entered.bind(n))
		n.mouse_exited.connect(_on_option_mouse_exited.bind(n))


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
	
	for n in options_arr:
		_deselect(n)
		
	option_selected = -1
	
	return tween


func _on_option_mouse_entered(area) -> void:
	if options_arr[option_selected] != area:
		option_hovered = true
		$PauseBody/Selection.visible = true
		$PauseBody/Selection.position = area.position
		_add_wave(area.get_node("Label"))


func _on_option_mouse_exited(area) -> void:
	if options_arr[option_selected] != area:
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

func _on_resume_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if option_selected != 0:
				option_selected = 0
				option_hovered = false
				_select(options_arr[0])
			else:
				_animate_button(options_arr[0])
				_hide_pause()

func _on_quit_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if option_selected != 2:
				option_selected = 2
				option_hovered = false
				_select(options_arr[2])
			else:
				_animate_button(options_arr[2])
				await _hide_pause().finished
				visible = false
				_quit()

func _select(button):
	button.get_node("ColorRect").visible = true
	_transition_text(button.get_node("Label"))
	for n in options_arr:
		if n == button:
			continue
		_deselect(n)
	
func _animate_button(button):
	pass
	
func _quit():
	for n in main.get_children():
		if n.name == "Feed":
			main.get_node("Player/StatBlock").position = n.stat_block_pos
			n.queue_free()
		elif n.name == "Messenger" or n.name == "Economy":
			n.queue_free()
	
	for n in main.buttons:
		n.visible = true
		
	main.get_node("Player").visible = false
	
	
func _deselect(button):
	button.get_node("ColorRect").visible = false
	button.get_node("Label").text = button.name
	
func _transition_text(label):
	var tween = create_tween()
	
	tween.tween_property(label, "visible_ratio", 0.0, 0.05)
	
	await tween.finished
	
	var tween2 = create_tween()
	
	label.text = str("[color=", black, "]Are you sure?[/color]")
	tween2.tween_property(label, "visible_ratio", 1.0, 0.1)

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
