extends Node2D

@onready var post_scene = preload("res://post.tscn")
@onready var change_label_scene = preload("res://change_label.tscn")
@onready var main = get_parent()
@onready var pause = main.get_node("Pause")
@onready var player = main.get_node("Player")
@onready var viewport_centre = get_viewport_rect().size / 2

var money_colour = "#6bff6a"
var health_colour = "#d0316c"
var followers_colour = "#0072ff"
var energy_colour = "#ece347"

var current_post_seed = "000" #where first character is binary liked, second is binary reposted and third is 0-3 indicating if a comment was made

var current_post
var current_post_body

var next_post
var next_post_body

var post_height
var post_position

var post_array
var post_data
var current_post_index = 0

var new_post_button_pos
var comment_box_pos
var hand_pos
var background_pos
var stat_block_pos
var background_width
var end_label_pos
var continue_button_pos

var is_scrolling = false
var paused = false
var commenting = false
var prepared_for_play = false
var feed_ended = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	post_array = _json_decode(str("res://daily_files/", main.current_day, "/posts.json"))
	post_data = _json_decode("res://posts/post_dict.json")
	
	$FeedBackground.position = viewport_centre
	
	background_pos = $FeedBackground/Texture.position
	background_width = $FeedBackground/Texture.size.x
	
	$CommentBox.position = viewport_centre
	$CommentBox.position.y = 1000
	
	$EndLabel.position.y = 1000
	
	$ContinueButton.position = viewport_centre
	$ContinueButton.position.y = 1000
	
	end_label_pos = Vector2($EndLabel.position.x, 250)
	
	continue_button_pos = Vector2(viewport_centre.x, viewport_centre.y + 230)
	
	comment_box_pos = Vector2(viewport_centre.x, 525)
	
	stat_block_pos = player.get_node("StatBlock").position
	
	current_post = _instaniate_post(_get_current_post_data())
	
	_populate_comments()
	
	next_post = _instaniate_post(_get_next_post_data())
	
	post_position = viewport_centre
	
	post_height = current_post.get_node("PostBody/Sprite2D").get_rect().size.y * current_post.scale.y
	
	next_post.position.y = post_position.y + post_height

	new_post_button_pos = $NewPostButton.position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$FeedBackground.position = viewport_centre
	
	if Input.is_action_just_pressed("pause"):
		if not paused:
			paused = true
			await _hide_for_pause().finished
			pause._show_pause()
		else:
			paused = false
			await pause._hide_pause().finished
			pause.visible = false
			_show_for_resume()

func _get_current_post_data():
	return post_data[post_array[current_post_index]]

func _get_next_post_data():
	return post_data[post_array[current_post_index + 1]]

func _instaniate_post(data):
	var new_post = post_scene.instantiate()
	new_post.position = viewport_centre
	
	new_post.get_node("PostBody/Username").text = data.user
	new_post.get_node("PostBody/Caption").text = data.caption
	add_child(new_post)
	return new_post
	
func _populate_comments():
	var data = _get_current_post_data().options
	var option_arr = [data[0].option, data[1].option, data[2].option]
	var full_arr = [data[0].full, data[1].full, data[2].full]
	
	$CommentBox.option_text = option_arr
	$CommentBox.full_text = full_arr
	
func _input(event):
	if is_scrolling or commenting:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed and not feed_ended:
			_trigger_scroll()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed and feed_ended:
			_final_scroll()
	elif event is InputEventPanGesture:
		if event.delta.y > 0.5 and not feed_ended: 
			_trigger_scroll()
		elif event.delta.y > 0.5 and feed_ended:
			_final_scroll()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_DOWN and not event.is_echo():
			if feed_ended:
				_final_scroll()
			else:
				_trigger_scroll()
	

func _trigger_scroll():
	if not main.in_hand:
		is_scrolling = true
		main._append_today_seed(current_post_seed)
		current_post_seed = "000"
		_reset_post(next_post)
		var tween = _move_posts(current_post, next_post)
		await tween.finished
		_effect_stats()
		if current_post_index + 1 < post_array.size() - 1:
			_recycle_posts()
		elif current_post_index + 1 == post_array.size() - 1:
			feed_ended = true
			
		await get_tree().create_timer(0.4).timeout
		is_scrolling = false

