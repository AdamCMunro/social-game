extends Area2D

var pressing = false
var button_scale = Vector2.ZERO
var disabled = false
var hovered = false

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
	hovered = true
	if not disabled:
		sprite.texture = load("res://assets/New_Post_Button_Hover.png")
	else:
		sprite.texture = load("res://assets/New_Post_Button_Disabled_Hover.png")
	

func _on_mouse_exited() -> void:
	hovered = false
	if not disabled:
		sprite.texture = load("res://assets/New_Post_Button.png")
	else:
		sprite.texture = load("res://assets/New_Post_Button_Disabled.png")


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if not pressing and not feed.feed_ended:
				if not disabled:
					if not main.in_hand:
						if feed.commenting:
							feed.get_node("CommentBox")._cancel_comment()
							feed.commenting = false
							await get_tree().create_timer(0.25).timeout
						_draw_hand()
					else:
						_hide_hand()
					pressing = true
					await _press().finished
					pressing = false
					main.in_hand = _toggle(main.in_hand)
				else:
					pressing = true
					await _shake().finished
					pressing = false
				

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
	
func _disable():
	disabled = true
	if hovered:
		sprite.texture = load("res://assets/New_Post_Button_Disabled_Hover.png")
	else:
		sprite.texture = load("res://assets/New_Post_Button_Disabled.png")
	
func _enable():
	disabled = false
	if hovered:
		sprite.texture = load("res://assets/New_Post_Button_Hover.png")
	else:
		sprite.texture = load("res://assets/New_Post_Button.png")
	
	
func _shake():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:x", -10, 0.05).as_relative()
	tween.tween_property(self, "position:x", 15, 0.05).as_relative()
	tween.tween_property(self, "position:x", -10, 0.05).as_relative()
	tween.tween_property(self, "position:x", 5, 0.05).as_relative()
	
	return tween
	
	
