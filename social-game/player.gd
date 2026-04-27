extends Node2D

@onready var card_scene = preload("res://card.tscn")

var energy = 0
var health = 0
var followers = 0
var money = 0

var deck := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(6):
		var card_instance = card_scene.instantiate()
		deck.append(card_instance)
		card_instance.get_node("CardBody/CardName").text = str("Card Name ", i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _populate_hand():
	$Hand._populate(deck)

func _hide_hand():
	$Hand._hide_hand()
		