func _final_scroll():
	var tween = create_tween()
	is_scrolling = true
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(next_post, "position:y", viewport_centre.y - post_height, 0.5)
	tween.parallel().tween_property($EndLabel, "position:y", end_label_pos.y - 15, 0.5)
	tween.parallel().tween_property($ContinueButton, "position:y", continue_button_pos.y - 15, 0.5)
	tween.tween_property($EndLabel, "position:y", end_label_pos.y, 0.3)
	tween.parallel().tween_property($ContinueButton, "position:y", continue_button_pos.y, 0.3)
	
	await tween.finished
	
	is_scrolling = false

func _move_posts(post, post2):
	var tween = create_tween()
	tween.tween_property(post, "position", Vector2(viewport_centre.x, viewport_centre.y -post_height), 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(post2, "position", viewport_centre, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	return tween

func _recycle_posts():
	var recycled_post
	
	current_post_index += 1
	
	_populate_comments()
	
	if current_post.get_name() == "Post":
		recycled_post = current_post
	else:
		current_post.queue_free()
		recycled_post = _instaniate_post(_get_next_post_data())
	
	current_post = next_post
	current_post.position = post_position
	
	next_post = recycled_post
	
	next_post.position = Vector2(post_position.x, post_position.y + post_height)

	_populate_post(next_post, _get_next_post_data())
	
func _populate_post(post, data):
	post.get_node("PostBody/Username").text = data.user
	post.get_node("PostBody/Caption").text = data.caption
	
func _reset_post(post):
	var like = post.get_node("PostBody/LikeButton")
	var comment = post.get_node("PostBody/CommentButton")
	var send = post.get_node("PostBody/SendButton")
	
	var button_arr = [like, comment, send]
	
	for b in button_arr:
		if b and b.pressed:
			b._unpress()
	
	comment.commented = false
	
func _hide_for_pause():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	
	if main.in_hand:
		var hand = player.get_node("Hand")
		hand_pos = hand.position
		tween.tween_property(hand, "position:y", hand_pos.y - 20, 0.05)
		tween.tween_property(hand, "position:y", 1000, 0.05)
	
	if commenting:
		tween.tween_property($CommentBox, "position:y", comment_box_pos.y - 20, 0.05)
		tween.tween_property($CommentBox, "position:y", 1000, 0.05)
		
	if not feed_ended:
		tween.tween_property(current_post, "position:y", post_position.y - 20, 0.05)
	else:
		tween.tween_property($ContinueButton, "position:y", continue_button_pos.y - 20, 0.05)
		tween.parallel().tween_property($EndLabel, "position:y", end_label_pos.y - 20, 0.05)

	tween.parallel().tween_property($NewPostButton, "position:y", new_post_button_pos.y + 20, 0.05)
	tween.parallel().tween_property(player.get_node("StatBlock"), "position:x", stat_block_pos.x + 20, 0.05)
	tween.parallel().tween_property($FeedBackground/Texture, "size:x", background_width - 40, 0.08)
	
	if not feed_ended:
		tween.tween_property(current_post, "position:y", 1000, 0.08)
	else:
		tween.tween_property($ContinueButton, "position:y", 1000, 0.05)
		tween.parallel().tween_property($EndLabel, "position:y", 1000, 0.05)
	
	
	tween.parallel().tween_property($NewPostButton, "position:y", -100, 0.08)
	tween.parallel().tween_property(player.get_node("StatBlock"), "position:x", -200, 0.08)
	tween.parallel().tween_property($FeedBackground/Texture, "size:x", 3000, 0.1)
	tween.parallel().tween_property($FeedBackground/Texture, "position:x", -1500, 0.1)
	
	return tween
	
func _show_for_resume():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	if not feed_ended:
		tween.tween_property(current_post, "position:y", post_position.y + 20, 0.05)
	else:
		tween.tween_property($ContinueButton, "position:y", continue_button_pos.y + 20, 0.05)
		tween.parallel().tween_property($EndLabel, "position:y", end_label_pos.y + 20, 0.05)
	
	tween.parallel().tween_property($NewPostButton, "position:y", new_post_button_pos.y + 20, 0.05)
	tween.parallel().tween_property(player.get_node("StatBlock"), "position:x", stat_block_pos.x + 20, 0.05)
	tween.parallel().tween_property($FeedBackground/Texture, "size:x", background_width, 0.05)
	tween.parallel().tween_property($FeedBackground/Texture, "position:x", background_pos.x, 0.05)
	
	if not feed_ended:
		tween.tween_property(current_post, "position:y", post_position.y, 0.08)
	else:
		tween.tween_property($ContinueButton, "position:y", continue_button_pos.y, 0.05)
		tween.parallel().tween_property($EndLabel, "position:y", end_label_pos.y, 0.05)
	
	tween.parallel().tween_property($NewPostButton, "position:y", new_post_button_pos.y, 0.05)
	tween.parallel().tween_property(player.get_node("StatBlock"), "position:x", stat_block_pos.x, 0.05)
	
	if main.in_hand:
		var hand = player.get_node("Hand")
		tween.tween_property(hand, "position:y", hand_pos.y - 20, 0.05)
		tween.tween_property(hand, "position:y", hand_pos.y, 0.05)
	
	if commenting:
		tween.tween_property($CommentBox, "position:y", comment_box_pos.y - 20, 0.05)
		tween.tween_property($CommentBox, "position:y", comment_box_pos.y, 0.05)
	
func _show_comment_box():
	for i in range($CommentBox.option_arr.size()):
		$CommentBox.option_arr[i].get_node("Label").text = $CommentBox.option_text[i]
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($CommentBox, "position:y", comment_box_pos.y - 20, 0.2)
	tween.tween_property($CommentBox, "position:y", comment_box_pos.y, 0.2)
	
	
func _hide_comment_box():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($CommentBox, "position:y", comment_box_pos.y - 20, 0.2)
	tween.tween_property($CommentBox, "position:y", 1000, 0.2)
	
	await tween.finished
	
	_reset_comment_box()
		
func _reset_comment_box():
	$CommentBox/Cancel.position = $CommentBox.cancel_pos
	
	for i in range($CommentBox.option_arr.size()):
		var option = $CommentBox.option_arr[i]
		var pos = $CommentBox.option_pos[i]
		var text = $CommentBox.option_text[i]
		
		option.position = pos
		$CommentBox._deselect(option, text)
		$CommentBox.selected_option = null
		
	$CommentBox.commenting_text.text = "Type random letters to comment"

func _prepare_for_play():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(current_post, "position:y", post_position.y - 10, 0.05)
	tween.tween_property(current_post, "position:y", post_position.y + post_height, 0.05)

	
func _unprepare_for_play():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(current_post, "position:y", post_position.y - 10, 0.05)
	tween.tween_property(current_post, "position:y", post_position.y, 0.05)
	
func _json_decode(file_path: String) -> Array:
	var content = FileAccess.get_file_as_string(file_path)
	var data = JSON.parse_string(content)
	
	if typeof(data) == TYPE_ARRAY:
		return data as Array
		
	push_error("Failed to parse JSON, or the root is not an Array.")
	return []	

func _effect_stats():
	var stats = _get_current_post_data().stats
	
	if stats.energy != 0:
		_change_stat("energy", stats.energy)
		await get_tree().create_timer(0.5).timeout
		
	if stats.health != 0:
		_change_stat("health", stats.health)
		await get_tree().create_timer(0.5).timeout
		
	if stats.followers != 0:
		_change_stat("followers", stats.followers)
		await get_tree().create_timer(0.5).timeout
		
	if stats.money != 0:
		_change_stat("money", stats.money)
		
		
		
func _change_stat(stat : String, value : int):
	var text : String
	var colour: String
	
	match stat:
		"energy":
			colour = energy_colour
			player._update_energy(player.energy + value)
		"health":
			colour = health_colour
			player._update_health(player.health + value)
		"followers":
			colour = followers_colour
			player._update_followers(player.followers + value)
		"money":
			colour = money_colour
			player._update_money(player.money + value)
	
	if value < 0:
		text = str("[color=", colour, "]", value, "[/color]")
		_show_change_label(text)
		await get_tree().create_timer(0.2).timeout
		main._shake()
	else:
		text = str("[color=", colour, "]+", value, "[/color]")
		_show_change_label(text)
	
func _show_change_label(text):
	var label = _create_change_label()
	label.text = text
	await _animate_change_label(label).finished
	label.visible = false
	label.queue_free()

func _create_change_label():
	var instance = change_label_scene.instantiate()
	instance.visible = false
	instance.position = Vector2(172, 43)
	add_child(instance)
	return instance

func _animate_change_label(label):
	label.modulate.a = 0
	label.position = Vector2(750, 450)
	label.visible = true
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(label, "position:y", -125, 0.3).as_relative()
	tween.parallel().tween_property(label, "modulate:a", 1, 0.2)
	tween.tween_property(label, "position:y", 125, 0.4).as_relative()
	tween.parallel().tween_property(label, "modulate:a", 0, 0.4)
	
	return tween
	
	
	
