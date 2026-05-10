extends Node2D

@onready var player = get_parent().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player._test_update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _purchase(value):
	player._update_money(player.money - value)
	
func _refund(value):
	player._update_money(player.money + value)

func _get_money():
	return player.money
