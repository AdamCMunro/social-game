extends Area2D

@onready var income_item_scene = preload("res://income_item.tscn")
var income_arr = [{"label":"Followers(400)","amount":"400"},{"label":"Sponsor","amount":"2000"},{"label":"Pocket Money","amount":"50"},]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(income_arr.size()):
		var instance = income_item_scene.instantiate()
		instance.position.y += i * 45
		instance.get_node("IncomeBody/Label").text = str(income_arr[i].label, ":")
		instance.get_node("IncomeBody/Amount").text = income_arr[i].amount
		add_child(instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
