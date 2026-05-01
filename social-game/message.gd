extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_bubble_width(text)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Attach this to your Label node
func update_bubble_width(text_string: String):
	text = text_string

# Reset wrap to calculate natural width
	autowrap_mode = TextServer.AUTOWRAP_OFF
	custom_minimum_size.x = 0
	
	var natural_size = get_combined_minimum_size()
	
	var max_width = 250

	if natural_size.x > max_width: # Your Max Width
		autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		custom_minimum_size.x = max_width
	else:
		# Keep it small for short messages
		custom_minimum_size.x = natural_size.x

	
