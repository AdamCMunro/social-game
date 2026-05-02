extends Node2D

@onready var selection = get_parent().get_node("Selection")

var contact_scale
var contact_position

var selected = false
var hovered = false

var black = Color(0,0,0,1)
var white = Color(1,1,1,1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_scale = scale
	contact_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hovered and not selected:
		selection.visible = true


func _on_contact_body_mouse_entered() -> void:
	hovered = true
	selection.position = position
		
func _on_contact_body_mouse_exited() -> void:
	hovered = false
	selection.visible = false


func _on_contact_body_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if not selected:
				_select()
				
func _select():
	$ContactBody/Sprite2D.texture = preload("res://assets/Contact_Selected.png")
	$ContactBody/Label.set("theme_override_colors/font_color",black)
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "scale", contact_scale * 0.99, 0.2)
	tween.parallel().tween_property(self, "position:y", contact_position.y + 5, 0.2)
	tween.tween_property(self, "scale", contact_scale, 0.1)
	tween.parallel().tween_property(self, "position:y", contact_position.y, 0.1)
	
	var children = get_parent().get_children()
	
	for n in children:
		if n is not Area2D and n is not Sprite2D and n.selected :
			n._deselect()
			
	selected = true
	selection.visible = false
	
	get_parent().get_parent()._show_chats($ContactBody/Label.text)
			
func _deselect():
	$ContactBody/Sprite2D.texture = preload("res://assets/Contact.png")
	$ContactBody/Label.set("theme_override_colors/font_color",white)
	
	selected = false
			
