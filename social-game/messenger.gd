extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2
@onready var option1 = $MessengerBody/Option1
@onready var option2 = $MessengerBody/Option2
@onready var option3 = $MessengerBody/Option3
@onready var option_arr = [option1, option2, option3]
@onready var sending_text = $MessengerBody/SendingText

@onready var player_message_scene = preload("res://player_message.tscn")

var typing = false

var chosen_option_text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MessengerBody.position = viewport_centre
	$Messages.position = viewport_centre


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _option1():
	chosen_option_text = option1.full_text
	_option_chosen()
	
func _option2():
	chosen_option_text = option2.full_text
	_option_chosen()
	
func _option3():
	chosen_option_text = option3.full_text
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
			elif sending_text.visible_characters < sending_text.text.length():
				sending_text.visible_characters += 1
			else:
				typing = false
				sending_text.visible = false
				_send_message(sending_text.text)

func _show_sending_text():
	var tween = create_tween()
	
	tween.tween_property(sending_text, "visible_ratio", 1, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)

func _send_message(message):
	var new_message = player_message_scene.instantiate()
	new_message.get_node("TextContainer/Message").text = message
	await get_tree().process_frame
	new_message.position = Vector2(15, 10)
	$Messages.add_child(new_message)
	
	#_message_animation(new_message)


func _message_animation(message):
	message.modulate.a = 0
	var tween = create_tween()

	# Fade in
	tween.tween_property(message, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(message, "position", Vector2(message.position.x, 0), 0.3)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(message, "position", Vector2(message.position.x, 10), 0.2)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	
	
