extends Node2D

var card_hovered = false

@onready var viewport_centre = get_viewport_rect().size / 2

var card_pool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _populate(cards):
	card_pool = cards
	var midpoint = card_pool.size()/2
	if card_pool.size()%2 == 0:
		midpoint -= 0.5
	var diff
	
	for i in range(card_pool.size()):
		
		if card_pool[i].removal_submitted:
			continue
		
		add_child(card_pool[i])
		diff = i - midpoint
		
		card_pool[i].scale = Vector2(0.65, 0.65)
		card_pool[i].card_scale = card_pool[i].scale
		card_pool[i].z_index = i + 2
		card_pool[i].card_z = i + 2
		
		card_pool[i].position.y = 600
		card_pool[i].position.x = 2000
		
		var tween = create_tween()
		
		tween.tween_property(card_pool[i], "position", Vector2(viewport_centre.x + (125 * diff), 600 + abs(30 * diff)), 0.09)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(card_pool[i], "rotation", 0.15 * diff, 0.09)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
		
		card_pool[i].card_position = Vector2(575 + (125 * diff), 600 + abs(30 * diff))
		card_pool[i].card_rotation = 0.15 * diff
		
		var delay_tween = create_tween()
		
		delay_tween.tween_property(self, "position", position, 0.05 + (0.02 * i))
		await delay_tween.finished
		
		
func _hide_hand():
	for i in card_pool.size():
		if card_pool and i >= card_pool.size():
			continue
			
		if card_pool[i].removal_submitted:
			continue
			
		var tween = create_tween()
		
		tween.tween_property(card_pool[i], "position", Vector2(-2000, 600), 0.09)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(card_pool[i], "rotation", 0, 0.12)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
			
		var delay_tween = create_tween()
		
		delay_tween.tween_property(self, "position", position, 0.05 + (0.02 * i))
		await delay_tween.finished
		
		remove_child(card_pool[i])
		
func _move_card(start, destination):
	var moved_card = card_pool.pop_at(start)
	card_pool.insert(destination, moved_card)
	moved_card.z_index = destination + 2
	moved_card.card_z = destination + 2
	move_child(moved_card, destination)		
	
	_realign_cards()
	
func _realign_cards():
	var midpoint = card_pool.size()/2
	if card_pool.size()%2 == 0:
		midpoint -= 0.5
	
	for i in range(card_pool.size()):
		var card = card_pool[i]
		var diff = i - midpoint
		
		var target_x = viewport_centre.x + (125 * diff)
		var target_y = 600 + abs(30 * diff)
		var target_rot = 0.15 * diff
		
		card.card_position = Vector2(target_x, target_y)
		card.card_rotation = target_rot
		
		if not card_pool[i].picked_up:
			var tween = create_tween().set_parallel(true)
			tween.tween_property(card, "position", Vector2(target_x, target_y), 0.09).set_trans(Tween.TRANS_SINE)
			tween.tween_property(card, "rotation", target_rot, 0.09).set_trans(Tween.TRANS_SINE)
