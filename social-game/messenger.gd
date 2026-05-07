extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2
@onready var option1 = $MessengerBody/Option1
@onready var option2 = $MessengerBody/Option2
@onready var option3 = $MessengerBody/Option3
@onready var option_arr = [option1, option2, option3]
@onready var sending_text = $MessengerBody/SendingText
@onready var container_position = $Messages/Container.position
@onready var current_container_position = $Messages/Container.position

@onready var player_message_scene = preload("res://player_message.tscn")
@onready var message_scene = preload("res://message.tscn")

@export var mac_scroll_speed = 7.5
@export var win_scroll_speed = 22.5
var velocity: float
var friction = 0.8
var smooth_speed = 0.5
var return_speed = 0.2
var upper_limit
var lower_limit

var line_height = 24.75

var option_position = []

var typing = false
var repeat = false
var scrolling = false
var scroll_return = false
var messages_moving = false

var prev_message
var prev_message_type = ""
var chosen_option_text
var next_message_index

var message_arr = []
var message_history_arr = []

var new_seed_vaue

var sender_name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MessengerBody.position = viewport_centre
	$Messages.position = viewport_centre
	
	for n in option_arr:
		option_position.append(n.position)
		n.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Messages/Container.size.x = 561.5
	$Messages/Container.position.x = 299.25
	
	lower_limit = current_container_position.y
	upper_limit = current_container_position.y + $Messages/Container.size.y - 1200
	
	if scrolling and not messages_moving:
		$Messages/Container.position.y = lerp($Messages/Container.position.y, $Messages/Container.position.y + (velocity * friction), smooth_speed)

func _option1():
	chosen_option_text = option1.full_text
	new_seed_vaue = "1"
	_option_chosen()
	
func _option2():
	chosen_option_text = option2.full_text
	new_seed_vaue = "2"
	_option_chosen()
	
func _option3():
	chosen_option_text = option3.full_text
	new_seed_vaue = "3"
	_option_chosen()

func _option_chosen() -> void:
	
	await _hide_options()
	
	sending_text.visible = true
	sending_text.visible_ratio = 0
	_show_sending_text()
	typing = true


func _hide_option(option):
	var option_tween = create_tween()
		
	option_tween.tween_property(option, "position", Vector2(option.position.x, option.position.y - 15), 0.15)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	option_tween.tween_property(option, "position", Vector2(option.position.x, option.position.y + 500), 0.1)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	
	return option_tween

