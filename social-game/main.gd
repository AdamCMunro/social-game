extends Node2D

@onready var buttons = [$FeedButton, $MessengerButton, $DeleteSaveButton, $EconomyButton]

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
