extends Node2D

@onready var viewport_centre = get_viewport_rect().size / 2

@onready var main = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LabelArea.position = viewport_centre
	await get_tree().create_timer(2).timeout
	$LabelArea/Label.visible = true
	await get_tree().create_timer(0.8).timeout
	_transition_day()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _transition_day():
	main.current_day += 1
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($LabelArea, "rotation_degrees", -20, 0.2)
	tween.tween_property($LabelArea, "rotation_degrees", 180, 0.1)
	
	$LabelArea/Label.text = str("Day ", main.current_day)
	
	tween.tween_property($LabelArea, "rotation_degrees", 390, 0.11)
	tween.tween_property($LabelArea, "rotation_degrees", -10, 0.1)
	tween.tween_property($LabelArea, "rotation_degrees", 0, 0.1)
	tween.tween_property($LabelArea, "rotation_degrees", 0, 1)
	tween.tween_property($LabelArea, "modulate:a", 0, 0.5)
	
	await tween.finished
	
	await get_tree().create_timer(0.3).timeout
	
	main.get_node("ContinueButton")._transition_screen()
