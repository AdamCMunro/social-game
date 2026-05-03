extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2
@onready var option1 = $MessengerBody/Option1
@onready var option2 = $MessengerBody/Option2
@onready var option3 = $MessengerBody/Option3
@onready var option_arr = [option1, option2, option3]
@onready var sending_text = $MessengerBody/SendingText
@onready var container_position = $Messages/Container.position

@onready var player_message_scene = preload("res://player_message.tscn")
@onready var message_scene = preload("res://message.tscn")

var typing = false
var repeat = false

var prev_message
var prev_message_type = ""
var chosen_option_text
var next_message_index

var message_arr = []
var message_history_arr = []

var sender_name

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
				_add_message_to_history("player", sending_text.text)
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
	_animate_messages(new_message.size.y + 3)
	prev_message_type = "sent"
	prev_message = new_message
	
func _show_typing():
	$Messages/TypingIndicator.visible = true
	await get_tree().create_timer(2.0).timeout
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
	_animate_messages(new_message.size.y + 3)
	prev_message_type = "recieved"
	prev_message = new_message

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
		
func _show_chats(name, index):
	var file = str("res://chat_logs/", name, ".json")
	
	message_arr = _json_decode(file)
	sender_name = name
	
	_progress_chats(index)
				
func _progress_chats(start_index):
	
	for i in range(start_index, message_arr.size()):
		if message_arr[i].seed == _get_seed() or message_arr[i].seed == "":
			if prev_message_type == "recieved":
				repeat = true
			_show_typing()
			await get_tree().create_timer(2.0).timeout
			_recieve_message(message_arr[i].body)
			_add_message_to_history(sender_name, message_arr[i].body)
			await get_tree().create_timer(0.75).timeout
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

func _save_json(file_path: String, data_array: Array) -> void:
	# Convert the array to a JSON string. 
	# The "\t" parameter adds tab indentation for readability (pretty printing).
	var json_string: String = JSON.stringify(data_array, "\t")
	
	# Open the file in WRITE mode. This automatically overwrites existing content 
	# or creates a new file if it doesn't exist.
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		# Write the JSON string to the file
		file.store_string(json_string)
		
		# Close the file to free the resource and ensure data is flushed
		file.close()
	else:
		# If the file fails to open (e.g., bad path, read-only system), grab the error
		var error_code = FileAccess.get_open_error()
		printerr("Failed to open file for writing at: ", file_path)
		printerr("Error code: ", error_code)

func _get_seed():
	return get_parent().seed
	
func _append_seed(char):
	get_parent()._append_seed(char)
	
func _clear_chats():
	var tween = _animate_messages_clear()
	
	await tween.finished
	
	var chat_arr = $Messages/Container.get_children()
	
	for c in chat_arr:
		$Messages/Container.remove_child(c)
	
	$Messages/Container.size.y = 0
	await get_tree().process_frame
	$Messages/Container.position = container_position
	
	_save_json(str("user://chat_logs/history/", sender_name, ".json"), message_history_arr)
	message_arr.clear()
	message_history_arr.clear()
	
func _animate_messages_clear():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($Messages/Container, "position:y", 10, 0.2).as_relative()
	tween.tween_property($Messages/Container, "position:y", -750, 0.3).as_relative()
	tween.parallel().tween_property($Messages/Containter, "modulate:a", 0, 0.3)
	
	return tween

func _retrieve_messages(name):
	var file = str("user://chat_logs/history/", name, ".json")
	
	message_history_arr = _json_decode(file)
	next_message_index = 0
	
	for m in message_history_arr:
		if m.sender == "player":
			_send_message(m.body)
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
		else:
			_recieve_message(m.body)
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
		next_message_index += 1
		
	return next_message_index

func _add_message_to_history(sender, body):
	var new_message = {"sender":sender, "body":body}
	message_history_arr.append(new_message)
	_save_json(str("user://chat_logs/history/", sender_name, ".json"), message_history_arr)
	
func _transition_recipient(new_text):
	var tween = create_tween()
	
	tween.tween_property($MessengerBody/Recipient, "visible_ratio", 0.0, 0.1)
	
	await tween.finished
	
	var tween2 = create_tween()
	
	$MessengerBody/Recipient.text = new_text
	tween2.tween_property($MessengerBody/Recipient, "visible_ratio", 1.0, 0.2)
	
	
	
	
	
	
