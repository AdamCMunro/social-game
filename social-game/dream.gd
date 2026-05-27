extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2
@onready var main = get_parent()
@onready var pause = main.get_node("Pause")
@onready var player = main.get_node("Player")
@onready var hand = player.get_node("Hand")

var dream_data := []
var message_index = 0
var text_tween : Tween
var hint_tween : Tween
var card_remove_tween : Tween
var text_y
var hint_y
var hand_pos
var choosing_text_y
var choosing_hint_y

var picked_up_card

var paused = false
var message_visible = false
var hint_delay = 5000
var last_message_time

var choosing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dream_data = _json_decode(str("res://daily_files/",main.current_day ,"/dream.json"))
	
	player.visible = true
	player.get_node("StatBlock").visible = false
	
	$CardRemovalTemplate.position = viewport_centre
	
	$Label.position = viewport_centre
	text_y = viewport_centre.y
	choosing_text_y =  text_y - 300
	
	$Hint.position = viewport_centre
	$Hint.position.y += 100
	hint_y = $Hint.position.y
	choosing_hint_y = hint_y - 350
	
	hand_pos = hand.position
	
	_populate_labels(dream_data[message_index].text)
	_clear_labels()
	await get_tree().create_timer(dream_data[message_index].delay).timeout
	_progress_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("advance_dream") and not choosing and not paused:
		$Hint.visible = false
		if $Label/MainLabel.visible_ratio == 1:
			message_index += 1
			_clear_labels()
			if dream_data[message_index].choice:
				choosing = true
				_show_hand()
				_show_card_remove()
			_populate_labels(dream_data[message_index].text)
			await get_tree().create_timer(dream_data[message_index].delay).timeout
			_progress_text()
		else:
			if text_tween and text_tween.is_running():
				text_tween.kill()
			for n in $Label.get_children():
				n.visible_ratio = 1
	
	if Input.is_action_just_pressed("pause"):
		if not paused:
			await _hide_for_pause().finished
			paused = true
			pause._show_pause()
		else:
			await pause._hide_pause().finished
			_show_for_resume()
			paused = false
				
	if $Label/MainLabel.visible_ratio == 1 and not message_visible:
		message_visible = true
		last_message_time = Time.get_ticks_msec()
	elif $Label/MainLabel.visible_ratio != 1:
		message_visible = false
		
	if message_visible and Time.get_ticks_msec() - last_message_time >= hint_delay and not $Hint.visible and not choosing:
		_pulse_hint()
		
	
func _progress_text():
	if text_tween and text_tween.is_running():
		text_tween.kill()
	
	if $Label/MainLabel.visible_ratio == 1:
		return
	
	text_tween = create_tween()
	var text = $Label/MainLabel.text
	var timing = 0.18 * sqrt(text.length())
	
	for n in $Label.get_children():
		text_tween.parallel().tween_property(n, "visible_ratio", 1, timing)

func _show_hand():
	
	$Hint.position.y = choosing_hint_y
	$Label.position.y = choosing_text_y
	
	await get_tree().create_timer(2).timeout
	
	player._populate_hand()

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

func _show_card_remove():
	var sprite = $CardRemovalTemplate/Sprite2D
	
	if card_remove_tween and card_remove_tween.is_running():
		card_remove_tween.kill()
		
	card_remove_tween = create_tween()
	
	card_remove_tween.set_ease(Tween.EASE_IN_OUT)
	card_remove_tween.set_trans(Tween.TRANS_SINE)
	card_remove_tween.set_loops()
	
	sprite.modulate.a = 0
	$CardRemovalTemplate.visible = true
	
	card_remove_tween.tween_property(sprite, "modulate:a", 1, 1)
	card_remove_tween.tween_property(sprite, "modulate:a", 1, 1)
	card_remove_tween.tween_property(sprite, "modulate:a", 0.7, 0.7)
	card_remove_tween.tween_property(sprite, "modulate:a", 1, 0.9)
	card_remove_tween.tween_property(sprite, "modulate:a", 0.8, 0.7)
	card_remove_tween.tween_property(sprite, "modulate:a", 1, 0.9)
	card_remove_tween.tween_property(sprite, "modulate:a", 0.6, 1)
	card_remove_tween.tween_property(sprite, "modulate:a", 0.6, 1)

func _physics_process(delta: float) -> void:
	for area in $CardRemovalTemplate.get_overlapping_areas():
		var card = area.get_parent()
		if card.get_name().begins_with("Card") and picked_up_card and card == picked_up_card:
			var x_diff = abs(card.position.x - $CardRemovalTemplate.position.x)
			var y_diff = abs(card.position.y - $CardRemovalTemplate.position.y)
			
			if x_diff <= 75 and y_diff <= 75:
				card.removal_hover = true
			else:
				card.removal_hover = false

func _snap_for_remove(card):
	var x_diff = card.position.x - $CardRemovalTemplate.position.x
	var y_diff = card.position.y - $CardRemovalTemplate.position.y
	
	var x_offset
	var y_offset
	
	if x_diff > 0:
		x_offset = -5
	elif x_diff < 0:
		x_offset = 5
	else:
		x_offset = 0
	
	if y_diff > 0:
		y_offset = -5
	elif y_diff < 0:
		y_offset = 5
	else:
		y_offset = 0
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(card, "position", Vector2(viewport_centre.x + x_offset, viewport_centre.y + y_offset), 0.2)
	tween.tween_property(card, "position", viewport_centre, 0.15)
	
	player._hide_hand()
	

func _hide_for_pause():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	if choosing:
		tween.tween_property(hand, "position:y", hand_pos.y - 20, 0.1)
		tween.tween_property(hand, "position:y", 1000, 0.05)
		
		card_remove_tween.kill()
		tween.parallel().tween_property($CardRemovalTemplate/Sprite2D, "modulate:a", 0, 0.3)
		
		tween.parallel().tween_property($Label, "position:y", choosing_text_y + 20, 0.05)
		tween.parallel().tween_property($Hint, "position:y", choosing_hint_y + 20, 0.05)
		
		tween.tween_property($Label, "position:y", -100, 0.05)
		tween.parallel().tween_property($Hint, "position:y", -100, 0.05)
	else:
		tween.tween_property($Label, "position:y", text_y + 20, 0.05)
		tween.parallel().tween_property($Hint, "position:y", hint_y - 20, 0.05)
		
		tween.tween_property($Label, "position:y", -100, 0.05)
		tween.parallel().tween_property($Hint, "position:y", 1000, 0.05)
	
	return tween
	
func _show_for_resume():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	if choosing:
		tween.tween_property($Label, "position:y", choosing_text_y + 20, 0.05)
		tween.parallel().tween_property($Hint, "position:y", choosing_hint_y + 20, 0.05)
		
		_show_card_remove()
		
		tween.tween_property($Label, "position:y", choosing_text_y, 0.05)
		tween.parallel().tween_property($Hint, "position:y", choosing_hint_y, 0.05)
		
		tween.tween_property(hand, "position:y", hand_pos.y - 20, 0.1)
		tween.tween_property(hand, "position:y", hand_pos.y, 0.05)
	else:
		tween.tween_property($Label, "position:y", text_y + 20, 0.05)
		tween.parallel().tween_property($Hint, "position:y", hint_y - 20, 0.05)
		
		tween.tween_property($Label, "position:y", text_y, 0.05)
		tween.parallel().tween_property($Hint, "position:y", hint_y, 0.05)
	
	return tween
