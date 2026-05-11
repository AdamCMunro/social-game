extends Node2D

@onready var income_position = position
@onready var income_scale = scale

var floating = false

var label_text :String
var amount_text :String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_text = $IncomeBody/Label.text
	amount_text = $IncomeBody/Amount.text 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_income_body_mouse_entered() -> void:
	if not floating:
		_add_wave($IncomeBody/Label, label_text)
		_add_wave($IncomeBody/Amount, amount_text)
		_rise_up($IncomeBody/Label)
		_rise_up($IncomeBody/Amount)


func _on_income_body_mouse_exited() -> void:
	if not floating:
		_remove_wave($IncomeBody/Label, label_text)
		_remove_wave($IncomeBody/Amount, amount_text)
		_fall_down($IncomeBody/Label)
		_fall_down($IncomeBody/Amount)

func _add_wave(label, text):
	label.text = str("[wave amp=12.0 freq=4 connected=0]", text, "[/wave]")
	
func _remove_wave(label, text):
	label.text = text

func _rise_up(node):
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:y", income_position.y - 5, 0.15)
	tween.parallel().tween_property(self, "scale", income_scale * 1.05, 0.15)
	tween.tween_property(self, "position:y", income_position.y - 2.5, 0.25)
	tween.parallel().tween_property(self, "scale", income_scale * 1.025, 0.25)
	
	
func _fall_down(node):
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:y", income_position.y + 1, 0.2)
	tween.parallel().tween_property(self, "scale", income_scale * 0.975, 0.2)
	tween.tween_property(self, "position:y", income_position.y, 0.25)
	tween.parallel().tween_property(self, "scale", income_scale, 0.25)
