extends Node2D

@onready var player = get_parent().get_node("Player")
@onready var viewport_centre = get_viewport_rect().size / 2

@onready var change_label_scene = preload("res://change_label.tscn")

var green = "#6bff6a"
var red = "#d0316c"
var black = '#000000'

var balance

var button_hovered = false
var button_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_get_player_info()
	_get_change_label_scene()
	$Money.position = viewport_centre
	$Money.position.y += 200
	$BuyableBox.position = viewport_centre
	$BuyableBox.position.y += 500
	$IncomeBox.position = viewport_centre
	$IncomeBox.position.y -= 150
	$Income.position = viewport_centre
	$Income.position.y -= 250
	$Button.position = viewport_centre
	$Button.position.y += 300
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if balance > player.money or balance == 0:
		_update_label($Money/MoneyLabel, balance, red)
	else:
		_update_label($Money/MoneyLabel, balance, green)
		
	if button_hovered or button_pressed:
		$Button/ColorRect.visible = true
		$Button/Label.text = str("[color=", black, "]Continue[/color]")
	else:
		$Button/ColorRect.visible = false
		$Button/Label.text = "Continue"

	
func _purchase(value):
	_update_balance(player.money, player.money - value)
	player.money -= value
	_show_decrement(value)
	
func _refund(value):
	_update_balance(player.money, player.money + value)
	player.money += value
	_show_increment(value)

func _get_money():
	return player.money

func _update_balance(starting_val, new_value):
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "balance", new_value, 0.7)\
		.from(starting_val)

func _update_label(label, val, color):
	var text
	
	if color == green:
		$Money/RedDollar.visible = false
		$Money/GreenDollar.visible = true
	else:
		$Money/RedDollar.visible = true
		$Money/GreenDollar.visible = false
	
	if val < 10:
		text = str("000", val)
		label.text = str("[color=", color, "]", text, "[/color]")
	elif val < 100:
		text = str("00", val)
		label.text = str("[color=", color, "]", text, "[/color]")
	elif val < 1000:
		text = str("0", val)
		label.text = str("[color=", color, "]", text, "[/color]")
	else:
		text = str(val)
		label.text = str("[color=", color, "]", text, "[/color]")

func _show_increment(value):
	var label = _create_change_label()
	label.text = str("[color=", green, "]+", value, "[/color]")
	await _animate_change_label(label).finished
	label.visible = false
	label.queue_free()
	
func _show_decrement(value):
	var label = _create_change_label()
	label.text = str("[color=", red, "]-", value, "[/color]")
	await _animate_change_label(label).finished
	label.visible = false
	label.queue_free()

func _create_change_label():
	var instance = change_label_scene.instantiate()
	instance.visible = false
	instance.position = Vector2(172, 43)
	$Money.add_child(instance)
	return instance

func _animate_change_label(label):
	label.modulate.a = 0
	label.visible = true
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(label, "position:y", -125, 0.3).as_relative()
	tween.parallel().tween_property(label, "modulate:a", 1, 0.2)
	tween.tween_property(label, "position:y", 125, 0.4).as_relative()
	tween.parallel().tween_property(label, "modulate:a", 0, 0.4)
	
	return tween

func _get_player_info():
	player = get_parent().get_node("Player")
	balance = player.money

func _get_change_label_scene():
	change_label_scene = preload("res://change_label.tscn")
		
func _on_button_mouse_entered() -> void:
	button_hovered = true
	$Button/ColorRect.visible = true
	$Button/Label.text = str("[color=", black, "]Continue[/color]")


func _on_button_mouse_exited() -> void:
	button_hovered = false
	$Button/ColorRect.visible = false
	$Button/Label.text = "Continue"


func _on_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if not button_pressed:
				button_pressed = true
				_animate_button_press()
				_move_to_buyables()

func _animate_button_press():
	var tween = create_tween()
	var starting_scale = $Button.scale
	var starting_pos = $Button.position
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($Button, "scale", starting_scale * 0.85, 0.15)
	tween.tween_property($Button, "scale", starting_scale * 0.9, 0.2)
	
func _move_to_buyables():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($Button, "position:y", 300, 0.2).as_relative()
	
	tween.tween_property($Income, "position:y", 40, 0.1).as_relative()
	tween.parallel().tween_property($IncomeBox, "position:y", 40, 0.1).as_relative()
	tween.parallel().tween_property($Money, "position:y", 40, 0.1).as_relative()
		
	tween.tween_property($Income, "position:y", -475, 0.3).as_relative()
	tween.parallel().tween_property($IncomeBox, "position:y", -475, 0.3).as_relative()
	tween.parallel().tween_property($Money, "position:y", -475, 0.3).as_relative()
	
	tween.tween_property($Income, "position:y", 30, 0.2).as_relative()
	tween.parallel().tween_property($IncomeBox, "position:y", 30, 0.2).as_relative()
	tween.parallel().tween_property($Money, "position:y", 30, 0.2).as_relative()
	
	tween.tween_property($BuyableBox, "position:y", -600, 0.4).as_relative()
	tween.tween_property($BuyableBox, "position:y", 15, 0.2).as_relative()

	
