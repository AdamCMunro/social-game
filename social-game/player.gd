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

var cards_data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cards_data = _json_decode("res://posts/player_post_dict.json")
	
	_add_to_deck(0)
	
	_update_energy(100)
	_update_health(100)
	_update_followers(100)
	_update_money(100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_label(energy_label, current_energy)
	_update_label(health_label, current_health)
	_update_label(followers_label, current_followers)
	_update_label(money_label, current_money)

func _test_update():
	_update_money(210)

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

func _update_stat(stat, temp_stat, label, new_value):
	var starting_val = stat
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, temp_stat, new_value, 0.7)\
		.from(starting_val)

func _update_label(label, val):
	if val < 10:
		label.text = str("[wave amp=11.0 freq=2.5 connected=0]000", val, "[/wave]")
	elif val < 100:
		label.text = str("[wave amp=11.0 freq=2.5 connected=0]00", val, "[/wave]")
	elif val < 1000:
		label.text = str("[wave amp=11.0 freq=2.5 connected=0]0", val, "[/wave]")
	else:
		label.text = str("[wave amp=11.0 freq=2.5 connected=0]", val, "[/wave]")

func _json_decode(file_path: String) -> Array:
	var content = FileAccess.get_file_as_string(file_path)
	var data = JSON.parse_string(content)
	
	if typeof(data) == TYPE_ARRAY:
		return data as Array
		
	push_error("Failed to parse JSON, or the root is not an Array.")
	return []
	
func _populate_card_details(card, data):
	card.id = data.id
	card.title = data.name
	card.description = data.description
	card.stats = data.stats
	
func _add_to_deck(id):
	var card_instance = card_scene.instantiate()
	
	deck.append(card_instance)
	_populate_card_details(card_instance, cards_data[id])
	
