extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2
@onready var option1 = $MessengerBody/Option1
@onready var option2 = $MessengerBody/Option2
@onready var option3 = $MessengerBody/Option3
@onready var option_arr = [option1, option2, option3]
@onready var sending_text = $MessengerBody/SendingText

var typing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MessengerBody.position = viewport_centre


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
				sending_text.text = option1.full_text
			else:
				sending_text.visible_characters += 1

func _show_sending_text():
	var tween = create_tween()
	
	tween.tween_property(sending_text, "visible_ratio", 1, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
