extends Node2D

@onready var post_scene = preload("res://post.tscn")
@onready var main = get_parent()
@onready var pause = main.get_node("Pause")
@onready var player = main.get_node("Player")
@onready var viewport_centre = get_viewport_rect().size / 2

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
	
func _input(event):
	if is_scrolling:
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
	

func _trigger_scroll():
	if not main.in_hand:
		is_scrolling = true
		_reset_post(next_post)
		var tween = _move_posts(current_post, next_post)
		await tween.finished
		
		if current_post_index + 1 < post_array.size() - 1:
			_recycle_posts()
		elif current_post_index + 1 == post_array.size() - 1:
			feed_ended = true
			
		await get_tree().create_timer(0.4).timeout
		is_scrolling = false

func _final_scroll():
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(next_post, "position", Vector2(viewport_centre.x, viewport_centre.y -post_height), 0.5)
	tween.tween_property($EndLabel, "position:y", end_label_pos.y - 10, 0.3)
	tween.parallel().tween_property($ContinueButton, "position:y", continue_button_pos.y - 10, 0.3)
	tween.tween_property($EndLabel, "position:y", end_label_pos.y, 0.2)
	tween.parallel().tween_property($ContinueButton, "position:y", continue_button_pos.y, 0.2)

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
	
	
	
	
