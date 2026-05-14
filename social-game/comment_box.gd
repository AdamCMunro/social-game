extends Area2D

@onready var feed = get_parent()
@onready var selection = $Selection
@onready var option_arr = [$Option1, $Option2, $Option3]
@onready var commenting_text = $CommentingText

var option_text = ["OMG SLAY", "I hate you", "whatever"]
var full_text = ["OMG SLAY", "I HATE YOU I HATE YOU I HATE YOU", "whatever"]
var option_pos = [Vector2.ZERO,Vector2.ZERO,Vector2.ZERO]

var cancel_pos

var selected_option
var hovered_option

var chosen_option_text

var hovering = false
var typing = false

var black = Color(0,0,0,1)
var white = Color(1,1,1,1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cancel_pos = $Cancel.position
	
	var count = 0
	for n in option_arr:
		n.mouse_entered.connect(_on_option_mouse_entered.bind(n))
		n.mouse_exited.connect(_on_option_mouse_exited.bind(n))
		n.input_event.connect(_on_option_input_event.bind(n))
		n.get_node("Label").text = option_text[count]
		option_pos[count] = n.position
		count += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hovering:
		selection.visible = true

func _select(option):
	selected_option = option
	hovering = false
	selection.visible = false
	option.get_node("ColorRect").visible = true
	option.get_node("Label").set("theme_override_colors/font_color",black)
	
	for i in range(option_arr.size()):
		if option_arr[i] == option:
			continue
		_deselect(option_arr[i], option_text[i])
	
	_transition_text(option.get_node("Label"), "Click again to confirm")

func _deselect(option, text):
	option.get_node("ColorRect").visible = false
	option.get_node("Label").set("theme_override_colors/font_color",white)
	option.get_node("Label").text = text
	
func _transition_text(label, new_text):
	var tween = create_tween()
	
	tween.tween_property(label, "visible_ratio", 0.0, 0.1)
	
	await tween.finished
	
	var tween2 = create_tween()
	
	label.text = new_text
	tween2.tween_property(label, "visible_ratio", 1.0, 0.2)

func _on_option_mouse_entered(option) -> void:
	if selected_option != option:
		selection.visible = true
		hovered_option = option
		selection.position = option.position
		await get_tree().process_frame
		hovering = true

func _on_option_mouse_exited(option) -> void:
		selection.visible = false
		hovering = false
		
func _on_option_input_event(viewport: Node, event: InputEvent, shape_idx: int, option) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if selected_option == option:
				_choose_option(option)
			else:
				_select(option)
				
func _choose_option(option):
	for i in range(option_arr.size()):
		if option_arr[i] == option:
			chosen_option_text = full_text[i]
	await _hide_options()
	commenting_text.visible = true
	commenting_text.visible_ratio = 0
	_show_commenting_text()
	typing = true
	

func _hide_options():
	for i in range(option_arr.size()):
		var op = option_arr[i]
		var op_tween = create_tween()
	
		op_tween.set_ease(Tween.EASE_IN_OUT)
		op_tween.set_trans(Tween.TRANS_SINE)
		
		op_tween.tween_property(op, "position:y", option_pos[i].y - 10, 0.1)
		op_tween.tween_property(op, "position:y", 800, 0.1)
		
		await get_tree().create_timer(0.1).timeout
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($Cancel, "position:y", cancel_pos.y - 10, 0.1)
	tween.tween_property($Cancel, "position:y", 800, 0.1)
	
		

func _on_cancel_mouse_entered() -> void:
	selection.visible = true
	selection.position = $Cancel.position
	await get_tree().process_frame
	hovering = true

func _on_cancel_mouse_exited() -> void:
	selection.visible = false
	hovering = false


func _on_cancel_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			$Cancel/ColorRect.visible = true
			$Cancel/Label.set("theme_override_colors/font_color",black)
			var tween = create_tween()
			
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_SINE)
			
			tween.tween_property($Cancel, "scale", Vector2(0.9,0.9), 0.05)
			tween.tween_property($Cancel, "scale", Vector2(1.01,1.01), 0.05)
			tween.tween_property($Cancel, "scale", Vector2(1,1), 0.05)
			
			await tween.finished
			$Cancel/ColorRect.visible = false
			$Cancel/Label.set("theme_override_colors/font_color",white)
			_cancel_comment()

func _cancel_comment():
	
	feed.commenting = false
	feed._hide_comment_box()
	feed.current_post.get_node("PostBody/CommentButton")._unpress()
	await get_tree().create_timer(0.3).timeout
	for i in range(option_arr.size()):
		_deselect(option_arr[i], option_text[i])
		
func _show_commenting_text():
	var tween = create_tween()
	
	tween.tween_property(commenting_text, "visible_ratio", 1, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if typing:
			if commenting_text.text == "Type random letters to comment" and commenting_text.visible_ratio == 1:
				commenting_text.visible_ratio = 0
				commenting_text.text = chosen_option_text
			elif commenting_text.text != "Type random letters to comment" and commenting_text.visible_characters < commenting_text.text.length():
				commenting_text.visible_characters += 1
			elif commenting_text.text != "Type random letters to comment":
				typing = false
				commenting_text.visible = false
				_comment()
				feed.commenting = false
				feed._hide_comment_box()

func _comment():
	feed.current_post.get_node("PostBody/CommentButton").commented = true
