extends Area2D

@onready var dream = get_parent()

var black = Color(0,0,0,1)
var red = Color.from_rgba8(208,49,108)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	$ColorRect.visible = true
	$Label.set("theme_override_colors/font_color",black)

func _on_mouse_exited() -> void:
	$ColorRect.visible = false
	$Label.set("theme_override_colors/font_color",red)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			dream.chosen_card._destroy_card()
			dream._take_health(-20)
			dream._end_sacrifice()
