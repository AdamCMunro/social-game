extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2
@onready var option1 = $MessengerBody/Option1
@onready var option2 = $MessengerBody/Option2
@onready var option3 = $MessengerBody/Option3
@onready var option_arr = [option1, option2, option3]
@onready var sending_text = $MessengerBody/SendingText

@onready var player_message_scene = preload("res://player_message.tscn")
@onready var message_scene = preload("res://message.tscn")

var typing = false

var chosen_option_text
var next_message_index

var message_arr = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MessengerBody.position = viewport_centre
	$Messages.position = viewport_centre
	for n in option_arr:
		n.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Messages/Container.size.x = 561.5
	$Messages/Container.position.x = 299.25


func _option1():
	chosen_option_text = option1.full_text
	_append_seed("1")
	_option_chosen()
	
func _option2():
	chosen_option_text = option2.full_text
	_append_seed("2")
	_option_chosen()
	
func _option3():
	chosen_option_text = option3.full_text
	_append_seed("3")
	_option_chosen()

func _option_chosen() -> void:
	
	for option in option_arr:
		var option_tween = create_tween()
		
		option_tween.tween_property(option, "position", Vector2(option.position.x, option.position.y - 15), 0.15)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_SINE)
		option_tween.tween_property(option, "position", Vector2(option.position.x, option.position.y + 500), 0.1)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_SINE)
		
		await option_tween.finished
		
	sending_text.visible = true
	sending_text.visible_ratio = 0
	_show_sending_text()
	typing = true


func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if typing:
			if sending_text.text == "Type random letters to send":
				sending_text.visible_ratio = 0
				sending_text.text = chosen_option_text
			elif sending_text.visible_characters < sending_text.text.length() - 1:
				sending_text.visible_characters += 1
			else:
				typing = false
				sending_text.visible = false
				_send_message(sending_text.text)
				await get_tree().create_timer(0.5).timeout
				_progress_chats(next_message_index)

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
	_animate_messages(new_message.size.y)
	
func _recieve_message(message):
	$Messages/TypingIndicator.visible = true
	await get_tree().create_timer(2.0).timeout
	$Messages/TypingIndicator.visible = false
	var new_message = message_scene.instantiate()
	new_message.get_node("TextContainer/Message").text = message
	$Messages/Container.add_child(new_message)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_animate_messages(new_message.size.y)

func _animate_messages(offset):
	var tween = create_tween()
	
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
		
func _show_chats(name):
	var file = str("res://chat_logs/", name, ".json")
	
	message_arr = _json_decode(file)
	
	_progress_chats(0)
				
func _progress_chats(start_index):
	for i in range(start_index, message_arr.size()):
		if message_arr[i].seed == _get_seed():
			_recieve_message(message_arr[i].body)
			await get_tree().create_timer(2.2).timeout
			if message_arr[i].options.size() > 0:
				for j in range(option_arr.size()):
					option_arr[j].option_text = message_arr[i].options[j].option
					option_arr[j].full_text = message_arr[i].options[j].full
					option_arr[j]._transition_text(message_arr[i].options[j].option)
					option_arr[j].visible = true
				next_message_index = i + 1
				break


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
	
	
	
	
	
