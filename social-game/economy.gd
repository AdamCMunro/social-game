extends Node2D

@onready var player = get_parent().get_node("Player")
@onready var viewport_centre = get_viewport_rect().size / 2

@onready var change_label_scene = preload("res://change_label.tscn")

var green = "#6bff6a"
var red = "#d0316c"

var balance

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
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if balance > player.money or balance == 0:
		_update_label($Money/MoneyLabel, balance, red)
	else:
		_update_label($Money/MoneyLabel, balance, green)
	
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
	
	
