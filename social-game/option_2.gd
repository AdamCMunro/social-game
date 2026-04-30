extends Area2D

signal option2_chosen

@onready var selection = get_parent().get_node("Selection")
@onready var messenger_body = get_parent()

var option_text = "Option 2..."

var hovered = false
var selected = false

var black = Color(0,0,0,1)
var white = Color(1,1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hovered and not selected:
		selection.visible = true

func _on_mouse_entered() -> void:
	hovered = true
	selection.position = position

func _on_mouse_exited() -> void:
	hovered = false
	selection.visible = false

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if not selected:
				_select()
			else:
				option2_chosen.emit()

func _select():
	selected = true
	selection.visible = false
	$ColorRect.set_color(white)
	$OptionLabel.set("theme_override_colors/font_color",black)
	messenger_body.get_node("Option1")._deselect()
	messenger_body.get_node("Option3")._deselect()
	_transition_text("Click again to confirm")

func _deselect():
	selected = false
	$ColorRect.set_color(black)
	$OptionLabel.set("theme_override_colors/font_color",white)
	$OptionLabel.text = option_text
	
func _transition_text(new_text):
	var tween = create_tween()
	
	tween.tween_property($OptionLabel, "visible_ratio", 0.0, 0.1)
	
	await tween.finished
	
	var tween2 = create_tween()
	
	$OptionLabel.text = new_text
	tween2.tween_property($OptionLabel, "visible_ratio", 1.0, 0.2)
