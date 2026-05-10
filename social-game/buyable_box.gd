extends Area2D

@onready var buyable_scene = preload("res://buyable.tscn")
@onready var buyable_arr = [{"label":"Rent","price":200}, {"label":"Electricity","price":25}, {"label":"Food","price":15}, {"label":"Internet","price":10}]

var hovering = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for i in range(buyable_arr.size()):
		var instance = buyable_scene.instantiate()
		instance.get_node("BuyableBody/Label").text = buyable_arr[i].label
		instance.get_node("BuyableBody/Price").text = str(buyable_arr[i].price)
		instance.position.y += i * 50
		add_child(instance)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
