extends Node2D

@onready var post_scene = preload("res://post.tscn")
@onready var main = get_parent()
@onready var viewport_centre = get_viewport_rect().size / 2

var current_post
var current_post_body

var next_post
var next_post_body

var post_height
var post_position
var post_data

var is_scrolling = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FeedBackground.position = viewport_centre
	current_post = _instaniate_post(post_data)
	
	next_post = _instaniate_post(post_data)
	
	post_position = viewport_centre
	
	post_height = current_post.get_node("PostBody/Sprite2D").get_rect().size.y * current_post.scale.y
	
	next_post.position.y = post_position.y + post_height


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _instaniate_post(post_data):
	var new_post = post_scene.instantiate()
	new_post.position = viewport_centre
	
	#new_post.user = post_data.user
	#new_post.caption = post_data.caption
	add_child(new_post)
	return new_post
	
func _input(event):
	if is_scrolling:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if not main.in_hand:
				is_scrolling = true
				_reset_post(next_post)
				var tween = _move_posts(current_post, next_post)
				await tween.finished

				_recycle_posts()

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
	
	if current_post.get_name() == "Post":
		recycled_post = current_post
	else:
		current_post.queue_free()
		recycled_post = _instaniate_post(post_data)
	
	current_post = next_post
	current_post.position = post_position
	
	next_post = recycled_post
	
	next_post.position = Vector2(post_position.x, post_position.y + post_height)

	_populate_post(next_post, post_data)
	
func _populate_post(post, data):
	pass
	
func _reset_post(post):
	var like = post.get_node("PostBody/LikeButton")
	var comment = post.get_node("PostBody/CommentButton")
	var send = post.get_node("PostBody/SendButton")
	
	var button_arr = [like, comment, send]
	
	for b in button_arr:
		if b and b.pressed:
			b._unpress()
