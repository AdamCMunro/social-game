extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LabelArea.position = viewport_centre
	await get_tree().create_timer(0.8).timeout
	$LabelArea/Label.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
