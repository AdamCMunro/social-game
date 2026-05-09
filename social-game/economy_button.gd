extends Button

@onready var economy = preload("res://economy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	var instance = economy.instantiate()
	get_parent().add_child(instance)
	get_parent().get_node('DeleteSaveButton').visible = false
	get_parent().get_node('Player').visible = true
	get_parent().get_node('FeedButton').visible = false
	get_parent().get_node('MessengerButton').visible = false
	visible = false
