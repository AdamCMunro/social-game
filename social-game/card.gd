extends Node2D

@onready var hand = get_parent()
@onready var player = hand.get_parent()
@onready var main = player.get_parent()
@onready var feed = main.get_node("Feed")
@onready var post_scale = feed.get_node("Post").scale

@onready var viewport_centre = get_viewport_rect().size / 2

var rng = RandomNumberGenerator.new()

var card_scale
var card_rotation
var card_position
var card_z
var card_x_offset = 125

var hovering = false
var mouse_over = false
var viewing = false
var picked_up = false
var played = false

var last_stop = Vector2.ZERO

var offset = Vector2.ZERO

var id
var title
var description
var stats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_prepare_drift()
	
	$CardBody/CardName.text = title
	$CardBody/CardDescription.text = description
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not played:
		if mouse_over:
			_on_card_body_mouse_entered()
		
		if picked_up:
			global_position = get_global_mouse_position() + offset
			if abs(last_stop.x - global_position.x) > 125:
				_swap_card()
				last_stop = global_position
				
			if get_global_mouse_position().y < (viewport_centre.y * 0.75) and not feed.prepared_for_play:
				feed.prepared_for_play = true
				feed._prepare_for_play()
			elif get_global_mouse_position().y >= (viewport_centre.y * 0.75) and feed.prepared_for_play:
				feed.prepared_for_play = false
				feed._unprepare_for_play()
		

		_card_drift(delta)


func _on_card_body_mouse_entered() -> void:
	mouse_over = true
	if not hovering and not hand.card_hovered and not viewing and not picked_up and not played:
		hovering = true
		hand.card_hovered = true
		
		var tween = create_tween()
		tween.tween_property(self, "scale", card_scale * 1.1, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(self, "rotation", 0, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(self, "position", Vector2(card_position.x, 505), 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
		var hand_size = hand.get_children().size()
		
		self.z_index += hand_size
		
func _on_card_body_mouse_exited() -> void:
	mouse_over = false
	if hovering and not viewing and not played:
		hovering = false
		hand.card_hovered = false
		
		var tween = create_tween()
		tween.tween_property(self, "scale", card_scale, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(self, "rotation", card_rotation, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(self, "position", card_position, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
		self.z_index = card_z


func _on_card_body_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed() && not event.is_echo():
			if hovering and not viewing and not picked_up and not played:
				_view_card()
			elif hovering and not picked_up:
				_drop_card()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if hovering and not viewing and not picked_up and not played:
				_pick_up_card()
		elif not event.is_echo():
			if picked_up:
				if get_global_mouse_position().y < (viewport_centre.y * 0.75):
					_play_post()
				else:
					_drop_card()
			

func _view_card():
	viewing = true
	var tween = create_tween()
	
	tween.tween_property(self, "scale", card_scale * 1.5, 0.15)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "rotation", 0, 0.15)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "position", viewport_centre, 0.15)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	
	var hand_size = hand.get_children().size()
	z_index += hand_size
	
		
func _drop_card():
	var tween = create_tween()
	
	tween.tween_property(self, "scale", card_scale, 0.15)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "rotation", card_rotation, 0.15)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "position", card_position, 0.15)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	viewing = false
	picked_up = false
	hovering = false
	hand.card_hovered = false
	
func _pick_up_card():
	
	var tween = create_tween()
	
	picked_up = true
	offset = global_position - get_global_mouse_position()
	
	tween.tween_property(self, "scale", card_scale * 1.1, 0.15)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "rotation", 0, 0.15)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	
	z_index += hand.card_pool.size()
	
func _swap_card():
	var cards_in_hand = hand.card_pool
	var current_index = cards_in_hand.find(self)
	var swap_index = current_index
	var closest_dist = INF

	var my_x = get_global_mouse_position().x

	for i in range(cards_in_hand.size()):
		if i == current_index:
			continue
		
		var dist = abs(my_x - cards_in_hand[i].card_position.x)
		
		if dist <= closest_dist:
			closest_dist = dist
			swap_index = i

	if swap_index != current_index:
		hand._move_card(current_index, swap_index)

func _play_post():
	hand.card_pool.erase(self)
	feed.next_post = feed.current_post
	feed.next_post.position = Vector2(feed.post_position.x, feed.post_position.y + feed.post_height)
	feed.current_post = self
	played = true
	_card_drift_reset()
	_place_card_animation()
	z_index = 1
	hand.card_pool.erase(self)
	hand._hide_hand()
	main.in_hand = false
	hand.card_hovered = false
	hand.remove_child(self)
	feed.add_child(self)
	
func _place_card_animation():
	var tween = create_tween()
	
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "position", viewport_centre, 0.1)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "scale", post_scale, 0.3)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	

#card drift stuff

var noise = FastNoiseLite.new()
var time = 0.0

var speed = 0.5
var amplitude = 15.0 # How far it drifts
var rotation_amplitude = 6.0 # How much it tilts

func _prepare_drift():
	noise.seed = randi()
	noise.frequency = 0.1
	
func _card_drift(delta):
	time += delta * speed

	var ox = noise.get_noise_1d(time) * amplitude
	var oy = noise.get_noise_1d(time + 100) * amplitude 
	var ang = noise.get_noise_1d(time + 200) * rotation_amplitude

	$CardBody.position = Vector2(ox, oy)
	$CardBody.rotation_degrees = ang
	
func _card_drift_reset():
	var tween = create_tween()
	
	tween.tween_property($CardBody, "position", Vector2.ZERO, 0.01)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property($CardBody, "rotation", 0, 0.01)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)
	
