extends Area2D

var pressing = false
var button_scale = Vector2.ZERO

@onready var sprite = $Sprite2D
@onready var main = get_parent().get_parent()
@onready var feed = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_scale = transform.get_scale()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	sprite.texture = load("res://assets/New_Post_Button_Hover.png")


func _on_mouse_exited() -> void:
	sprite.texture = load("res://assets/New_Post_Button.png")


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if pressing == false:
				if not main.in_hand:
					if feed.commenting:
						feed.get_node("CommentBox")._cancel_comment()
						feed.commenting = false
						await get_tree().create_timer(0.25).timeout
					_draw_hand()
				else:
					_hide_hand()
				pressing = true
				var tween = _press()
				await tween.finished
				pressing = false
				main.in_hand = _toggle(main.in_hand)
				

func _press():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(button_scale.x * 0.95, button_scale.y * 0.95), 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(button_scale.x, button_scale.y), 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	return tween
	
func _toggle(boolean):
	if boolean:
		return false
	else:
		return true
		
func _draw_hand():
	main.get_node('Player')._populate_hand()

func _hide_hand():
	main.get_node('Player')._hide_hand()
