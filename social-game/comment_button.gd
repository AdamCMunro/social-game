extends Area2D

@onready var selection = get_parent().get_node("SquareSelection")
@onready var main = get_parent().get_parent().get_parent().get_parent()
@onready var feed = get_parent().get_parent().get_parent()

var pressed = false
var commented = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	if not main.in_hand and not feed.commenting and not commented:
		selection.visible = true
		selection.global_position = global_position

func _on_mouse_exited() -> void:
	selection.visible = false

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo() and not main.in_hand and not feed.commenting:
			if pressed == false:
				_press()
				feed._show_comment_box()
				feed.commenting = true
				selection.visible = false
			elif not commented:
				_unpress()

func _press():
	$Sprite2D.texture = load("res://assets/Comment_Button_Pressed.png")
	pressed = true
	
func _unpress():
	$Sprite2D.texture = load("res://assets/Comment_Button.png")
	pressed = false
