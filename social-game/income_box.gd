extends Area2D



@onready var income_item_scene = preload("res://income_item.tscn")
var income_arr = [{"label":"Followers(400)","amount":"400"},{"label":"Sponsor","amount":"2000"},{"label":"Pocket Money","amount":"50"},]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent()._get_player_info()
	get_parent()._get_change_label_scene()
	for i in range(income_arr.size()):
		var instance = income_item_scene.instantiate()
		instance.get_node("IncomeBody/Label").text = str(income_arr[i].label, ":")
		instance.get_node("IncomeBody/Amount").text = income_arr[i].amount
		add_child(instance)
		instance.position.y += 300
		instance.floating = true
		_animate_income_arrival(instance, i * 35)
		get_parent()._refund(int(income_arr[i].amount))
		await get_tree().create_timer(0.25).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _animate_income_arrival(node, endpoint):
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(node, "position:y", endpoint - 10, 0.3)
	tween.tween_property(node, "position:y", endpoint, 0.3)
	
	await tween.finished
	
	node.floating = false
	node.income_position = node.position
