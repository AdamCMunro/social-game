extends Node2D

@onready var card_scene = preload("res://card.tscn")

@onready var energy_label = $StatBlock/Energy
@onready var health_label = $StatBlock/MentalHealth
@onready var followers_label = $StatBlock/Followers
@onready var money_label = $StatBlock/Money

var energy = 0
var current_energy = 0

var health = 0
var current_health = 0

var followers = 0
var current_followers = 0

var money = 0
var current_money = 0

var deck := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(6):
		var card_instance = card_scene.instantiate()
		deck.append(card_instance)
		card_instance.get_node("CardBody/CardName").text = str("Card Name ", i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_label(energy_label, current_energy)
	_update_label(health_label, current_health)
	_update_label(followers_label, current_followers)
	_update_label(money_label, current_money)

func _test_update():
	_update_money(1000)

func _populate_hand():
	$Hand._populate(deck)

func _hide_hand():
	$Hand._hide_hand()
	
func _update_energy(value):
	_update_stat(energy, "current_energy", energy_label, value)
	energy = value
	
func _update_health(value):
	_update_stat(health, "current_health", health_label, value)
	health = value
	
func _update_followers(value):
	_update_stat(followers, "current_followers", followers_label, value)
	followers = value
	
func _update_money(value):
	_update_stat(money, "current_money", money_label, value)
	money = value
	print("money: ", money)

func _update_stat(stat, temp_stat, label, new_value):
	var starting_val = stat
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, temp_stat, new_value, 0.7)\
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
