extends Node2D

@onready var buttons = [$FeedButton, $MessengerButton, $DeleteSaveButton, $EconomyButton, $DreamButton]

var in_hand = false
var today_seed = ""
var seed = ""
var current_screen = ""
var current_day = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _append_seed(char):
	seed = str(seed, char)
	
func _append_today_seed(data):
	today_seed = str(today_seed, data)

func _shake():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position", Vector2(5, 8), 0.02)
	tween.tween_property(self, "position", Vector2(-5, -1), 0.03)
	tween.tween_property(self, "position", Vector2(8, -7), 0.02)
	tween.tween_property(self, "position", Vector2(-3, 2), 0.01)
	tween.tween_property(self, "position", Vector2(1, -10), 0.04)
	tween.tween_property(self, "position", Vector2(5, 8), 0.02)
	tween.tween_property(self, "position", Vector2(-5, -1), 0.03)
	tween.tween_property(self, "position", Vector2(8, -7), 0.02)
	tween.tween_property(self, "position", Vector2(-3, 2), 0.01)
	tween.tween_property(self, "position", Vector2(1, -1), 0.04)
	tween.tween_property(self, "position", Vector2.ZERO, 0.02)
