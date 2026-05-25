extends Area2D

@onready var selection = get_parent().get_node("SquareSelection")
@onready var main = get_parent().get_parent().get_parent().get_parent()
@onready var feed = get_parent().get_parent().get_parent()

var pressed = false
var reposted = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	if reposted:
		return
		
	if not main.in_hand and not feed.commenting:
		selection.visible = true
		selection.global_position = global_position

func _on_mouse_exited() -> void:
	if reposted:
		return
	
	selection.visible = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo() and not main.in_hand and not feed.commenting:
			if pressed == false:
				_press()
			else:
				_unpress()

func _press():
	$Sprite2D.texture = load("res://assets/Send_Button_Pressed.png")
	pressed = true
	selection.visible = false
	feed.current_post_seed[1] = "1"
	feed._change_stat("energy", -5)
	feed._repost()
	reposted = true
	await get_tree().create_timer(0.3).timeout
	feed._remove_gradient()
	
	
func _unpress():
	if reposted:
		return
		
	$Sprite2D.texture = load("res://assets/Send_Button.png")
	pressed = false
	feed.current_post_seed[1] = "0"
	feed._change_stat("energy", 5)
	feed._undo_repost()
	await get_tree().create_timer(0.3).timeout
	feed._remove_gradient()
	
func _reset():
	$Sprite2D.texture = load("res://assets/Send_Button.png")
	pressed = false
	reposted = false
	
