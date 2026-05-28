extends Node2D

@onready var main = get_tree().root.get_child(0)

@onready var player = main.get_node("Player")
@onready var hand = player.get_node("Hand")

@onready var feed = main.get_node("Feed")

@onready var viewport_centre = get_viewport_rect().size / 2

@onready var stats_left_pos = $StatsLeft/EnergyLabel.position
@onready var stats_right_pos = $StatsRight/MoneyLabel.position

var dream

var rng = RandomNumberGenerator.new()

var money_colour = "#6bff6a"
var health_colour = "#d0316c"
var followers_colour = "#0072ff"
var energy_colour = "#ece347"

var post_scale : Vector2

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
var intangible = false
var removal_hover = false
var removal_submitted = false

var last_stop = Vector2.ZERO

var offset = Vector2.ZERO

var id
var title
var description
var stats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_prepare_drift()
	
	if main.current_screen == "feed":
		post_scale = feed.get_node("Post").scale
	elif main.current_screen == "dream":
		dream = main.get_node("Dream")
		
	
	$StatsLeft/EnergyLabel.position.x = 0
	$StatsLeft/HealthLabel.position.x = 0
	$StatsRight/FollowersLabel.position.x = 0
	$StatsRight/MoneyLabel.position.x = 0
	
	$CardBody/CardName.text = title
	$CardBody/CardDescription.text = description
	
	if stats.energy >= 0:
		$StatsLeft/EnergyLabel.text = str("[wave amp=11.0 freq=2.5 connected=0]Energy\n+", int(stats.energy), "[/wave]")
	else:
		$StatsLeft/EnergyLabel.text = str("[wave amp=11.0 freq=2.5 connected=0]Energy\n", int(stats.energy), "[/wave]")
		
	if stats.health >= 0:
		$StatsLeft/HealthLabel.text = str("[wave amp=11.0 freq=2.5 connected=0]Health\n+", int(stats.health), "[/wave]")
	else:
		$StatsLeft/HealthLabel.text = str("[wave amp=11.0 freq=2.5 connected=0]Health\n", int(stats.health), "[/wave]")
	
	if stats.followers >= 0:
		$StatsRight/FollowersLabel.text = str("[wave amp=11.0 freq=2.5 connected=0]Stalkers\n+", int(stats.followers), "[/wave]")
	else:
		$StatsRight/FollowersLabel.text = str("[wave amp=11.0 freq=2.5 connected=0]Stalkers\n", int(stats.followers), "[/wave]")	
	
	if stats.money >= 0:
		$StatsRight/MoneyLabel.text = str("[wave amp=11.0 freq=2.5 connected=0]Money\n+", int(stats.money), "[/wave]")
	else:
		$StatsRight/MoneyLabel.text = str("[wave amp=11.0 freq=2.5 connected=0]Money\n", int(stats.money), "[/wave]")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not played and not intangible and not removal_submitted:
		if mouse_over:
			_on_card_body_mouse_entered()
		
		if picked_up:
			global_position = get_global_mouse_position() + offset
			if abs(last_stop.x - global_position.x) > 125:
				_swap_card()
				last_stop = global_position
			
			if main.current_screen == "feed":
				if get_global_mouse_position().y < (viewport_centre.y * 0.75) and not feed.prepared_for_play:
					feed.prepared_for_play = true
					feed._prepare_for_play()
				elif get_global_mouse_position().y >= (viewport_centre.y * 0.75) and feed.prepared_for_play:
					feed.prepared_for_play = false
					feed._unprepare_for_play()
				
		_card_drift(delta)


