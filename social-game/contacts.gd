extends Area2D

var contacts = []
var contact_names = ["Desmond", "Angela", "James", "Test"]

@onready var contact_scene = preload("res://contact.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_prepare_drift()
	for i in range (contact_names.size()):
		var new_contact = contact_scene.instantiate()
		new_contact.contact_name = contact_names[i]
		new_contact.get_node("ContactBody/Label").text = contact_names[i]
		new_contact.position.y = -200 + (50 * i)
		contacts.append(new_contact)
		$ContactBody.add_child(new_contact)
	await get_tree().create_timer(3).timeout
	_check_finished()
	
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_drift(delta)
	

func _check_finished():
	var finished = true
	
	for c in contacts:
		if not c.finished or c.pending > 0:
			finished = false
			break
	
	if finished:
		get_parent().main = get_parent().get_parent()
		get_parent().continue_button = get_parent().main.get_node("ContinueButton")
		get_parent()._show_continue_button()
			

#drift stuff

var noise = FastNoiseLite.new()
var time = 0.0

var speed = 1
var amplitude = 4.0 # How far it drifts
var rotation_amplitude = 0.75 # How much it tilts

func _prepare_drift():
	noise.seed = randi()
	noise.frequency = 0.1
	
func _drift(delta):
	time += delta * speed

	var ox = noise.get_noise_1d(time) * amplitude
	var oy = noise.get_noise_1d(time + 100) * amplitude
	var ang = noise.get_noise_1d(time + 200) * rotation_amplitude

	$ContactBody.position = Vector2(ox, oy)
	$ContactBody.rotation_degrees = ang
