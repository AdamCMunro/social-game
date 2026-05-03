extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	



func _on_pressed() -> void:
	DirAccess.remove_absolute(str("user://chat_logs/history/desmond.json"))
	DirAccess.remove_absolute(str("user://chat_logs/history/angela.json"))
	DirAccess.remove_absolute(str("user://chat_logs/history/james.json"))