func _on_card_body_mouse_entered() -> void:
	if intangible:
		return
	
	mouse_over = true
	if not hovering and not hand.card_hovered and not viewing and not picked_up and not played and not removal_submitted:
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
	if intangible:
		return
	
	
	mouse_over = false
	if hovering and not viewing and not played and not removal_submitted:
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
	
	if intangible:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed() && not event.is_echo():
			if hovering and not viewing and not picked_up and not played and not removal_submitted:
				_view_card()
			elif hovering and not picked_up and not played and not removal_submitted:
				_drop_card()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if hovering and not viewing and not picked_up and not played:
				if removal_submitted:
					player._populate_hand()
					dream._hide_confirm_button()
				_pick_up_card()
		elif not event.is_echo():
			if picked_up and not viewing and not played and not removal_hover:
				if get_global_mouse_position().y < (viewport_centre.y * 0.75) and main.current_screen == "feed":
					_play_post()
				else:
					_drop_card()
			elif picked_up and not viewing and not played and removal_hover:
				viewing = false
				picked_up = false
				hand.card_hovered = false
				removal_submitted = true
				_card_drift_reset()
				dream._snap_for_remove(self)
			

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
	
	_show_stats()
	
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
	
	_hide_stats()
	
	await tween.finished
	
	if main.current_screen == "dream":
		dream.picked_up_card = null
	
	viewing = false
	picked_up = false
	hovering = false
	hand.card_hovered = false

func _show_stats():
	$StatsLeft.visible = true
	$StatsRight.visible = true
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($StatsLeft/EnergyLabel, "position:x", stats_left_pos.x - 10, 0.1)
	tween.parallel().tween_property($StatsLeft/HealthLabel, "position:x", stats_left_pos.x - 10, 0.1)
	tween.parallel().tween_property($StatsRight/FollowersLabel, "position:x", stats_right_pos.x + 10, 0.1)
	tween.parallel().tween_property($StatsRight/MoneyLabel, "position:x", stats_right_pos.x + 10, 0.1)
	tween.tween_property($StatsLeft/EnergyLabel, "position:x", stats_left_pos.x, 0.2)
	tween.parallel().tween_property($StatsLeft/HealthLabel, "position:x", stats_left_pos.x, 0.2)
	tween.parallel().tween_property($StatsRight/FollowersLabel, "position:x", stats_right_pos.x, 0.2)
	tween.parallel().tween_property($StatsRight/MoneyLabel, "position:x", stats_right_pos.x, 0.2)


func _hide_stats():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($StatsLeft/EnergyLabel, "position:x", stats_left_pos.x - 10, 0.05)
	tween.parallel().tween_property($StatsLeft/HealthLabel, "position:x", stats_left_pos.x - 10, 0.05)
	tween.parallel().tween_property($StatsRight/FollowersLabel, "position:x", stats_right_pos.x + 10, 0.05)
	tween.parallel().tween_property($StatsRight/MoneyLabel, "position:x", stats_right_pos.x + 10, 0.05)
	tween.tween_property($StatsLeft/EnergyLabel, "position:x", 0, 0.1)
	tween.parallel().tween_property($StatsLeft/HealthLabel, "position:x", 0, 0.1)
	tween.parallel().tween_property($StatsRight/FollowersLabel, "position:x", 0, 0.1)
	tween.parallel().tween_property($StatsRight/MoneyLabel, "position:x", 0, 0.1)
	
	await tween.finished
	
	$StatsLeft.visible = false
	$StatsRight.visible = false
	

func _pick_up_card():
	
	var tween = create_tween()
	
	picked_up = true
	removal_submitted = false
	offset = global_position - get_global_mouse_position()
	
	if main.current_screen == "dream":
		dream.picked_up_card = self
	
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
	set_name("Card")
	hand.card_pool.erase(self)
	player.deck.erase(self)
	
	if player.deck.size() == 0:
		feed.get_node("NewPostButton")._disable()
	
	feed.current_post_index -= 1
	feed.next_post = feed.current_post
	feed.next_post.position = Vector2(feed.post_position.x, feed.post_position.y + feed.post_height)
	feed.current_post = self
	played = true
	_card_drift_reset()
	_place_card_animation()
	main._shake()
	feed._affect_stats(stats)
	z_index = 1
	hand.card_pool.erase(self)
	hand._hide_hand()
	main.in_hand = false
	hand.card_hovered = false
	hand.remove_child(self)
	feed.add_child(self)

func _submit_card_for_removal():
	pass
	
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
	
func _destroy_card():
	var tween = create_tween()
	var shader_mat = material as ShaderMaterial
	if not shader_mat:
		return
		
	shader_mat.set_shader_parameter("progress", 0.0)
	
	tween = create_tween()
	
	tween.tween_property(shader_mat, "shader_parameter/progress", 1.0, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
		
	await tween.finished
	
	player._remove_from_deck(self)
	hand.remove_child(self)
	