func _hide_options():
	for i in range(option_arr.size()):
		await _hide_option(option_arr[i]).finished
		option_arr[i].visible = false
		option_arr[i].position = option_position[i]
	sending_text.text = "Type random letters to send"
	return true

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if typing:
			if sending_text.text == "Type random letters to send" and sending_text.visible_ratio == 1:
				sending_text.visible_ratio = 0
				sending_text.text = chosen_option_text
			elif sending_text.text != "Type random letters to send" and sending_text.visible_characters < sending_text.text.length() - 1:
				sending_text.visible_characters += 1
			elif sending_text.text != "Type random letters to send":
				typing = false
				sending_text.visible = false
				_send_message(sending_text.text)
				await get_tree().create_timer(0.5).timeout
				for n in $Contacts.contacts:
					if n.contact_name == sender_name:
						message_history_arr = _json_decode(str("user://chat_logs/history/", sender_name, ".json"))
						var seed = str(message_history_arr[message_history_arr.size() - 1].seed, new_seed_vaue)
						message_history_arr.append({"sender":"player", "body":sending_text.text, "choice":false, "seed":seed})
						n._save_json(str("user://chat_logs/history/", sender_name, ".json"), message_history_arr)
						n._progress_chat()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_scroll_messages(win_scroll_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_scroll_messages(-win_scroll_speed)
	elif event is InputEventPanGesture:
		if event.delta.y > 0: 
			_scroll_messages(-mac_scroll_speed)
		elif event.delta.y < 0:
			_scroll_messages(mac_scroll_speed)
	else:
		scrolling = false

	
	
func _scroll_messages(amount):
	if (upper_limit - lower_limit) > 0:
		var scroll_position = $Messages/Container.position.y
		scrolling = true
		if scroll_position + velocity + amount <= lower_limit:
			$Messages/Container.position.y = lower_limit
			velocity = 0
		elif scroll_position + velocity + amount >= upper_limit:
			$Messages/Container.position.y = upper_limit
			velocity = 0
		else:
			velocity += amount


func _show_sending_text():
	var tween = create_tween()
	
	tween.tween_property(sending_text, "visible_ratio", 1, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)

func _send_message(message):
	var new_message = player_message_scene.instantiate()
	new_message.get_node("TextContainer/Message").text = message
	$Messages/Container.add_child(new_message)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await _animate_messages(new_message.size.y + 3)
	prev_message_type = "sent"
	prev_message = new_message
	
func _show_typing(time):
	$Messages/TypingIndicator.visible = true
	await get_tree().create_timer(time).timeout
	$Messages/TypingIndicator.visible = false
	
func _recieve_message(message):
	var new_message = message_scene.instantiate()
	new_message.get_node("TextContainer/Message").text = message
	$Messages/Container.add_child(new_message)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	if repeat:
		prev_message.get_node("Sprite").visible = false
		prev_message.get_node("RepeatSprite").visible = true
		repeat = false
	await _animate_messages(new_message.size.y + 3)
	prev_message_type = "recieved"
	prev_message = new_message
	print("recieving: ", message)
	return true

func _animate_messages(offset):
	var tween = create_tween()
	messages_moving = true
	
	current_container_position.y = container_position.y - offset
	
	tween.tween_property($Messages/Container, "size:y", (offset + 10), 0.15).as_relative()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property($Messages/Container, "position:y", -(offset + 10), 0.15).as_relative()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property($Messages/Container, "size:y", -10, 0.2).as_relative()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property($Messages/Container, "position:y", 10, 0.2).as_relative()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
		
	await tween.finished
	
	messages_moving = false
	print("animating")

func _show_options(options):
	sending_text.text = "Type random letters to send"
	for n in option_arr:
		n.visible = false
		n._deselect()
	
	for i in range(options.size()):
		option_arr[i].option_text = options[i].option
		option_arr[i].full_text = options[i].full
		await option_arr[i]._transition_text(options[i].option)
		option_arr[i].visible = true


func _json_decode(file_path: String) -> Array:
	var content = FileAccess.get_file_as_string(file_path)
	var data = JSON.parse_string(content)
	
	if typeof(data) == TYPE_ARRAY:
		return data as Array
		
	push_error("Failed to parse JSON, or the root is not an Array.")
	return []

func _get_seed():
	return get_parent().seed
	
func _append_seed(char):
	get_parent()._append_seed(char)
	
func _clear_chats():
	
	await _animate_messages_clear()
	
	var chat_arr = $Messages/Container.get_children()
	
	for c in chat_arr:
		$Messages/Container.remove_child(c)
	
	$Messages/Container.size.y = 0
	await get_tree().process_frame
	$Messages/Container.position = container_position
	
	message_arr.clear()
	message_history_arr.clear()
	
	if option1.visible:
		await _hide_options()
		
	return true
	
	
func _animate_messages_clear():
	var tween = create_tween()
	messages_moving = true
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($Messages/Container, "position:y", 10, 0.2).as_relative()
	tween.tween_property($Messages/Container, "position:y", -750, 0.3).as_relative()
	tween.parallel().tween_property($Messages/Containter, "modulate:a", 0, 0.3)
	
	await tween.finished
	
	messages_moving = false
	
	

func _retrieve_messages(name):
	var history_file = str("user://chat_logs/history/", name, ".json")
	var message_file = str("res://chat_logs/", name, ".json")
	var height = 0
	
	message_history_arr = _json_decode(history_file)
	message_arr = _json_decode(message_file)
	next_message_index = 0
	
	for m in message_history_arr:
		repeat = false
		var new_message
		if m.sender == "player":
			if prev_message_type == "sent":
				repeat = true
			new_message = player_message_scene.instantiate()
			prev_message_type = "sent"
		else:
			if prev_message_type == "recieved":
				repeat = true
			new_message = message_scene.instantiate()
			prev_message_type = "recieved"
		if repeat:
				prev_message.get_node("Sprite").visible = false
				prev_message.get_node("RepeatSprite").visible = true
				repeat = false
		new_message.get_node("TextContainer/Message").text = m.body
		$Messages/Container.add_child(new_message)
		var lines = _get_lines(m.body)
		height += (lines * line_height) + 31.5
		prev_message = new_message
		next_message_index += 1
		
	await _animate_messages(height)
	if message_history_arr.size() > 0 and message_history_arr[message_history_arr.size() - 1].choice:
		_show_options(message_arr[message_history_arr[message_history_arr.size() - 1].index].options)
	

func _get_lines(string):
	var total = 0
	var remaining = string.length()
	
	while remaining > 0:
		total += 1
		remaining -= 45

	return total

func _transition_recipient(new_text):
	var tween = create_tween()
	
	tween.tween_property($MessengerBody/Recipient, "visible_ratio", 0.0, 0.1)
	
	await tween.finished
	
	var tween2 = create_tween()
	
	$MessengerBody/Recipient.text = new_text
	tween2.tween_property($MessengerBody/Recipient, "visible_ratio", 1.0, 0.2)
	
	
	
	
	
	
