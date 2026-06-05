extends Node2D

@onready var pause = get_parent().get_node("Pause")
@onready var player = get_parent().get_node("Player")
@onready var continue_button = get_parent().get_node("ContinueButton")
@onready var viewport_centre = get_viewport_rect().size / 2

@onready var change_label_scene = preload("res://change_label.tscn")

var green = "#6bff6a"
var red = "#d0316c"
var black = '#000000'

var balance :int

var button_hovered = false
var button_pressed = false
var paused = false

var money_pos :Vector2
var buyable_box_pos :Vector2
var income_box_pos :Vector2
var income_pos :Vector2
var button_pos :Vector2
var continue_button_pos :Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_get_player_info()
	_get_change_label_scene()
	
	continue_button.visible = false
	continue_button.position = viewport_centre
	continue_button.position.y += 300
	continue_button_pos = continue_button.position
	
	$Money.position = viewport_centre
	$Money.position.y += 200
	money_pos = $Money.position
	
	$BuyableBox.position = viewport_centre
	$BuyableBox.position.y += 500
	buyable_box_pos = $BuyableBox.position
	
	$IncomeBox.position = viewport_centre
	$IncomeBox.position.y -= 150
	income_box_pos = $IncomeBox.position
	
	$Income.position = viewport_centre
	$Income.position.y -= 250
	income_pos = $Income.position
	
	$Button.position = viewport_centre
	$Button.position.y += 300
	button_pos = $Button.position
	

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
	
	if Input.is_action_just_pressed("pause"):
		if not paused:
			paused = true
			await _hide_for_pause().finished
			pause._show_pause()
		else:
			paused = false
			_show_for_resume()
			pause._hide_pause()

	
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
	
	tween.tween_property(self, "balance", new_value, 0.4)\
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
				await get_tree().create_timer(2).timeout
				_show_continue_button()

func _animate_button_press():
	var tween = create_tween()
	var starting_scale = $Button.scale
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($Button, "scale", starting_scale * 0.85, 0.15)
	tween.tween_property($Button, "scale", starting_scale * 0.9, 0.2)

func _show_continue_button():
	continue_button.modulate.a = 0
	continue_button.visible = true
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(continue_button, "modulate:a", 1, 0.5)

func _move_to_buyables():
	for n in $BuyableBox.get_children():
		n.moving = true
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($Button, "position:y", 300, 0.2).as_relative()
	
	tween.tween_property($Income, "position:y", 40, 0.1).as_relative()
	tween.parallel().tween_property($IncomeBox, "position:y", 40, 0.1).as_relative()
	tween.parallel().tween_property($Money, "position:y", 40, 0.1).as_relative()
		
	tween.tween_property($Income, "position:y", -475, 0.1).as_relative()
	tween.parallel().tween_property($IncomeBox, "position:y", -475, 0.075).as_relative()
	tween.parallel().tween_property($Money, "position:y", -475, 0.1).as_relative()
	
	tween.tween_property($Income, "position:y", 30, 0.05).as_relative()
	tween.parallel().tween_property($IncomeBox, "position:y", 30, 0.05).as_relative()
	tween.parallel().tween_property($Money, "position:y", 30, 0.05).as_relative()
	
	tween.parallel().tween_property($BuyableBox, "position:y", -600, 0.15).as_relative()
	tween.tween_property($BuyableBox, "position:y", 15, 0.075).as_relative()
	
	await tween.finished
	
	for n in $BuyableBox.get_children():
		n.moving = false
	
	buyable_box_pos = $BuyableBox.position
	money_pos = $Money.position

func _hide_for_pause():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	if button_pressed:
		tween.tween_property($Money, "position:y", money_pos.y + 20, 0.05)
		tween.parallel().tween_property($BuyableBox, "position:y", buyable_box_pos.y - 20, 0.05)
		
		tween.tween_property($Money, "position:y", -100, 0.05)
		tween.parallel().tween_property($BuyableBox, "position:y", 700, 0.05)
	else:
		tween.tween_property($Money, "position:y", money_pos.y - 20, 0.05)
		tween.parallel().tween_property($Income, "position:y", income_pos.y + 20, 0.05)
		tween.parallel().tween_property($IncomeBox, "position:y", income_box_pos.y + 20, 0.05)
		tween.parallel().tween_property($Button, "position:y", button_pos.y - 20, 0.05)
		
		tween.tween_property($Money, "position:y", 800, 0.05)
		tween.parallel().tween_property($Income, "position:y", -100, 0.05)
		tween.parallel().tween_property($IncomeBox, "position:y", -100, 0.05)
		tween.parallel().tween_property($Button, "position:y", 800, 0.05)
		
	return tween
		

