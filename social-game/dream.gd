extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2
@onready var main = get_parent()

var dream_data := []
var message_index = 0
var tween : Tween
var hint_tween : Tween

var message_visible = false
var hint_delay = 5000
var last_message_time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dream_data = _json_decode(str("res://daily_files/",main.current_day ,"/dream.json"))
	$Label.position = viewport_centre
	$Hint.position = viewport_centre
	$Hint.position.y += 100
	_populate_labels(dream_data[message_index].text)
	_clear_labels()
	await get_tree().create_timer(dream_data[message_index].delay).timeout
	_progress_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("advance_dream"):
		$Hint.visible = false
		if $Label/MainLabel.visible_ratio == 1:
			message_index += 1
			_clear_labels()
			_populate_labels(dream_data[message_index].text)
			await get_tree().create_timer(dream_data[message_index].delay).timeout
			_progress_text()
		else:
			if tween and tween.is_running():
				tween.kill()
			for n in $Label.get_children():
				n.visible_ratio = 1
				
	if $Label/MainLabel.visible_ratio == 1 and not message_visible:
		message_visible = true
		last_message_time = Time.get_ticks_msec()
	elif $Label/MainLabel.visible_ratio != 1:
		message_visible = false
		
	if message_visible and Time.get_ticks_msec() - last_message_time >= hint_delay and not $Hint.visible:
		_pulse_hint()
		
	
func _progress_text():
	if tween and tween.is_running():
		tween.kill()
	
	if $Label/MainLabel.visible_ratio == 1:
		return
	
	tween = create_tween()
	var text = $Label/MainLabel.text
	var timing = 0.18 * sqrt(text.length())
	
	for n in $Label.get_children():
		tween.parallel().tween_property(n, "visible_ratio", 1, timing)

func _clear_labels():
	for n in $Label.get_children():
		n.visible_ratio = 0
		
func _populate_labels(text):
	for n in $Label.get_children():
		n.text = str("[wave amp=11.0 freq=2.5 connected=0]", text, "[/wave]")

func _json_decode(file_path: String) -> Array:
	var content = FileAccess.get_file_as_string(file_path)
	var data = JSON.parse_string(content)
	
	if typeof(data) == TYPE_ARRAY:
		return data as Array
		
	push_error("Failed to parse JSON, or the root is not an Array.")
	return []
	
func _pulse_hint():
	if hint_tween and hint_tween.is_running():
		hint_tween.kill()
		
	hint_tween = create_tween()
	
	hint_tween.set_ease(Tween.EASE_IN_OUT)
	hint_tween.set_trans(Tween.TRANS_SINE)
	hint_tween.set_loops()
	
	$Hint.modulate.a = 0
	$Hint.visible = true
	
	hint_tween.tween_property($Hint, "modulate:a", 1, 2)
	hint_tween.tween_property($Hint, "modulate:a", 1, 2)
	hint_tween.tween_property($Hint, "modulate:a", 0, 2)
	hint_tween.tween_property($Hint, "modulate:a", 0, 2)
