extends Button

@onready var dream = preload("res://dream.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	var instance = dream.instantiate()
	get_parent().add_child(instance)
	get_parent().get_node('DeleteSaveButton').visible = false
	get_parent().get_node('Player').visible = false
	get_parent().get_node('FeedButton').visible = false
	get_parent().get_node('MessengerButton').visible = false
	get_parent().get_node('EconomyButton').visible = false
	get_parent().current_screen = "dream"
	visible = false