func _show_for_resume():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	if button_pressed:
		tween.tween_property($Money, "position:y", money_pos.y + 20, 0.05)
		tween.parallel().tween_property($BuyableBox, "position:y", buyable_box_pos.y - 20, 0.05)
		
		tween.tween_property($Money, "position:y", money_pos.y, 0.05)
		tween.parallel().tween_property($BuyableBox, "position:y", buyable_box_pos.y, 0.05)
	else:
		tween.tween_property($Money, "position:y", money_pos.y - 20, 0.05)
		tween.parallel().tween_property($Income, "position:y", income_pos.y + 20, 0.05)
		tween.parallel().tween_property($IncomeBox, "position:y", income_box_pos.y + 20, 0.05)
		tween.parallel().tween_property($Button, "position:y", button_pos.y - 20, 0.05)
		
		tween.tween_property($Money, "position:y", money_pos.y, 0.05)
		tween.parallel().tween_property($Income, "position:y", income_pos.y, 0.05)
		tween.parallel().tween_property($IncomeBox, "position:y", income_box_pos.y, 0.05)
		tween.parallel().tween_property($Button, "position:y", button_pos.y, 0.05)
		
func _transition_out():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	if button_pressed:
		tween.tween_property($Money, "position:y", money_pos.y + 20, 0.1)
		tween.parallel().tween_property($BuyableBox, "position:y", buyable_box_pos.y - 20, 0.1)
		tween.parallel().tween_property(continue_button, "position:y", continue_button_pos.y - 20, 0.1)
		
		tween.tween_property($Money, "position:y", -100, 0.1)
		tween.parallel().tween_property($BuyableBox, "position:y", 700, 0.1)
		tween.parallel().tween_property(continue_button, "position:y", 700, 0.1)
		
	else:
		tween.tween_property($Money, "position:y", money_pos.y - 20, 0.1)
		tween.parallel().tween_property($Income, "position:y", income_pos.y + 20, 0.1)
		tween.parallel().tween_property($IncomeBox, "position:y", income_box_pos.y + 20, 0.1)
		tween.parallel().tween_property($Button, "position:y", button_pos.y - 20, 0.1)
		
		tween.tween_property($Money, "position:y", 800, 0.1)
		tween.parallel().tween_property($Income, "position:y", -100, 0.1)
		tween.parallel().tween_property($IncomeBox, "position:y", -100, 0.1)
		tween.parallel().tween_property($Button, "position:y", 800, 0.1)
		
	return tween
	
func _transition_in():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	if button_pressed:
		tween.tween_property($Money, "position:y", money_pos.y + 20, 0.1)
		tween.parallel().tween_property($BuyableBox, "position:y", buyable_box_pos.y - 20, 0.1)
		
		tween.tween_property($Money, "position:y", money_pos.y, 0.1)
		tween.parallel().tween_property($BuyableBox, "position:y", buyable_box_pos.y, 0.1)
	else:
		tween.tween_property($Money, "position:y", money_pos.y - 20, 0.1)
		tween.parallel().tween_property($Income, "position:y", income_pos.y + 20, 0.1)
		tween.parallel().tween_property($IncomeBox, "position:y", income_box_pos.y + 20, 0.1)
		tween.parallel().tween_property($Button, "position:y", button_pos.y - 20, 0.1)
		
		tween.tween_property($Money, "position:y", money_pos.y, 0.1)
		tween.parallel().tween_property($Income, "position:y", income_pos.y, 0.1)
		tween.parallel().tween_property($IncomeBox, "position:y", income_box_pos.y, 0.1)
		tween.parallel().tween_property($Button, "position:y", button_pos.y, 0.1)
		
	return tween
	
