extends Node2D

@onready var radio = $BuyableBody/Radio
@onready var label = $BuyableBody/Label
@onready var price = $BuyableBody/Price
@onready var label_text = label.text
@onready var price_text = price.text
var buyable_position
var buyable_scale

var mouse_over = false
var hovered = false
var radio_hovered = false
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buyable_position = position
	buyable_scale = scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mouse_over and not hovered:
		_hover()
	elif not mouse_over and hovered:
		_dehover()


func _on_radio_mouse_entered() -> void:
	radio_hovered = true
	if not selected:
		radio.get_node("RadioHover").play("default")
		radio.get_node("RadioHover").visible = true


func _on_radio_mouse_exited() -> void:
	radio_hovered = false
	if not selected:
		radio.get_node("RadioHover").visible = false
		

func _on_radio_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if not selected:
				_select()
			else:
				_deselect()

func _select():
	selected = true
	radio.get_node("RadioHover").visible = false
	radio.get_node("RadioSelected").visible = true
	
func _deselect():
	selected = false
	radio.get_node("RadioHover").visible = true
	radio.get_node("RadioSelected").visible = false


func _on_buyable_body_mouse_entered() -> void:
	print("here")
	mouse_over = true
	if not get_parent().hovering:
		_hover()

func _on_buyable_body_mouse_exited() -> void:
	print("gone")
	mouse_over = false
	if hovered:
		_dehover()
	
func _hover():
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:y", buyable_position.y - 10, 0.2)
	tween.parallel().tween_property(self, "scale", buyable_scale * 1.1, 0.2)
	tween.tween_property(self, "position:y", buyable_position.y - 7.5, 0.2)
	tween.parallel().tween_property(self, "scale", buyable_scale * 1.05, 0.2)
	
	hovered = true
	get_parent().hovering = true
	
	_add_wave(label, label_text)
	_add_wave(price, price_text)

func _dehover():
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:y", buyable_position.y + 5, 0.2)
	tween.parallel().tween_property(self, "scale", buyable_scale * 0.9, 0.2)
	tween.tween_property(self, "position:y", buyable_position.y, 0.2)
	tween.parallel().tween_property(self, "scale", buyable_scale, 0.2)
	
	hovered = false
	get_parent().hovering = false
	
	_remove_wave(label, label_text)
	_remove_wave(price, price_text)
	
	
func _add_wave(label, text):
	label.text = str("[wave amp=11.0 freq=2.5 connected=0]", text, "[/wave]")
	
func _remove_wave(label, text):
	label.text = text
