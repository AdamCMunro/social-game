extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2.ZERO
	position = viewport_centre


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _show_pause():
	visible = true
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "scale", Vector2(1,1), 0.2)
	
func _hide_pause():
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "scale", Vector2(0,0), 0.2)
	
	await tween.finished
	
	visible = false
