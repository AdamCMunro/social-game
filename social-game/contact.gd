extends Node2D

@onready var selection = get_parent().get_node("Selection")

var contact_scale
var contact_position

var selected = false
var hovered = false

var pending = 0

var options = []

var black = Color(0,0,0,1)
var white = Color(1,1,1,1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_scale = scale
	contact_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hovered and not selected:
		selection.visible = true


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
	pending = 0
	
	get_parent().get_parent()._transition_recipient($ContactBody/Label.text)
	await get_parent().get_parent()._clear_chats()
	var index = await get_parent().get_parent()._retrieve_messages($ContactBody/Label.text)
	get_parent().get_parent()._show_chats($ContactBody/Label.text, index)
	get_parent().get_parent().get_node("Messages/TypingIndicator").text = str("[wave amp=9.0 freq=4 connected=0]", $ContactBody/Label.text, " is typing...[/wave]")
			
func _deselect():
	$ContactBody/Sprite2D.texture = preload("res://assets/Contact.png")
	$ContactBody/Label.set("theme_override_colors/font_color",white)
	
	selected = false
	
func _progress_chat():
	var name = $ContactBody/Label.text
	var messenger = get_parent().get_parent()
	var history_path = str("user://chat_logs/history/", name, ".json")
	var messages_path = str("res://chat_logs/", name, ".json")
	var history = _json_decode(history_path)
	var messages = _json_decode(messages_path)
	var start = history.size()
	var choice = false
	
	for i in range(start, messages.size()):
		options.clear()
		choice = false
		if messages[i].seed == "" or messages[i].seed == history[history.size() - 1].seed:
			await get_tree().create_timer(0.75).timeout
			if messages[i].options.size() > 0:
				choice = true
			history.append({"sender":name, "body":messages[i].body, "choice":choice, "seed":history[history.size() - 1].seed})
			_save_json(history_path, history)
			if selected:
				messenger._recieve_message(messages[i].body)
			else:
				pending += 1
			if choice:
				options = messages[i].options
				if selected:
					messenger._show_options(options)
				break
				
func _show_typing():
	pass
		

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
