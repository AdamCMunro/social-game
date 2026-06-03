extends Area2D

@onready var main = get_parent()
@onready var feed_scene = preload("res://feed.tscn")
@onready var messenger_scene = preload("res://messenger.tscn")
@onready var economy_scene = preload("res://economy.tscn")
@onready var dream_scene = preload("res://dream.tscn")

var black = Color(0,0,0,1)
var white = Color(1,1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	$ColorRect.visible = true
	$Label.set("theme_override_colors/font_color",black)

func _on_mouse_exited() -> void:
	$ColorRect.visible = false
	$Label.set("theme_override_colors/font_color",white)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			_transition_screen()

func _transition_screen():
	var current_screen = main.current_screen
	
	match current_screen:
		"feed":
			await main.get_node("Feed")._transition_out().finished
			main.get_node("Player").visible = false
			main.get_node("Feed").queue_free()
			var instance = messenger_scene.instantiate()
			instance.visible = false
			main.add_child(instance)
			main.current_screen = "messenger"
			await instance._hide_for_pause().finished
			instance.visible = true
			instance._transition_in()
		"messenger":
			await main.get_node("Messenger")._transition_out().finished
			main.get_node("Messenger").queue_free()
			var instance = economy_scene.instantiate()
			instance.visible = false
			main.add_child(instance)
			main.current_screen = "economy"
			await instance._hide_for_pause().finished
			instance.visible = true
			instance._transition_in()
		"economy":
			await main.get_node("Economy")._transition_out().finished
			main.get_node("Economy").queue_free()
			var instance = dream_scene.instantiate()
			instance.visible = false
			main.add_child(instance)
			main.current_screen = "dream"
			await instance._hide_for_pause().finished
			instance.visible = true
			instance._transition_in()
		"dream":
			pass
