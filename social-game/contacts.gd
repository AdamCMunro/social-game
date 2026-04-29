extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_prepare_drift()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_drift(delta)
	

#drift stuff

var noise = FastNoiseLite.new()
var time = 0.0

var speed = 1.75
var amplitude = 6.0 # How far it drifts
var rotation_amplitude = 0.75 # How much it tilts

func _prepare_drift():
	noise.seed = randi()
	noise.frequency = 0.1
	
func _drift(delta):
	time += delta * speed

	var ox = noise.get_noise_1d(time) * amplitude
	var oy = noise.get_noise_1d(time + 100) * amplitude
	var ang = noise.get_noise_1d(time + 200) * rotation_amplitude

	$Sprite2D.position = Vector2(ox, oy)
	$Sprite2D.rotation_degrees = ang
