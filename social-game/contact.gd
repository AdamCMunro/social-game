extends Node2D

@onready var selection = get_parent().get_node("Selection")
@onready var contacts = get_parent().get_parent()
@onready var messenger = get_parent().get_parent().get_parent()
@onready var main = messenger.get_parent()

var contact_scale
var contact_position

var selected = false
var hovered = false

var pending = 0
var typing = false
var repeat = false
var finished = false

var options = []
var contact_name

var black = Color(0,0,0,1)
var white = Color(1,1,1,1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_scale = scale
	contact_position = position
	_progress_chat()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if hovered and not selected:
		selection.visible = true
	
	if not selected:
		if typing or pending > 0:
			$ContactBody/Alert.visible = true
			if typing:
				$ContactBody/Alert/TypingLabel.visible = true
				$ContactBody/Alert/PendingLabel.visible = false
			else:
				$ContactBody/Alert/PendingLabel.text = str(pending)
				$ContactBody/Alert/PendingLabel.visible = true
				$ContactBody/Alert/TypingLabel.visible = false


func _on_contact_body_mouse_entered() -> void:
	hovered = true
	selection.position = position
		
func _on_contact_body_mouse_exited() -> void:
	hovered = false
	selection.visible = false


func _on_contact_body_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if not selected:
				_select()
				
				
func _select():
	$ContactBody/Sprite2D.texture = preload("res://assets/Contact_Selected.png")
	$ContactBody/Label.set("theme_override_colors/font_color",black)
	
	finished = true
	contacts._check_finished()
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "scale", contact_scale * 0.99, 0.2)
	tween.parallel().tween_property(self, "position:y", contact_position.y + 5, 0.2)
	tween.tween_property(self, "scale", contact_scale, 0.1)
	tween.parallel().tween_property(self, "position:y", contact_position.y, 0.1)
	
	var children = get_parent().get_children()
	
	for n in children:
		if n is not Area2D and n is not Sprite2D and n.selected :
			n._deselect()
			
	selected = true
	selection.visible = false
	$ContactBody/Alert.visible = false
	pending = 0
	messenger.sender_name = contact_name
	
	messenger._transition_recipient(contact_name)
	messenger.get_node("Messages/TypingIndicator").visible = false
	await messenger._clear_chats()
	messenger._retrieve_messages(contact_name)
	messenger.get_node("Messages/TypingIndicator").text = str("[wave amp=9.0 freq=4 connected=0]", contact_name, " is typing...[/wave]")
	messenger.get_node("Messages/TypingIndicator").visible = true
	await get_tree().create_timer(0.75).timeout
				
func _deselect():
	$ContactBody/Sprite2D.texture = preload("res://assets/Contact.png")
	$ContactBody/Label.set("theme_override_colors/font_color",white)
	
	selected = false
	
func _progress_chat():
	var history_path = str("user://", main.current_day, "/chat_logs/history/", contact_name, ".json")
	var messages_path = str("res://daily_files/", main.current_day, "/chat_logs/", contact_name, ".json")
	var history = _json_decode(history_path)
	var messages = _json_decode(messages_path)
	var start = _get_start_point(history)
	var choice = false

	for i in range(start, messages.size()):
		options.clear()
		#if _check_repetition(messages[i].body, history):
			#continue
		if messages[i].seed.has("") or messages[i].seed.has(history[history.size() - 1].seed):
			await get_tree().create_timer(messages[i].delay).timeout
			typing = true
			if selected:
				messenger._show_typing(messages[i].typing)
			await get_tree().create_timer(messages[i].typing).timeout
			typing = false
			if selected:
				await messenger._recieve_message(messages[i].body)
			else:
				pending += 1
			if messages[i].options.size() > 0:
				choice = true
			if history.size() > 0:
				history.append({"sender":contact_name, "body":messages[i].body, "choice":choice, "seed":history[history.size() - 1].seed, "index":i})
			else:
				history.append({"sender":contact_name, "body":messages[i].body, "choice":choice, "seed":"", "index":i})
			_save_json(history_path, history)
			if choice:
				options = messages[i].options
				if selected:
					messenger._show_options(options)
				break
			await get_tree().create_timer(0.5).timeout
		
	if not choice:
		finished = true
		contacts._check_finished()
				
func _get_start_point(arr):
	var count = 0
	
	for n in arr:
		if n.sender != "player":
			count += 1
	
	return count
	
func _check_repetition(text, arr):
	var index = arr.size()-1
	
	while index >= 0:
		if arr[index].body == text:
			return true
		elif arr[index].sender == "player":
			return false
		index -= 1
	return false
		

func _json_decode(file_path: String) -> Array:
	var content = FileAccess.get_file_as_string(file_path)
	var data = JSON.parse_string(content)
	
	if typeof(data) == TYPE_ARRAY:
		return data as Array
		
	push_error("Failed to parse JSON, or the root is not an Array.")
	return []

func _save_json(file_path: String, data_array: Array) -> void:
	var json_string: String = JSON.stringify(data_array, "\t")
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(json_string)
		
		file.close()
