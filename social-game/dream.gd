extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.position = viewport_centre
	_progress_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _progress_text():
	var tween = create_tween()
	var text = $Label/MainLabel.text
	var timing = 0.18 * sqrt(text.length())
	
	for n in $Label.get_children():
		n.visible_ratio = 0
	
	for n in $Label.get_children():
		tween.parallel().tween_property(n, "visible_ratio", 1, timing)
