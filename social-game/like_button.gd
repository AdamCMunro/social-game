extends Area2D

@onready var selection = get_parent().get_node("SquareSelection")
@onready var main = get_parent().get_parent().get_parent().get_parent()
@onready var feed = get_parent().get_parent().get_parent()

var pressed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	if not main.in_hand and not feed.commenting:
		selection.visible = true
		selection.global_position = global_position

func _on_mouse_exited() -> void:
	selection.visible = false
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo() and not main.in_hand and not feed.commenting:
			if pressed == false:
				_press()
			else:
				_unpress()

func _press():
	$Sprite2D.texture = load("res://assets/Like_Button_Liked.png")
	pressed = true
	feed.current_post_seed[0] = "1"
	
func _unpress():
	$Sprite2D.texture = load("res://assets/Like_Button.png")
	pressed = false
	feed.current_post_seed[0] = "0"
