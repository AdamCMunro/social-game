extends Node2D

@onready var player = get_parent().get_node("Player")
@onready var viewport_centre = get_viewport_rect().size / 2

var balance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player._test_update()
	balance = player.money
	$Money.position.x = viewport_centre.x
	$Money.position.y += 150

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_label($Money/MoneyLabel, balance)
	
func _purchase(value):
	_update_balance(player.money, player.money - value)
	player.money -= value
	
func _refund(value):
	_update_balance(player.money, player.money + value)
	player.money += value

func _get_money():
	return player.money

func _update_balance(starting_val, new_value):
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "balance", new_value, 0.7)\
		.from(starting_val)

func _update_label(label, val):
	if val < 10:
		label.text = str("000", val)
	elif val < 100:
		label.text = str("00", val)
	elif val < 1000:
		label.text = str("0", val)
	else:
		label.text = str(val)
	
