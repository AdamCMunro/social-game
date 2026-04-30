extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_bubble_width(text)

# Attach this to your Label node
func update_bubble_width(text_string: String):
	text = text_string

# Reset wrap to calculate natural width
	autowrap_mode = TextServer.AUTOWRAP_OFF
	custom_minimum_size.x = 0

# Wait for the engine to calculate the new size
	await get_tree().process_frame

	if size.x > 300: # Your Max Width
		autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		custom_minimum_size.x = 300
	else:
		# Keep it small for short messages
		custom_minimum_size.x = size.x
